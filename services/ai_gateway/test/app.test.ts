import assert from 'node:assert/strict';
import type {AddressInfo} from 'node:net';
import {createServer as createHttpServer, type RequestListener} from 'node:http';
import test from 'node:test';

import {createGatewayHandler, type GatewayDependencies} from '../src/app.js';
import type {
  AuthDecision,
  DiaryGenerationOptions,
  SafeRequestLog,
  VertexModelPort,
} from '../src/ports.js';
import {
  ModelFinishReasonError,
  ModelInvalidResponseError,
  ModelSafetyBlockedError,
  ModelTimeoutError,
  ModelTruncatedError,
} from '../src/ports.js';
import {InMemoryIdempotencyStore} from '../src/idempotency.js';
import {validChatRequest, validDiaryOutput, validDiaryRequest} from './fixtures.js';

test('GET /healthz is public and returns a no-store readiness response', async () => {
  const harness = makeHarness();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const response = await fetch(`${baseUrl}/healthz`);

    assert.equal(response.status, 200);
    assert.equal(response.headers.get('cache-control'), 'no-store');
    assert.deepEqual(await response.json(), {status: 'ok'});
  });

  assert.equal(harness.authCalls, 0);
  assert.equal(harness.model.chatCalls, 0);
});

test('chat validates headers, returns exact v1 data, and safely replays', async () => {
  const harness = makeHarness();
  const request = validChatRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const first = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': request.requestId,
      authorization: 'Bearer private-auth-token',
      'x-app-attestation': 'private-attestation-token',
    });
    const replay = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': request.requestId,
      authorization: 'Bearer private-auth-token',
      'x-app-attestation': 'private-attestation-token',
    });

    assert.equal(first.status, 200);
    assert.deepEqual(first.body, {
      schemaVersion: 1,
      messageId: 'assistant-fixed',
      text: '오늘의 산책이 편안했나 봐.',
      createdAtUtc: '2026-10-04T09:00:00.000Z',
    });
    assert.equal(replay.status, 200);
    assert.deepEqual(replay.body, first.body);
  });

  assert.equal(harness.model.chatCalls, 1);
  assert.equal(harness.quotaCalls, 1);
  assert.deepEqual(harness.lastAuthInput, {
    authorization: 'Bearer private-auth-token',
    attestation: 'private-attestation-token',
  });
  assert.equal(harness.logs.at(-1)?.idempotency, 'replayed');
  const serializedLogs = JSON.stringify(harness.logs);
  assert.doesNotMatch(serializedLogs, /천천히 산책/);
  assert.doesNotMatch(serializedLogs, /private-auth-token/);
  assert.doesNotMatch(serializedLogs, /private-attestation-token/);
  assert.doesNotMatch(serializedLogs, /fingerprint|body|token/i);
  assert.deepEqual(Object.keys(harness.logs.at(-1)!).sort(), [
    'event',
    'idempotency',
    'latencyMs',
    'method',
    'operation',
    'requestId',
    'route',
    'status',
  ]);
});

test('idempotency header must match body identity and cannot be reused', async () => {
  const harness = makeHarness();
  const request = validChatRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const mismatch = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': 'different-request',
    });
    assert.equal(mismatch.status, 400);

    const first = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': request.requestId,
    });
    assert.equal(first.status, 200);

    const conflict = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...request, text: '같은 ID지만 다른 원문'},
      {'idempotency-key': request.requestId},
    );
    assert.equal(conflict.status, 409);
    assert.deepEqual(conflict.body, {
      error: {code: 'idempotency_conflict'},
    });
  });

  assert.equal(harness.model.chatCalls, 1);
});

test('chat replay identity is stable when retry context has changed', async () => {
  const harness = makeHarness();
  const request = validChatRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const first = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': request.requestId,
    });
    const replay = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {
        ...request,
        persona: {...request.persona, tone: '사용자가 나중에 바꾼 말투'},
        activeMemories: [],
      },
      {'idempotency-key': request.requestId},
    );

    assert.equal(first.status, 200);
    assert.equal(replay.status, 200);
    assert.deepEqual(replay.body, first.body);
  });

  assert.equal(harness.model.chatCalls, 1);
});

test('authentication and attestation failures are distinct and fail closed', async () => {
  for (const [decision, expectedStatus] of [
    [{ok: false, reason: 'unauthorized'} as const, 401],
    [{ok: false, reason: 'attestation'} as const, 403],
  ] as const) {
    const harness = makeHarness({authDecision: decision});

    await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
      const response = await postJson(
        baseUrl,
        '/v1/chat/reply',
        validChatRequest(),
        {'idempotency-key': 'request-1'},
      );
      assert.equal(response.status, expectedStatus);
    });

    assert.equal(harness.model.chatCalls, 0);
    assert.equal(harness.quotaCalls, 0);
  }
});

test('quota failure returns 429 and Retry-After without calling Vertex', async () => {
  const harness = makeHarness({quotaRetryAfterSeconds: 17});

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const response = await postJson(
      baseUrl,
      '/v1/chat/reply',
      validChatRequest(),
      {'idempotency-key': 'request-1'},
    );

    assert.equal(response.status, 429);
    assert.equal(response.headers.get('retry-after'), '17');
    assert.deepEqual(response.body, {error: {code: 'rate_limited'}});
  });

  assert.equal(harness.model.chatCalls, 0);
});

test('JSON content type, exact schema, and body size are enforced', async () => {
  const harness = makeHarness({bodyLimitBytes: 2_048});

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const wrongType = await fetch(`${baseUrl}/v1/chat/reply`, {
      method: 'POST',
      headers: {
        'content-type': 'text/plain',
        'idempotency-key': 'request-1',
      },
      body: '{}',
    });
    assert.equal(wrongType.status, 415);

    const extraField = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...validChatRequest(), rawPrompt: 'not allowed'},
      {'idempotency-key': 'request-1'},
    );
    assert.equal(extraField.status, 400);

    const oversized = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...validChatRequest(), text: 'x'.repeat(4_000)},
      {'idempotency-key': 'request-1'},
    );
    assert.equal(oversized.status, 413);
  });

  assert.equal(harness.model.chatCalls, 0);
});

test('request v1 and unsupported response locales are rejected before Vertex', async () => {
  const harness = makeHarness();
  const request = validChatRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const oldSchema = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...request, schemaVersion: 1},
      {'idempotency-key': request.requestId},
    );
    const unsupportedLocale = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...request, responseLocale: 'fr'},
      {'idempotency-key': request.requestId},
    );

    assert.equal(oldSchema.status, 400);
    assert.equal(unsupportedLocale.status, 400);
  });

  assert.equal(harness.model.chatCalls, 0);
  assert.equal(harness.quotaCalls, 0);
});

test('chat idempotency does not replay a response in a different locale', async () => {
  const harness = makeHarness();
  const request = validChatRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const first = await postJson(baseUrl, '/v1/chat/reply', request, {
      'idempotency-key': request.requestId,
    });
    const differentLocale = await postJson(
      baseUrl,
      '/v1/chat/reply',
      {...request, responseLocale: 'ja'},
      {'idempotency-key': request.requestId},
    );

    assert.equal(first.status, 200);
    assert.equal(differentLocale.status, 409);
  });

  assert.equal(harness.model.chatCalls, 1);
});

test('diary validates the model result against request photo/source ids', async () => {
  const harness = makeHarness();
  const request = validDiaryRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const response = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });

    assert.equal(response.status, 200);
    assert.deepEqual(response.body, validDiaryOutput());
  });

  assert.equal(harness.model.diaryCalls, 1);
  assert.deepEqual(harness.model.lastDiaryRequest, request);
});

test('invalid or failed model output is redacted and never cached', async () => {
  const privateFailure = 'private Vertex response with diary text';
  const invalidOutput = {
    ...validDiaryOutput(),
    blocks: [{type: 'photo', photoAssetId: 'unknown-photo'}],
  };
  const harness = makeHarness({diaryOutput: invalidOutput});
  const request = validDiaryRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const invalid = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });
    assert.equal(invalid.status, 502);
    assert.deepEqual(invalid.body, {error: {code: 'invalid_model_response'}});

    harness.model.diaryError = new Error(privateFailure);
    const failed = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });
    assert.equal(failed.status, 502);
    assert.deepEqual(failed.body, {error: {code: 'model_unavailable'}});
  });

  assert.equal(harness.model.diaryCalls, 3);
  assert.doesNotMatch(JSON.stringify(harness.logs), new RegExp(privateFailure));
  assert.doesNotMatch(JSON.stringify(harness.logs), /unknown-photo/);
});

test('diary repairs one invalid contract result and caches only the valid response', async () => {
  const invalidOutput = {
    ...validDiaryOutput(),
    blocks: [{type: 'photo', photoAssetId: 'unknown-photo'}],
  };
  const harness = makeHarness({
    diaryResults: [invalidOutput, validDiaryOutput()],
  });
  const request = validDiaryRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const repaired = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });
    const replay = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });

    assert.equal(repaired.status, 200);
    assert.deepEqual(repaired.body, validDiaryOutput());
    assert.deepEqual(replay.body, repaired.body);
  });

  assert.equal(harness.model.diaryCalls, 2);
  assert.deepEqual(harness.model.diaryOptions, [
    {repair: false},
    {repair: true},
  ]);
  assert.equal(harness.quotaCalls, 1);
});

test('diary malformed output receives at most one repair attempt', async () => {
  const harness = makeHarness({
    diaryResults: [
      new ModelInvalidResponseError(),
      new ModelInvalidResponseError(),
    ],
  });
  const request = validDiaryRequest();

  await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
    const response = await postJson(baseUrl, '/v1/diary/generate', request, {
      'idempotency-key': request.generationId,
    });

    assert.equal(response.status, 502);
    assert.deepEqual(response.body, {
      error: {code: 'invalid_model_response'},
    });
  });

  assert.equal(harness.model.diaryCalls, 2);
});

test('typed safety, timeout, and truncation failures are redacted and never repaired', async () => {
  const cases = [
    {
      error: new ModelSafetyBlockedError(),
      status: 422,
      code: 'safety_blocked',
    },
    {
      error: new ModelTimeoutError(),
      status: 504,
      code: 'model_timeout',
    },
    {
      error: new ModelTruncatedError(),
      status: 502,
      code: 'model_truncated',
    },
    {
      error: new ModelFinishReasonError(),
      status: 502,
      code: 'invalid_model_response',
    },
  ] as const;

  for (const current of cases) {
    const harness = makeHarness({diaryResults: [current.error]});
    const request = validDiaryRequest();
    await withServer(createGatewayHandler(harness.dependencies), async (baseUrl) => {
      const response = await postJson(baseUrl, '/v1/diary/generate', request, {
        'idempotency-key': request.generationId,
      });
      assert.equal(response.status, current.status);
      assert.deepEqual(response.body, {error: {code: current.code}});
    });

    assert.equal(harness.model.diaryCalls, 1);
    assert.doesNotMatch(JSON.stringify(harness.logs), /private|prompt|body/i);
  }
});

interface HarnessOptions {
  readonly authDecision?: AuthDecision;
  readonly quotaRetryAfterSeconds?: number;
  readonly bodyLimitBytes?: number;
  readonly diaryOutput?: unknown;
  readonly diaryResults?: readonly unknown[];
}

function makeHarness(options: HarnessOptions = {}) {
  const logs: SafeRequestLog[] = [];
  let authCalls = 0;
  let quotaCalls = 0;
  let lastAuthInput:
    | {authorization: string | undefined; attestation: string | undefined}
    | undefined;
  const model = new FakeModel(
    options.diaryResults ?? [options.diaryOutput ?? validDiaryOutput()],
  );
  const dependencies: GatewayDependencies = {
    auth: {
      async verify(input) {
        authCalls += 1;
        lastAuthInput = input;
        return options.authDecision ?? {ok: true, principalId: 'principal-1'};
      },
    },
    quota: {
      async consume() {
        quotaCalls += 1;
        return options.quotaRetryAfterSeconds === undefined
          ? {allowed: true}
          : {
              allowed: false,
              retryAfterSeconds: options.quotaRetryAfterSeconds,
            };
      },
    },
    idempotency: new InMemoryIdempotencyStore({
      ttlMs: 60_000,
      maxEntries: 100,
      now: () => Date.parse('2026-10-04T09:00:00.000Z'),
    }),
    model,
    logger: {write: (entry) => logs.push(entry)},
    bodyLimitBytes: options.bodyLimitBytes ?? 256 * 1_024,
    now: () => Date.parse('2026-10-04T09:00:00.000Z'),
    newId: () => 'assistant-fixed',
  };

  return {
    dependencies,
    logs,
    model,
    get authCalls() {
      return authCalls;
    },
    get quotaCalls() {
      return quotaCalls;
    },
    get lastAuthInput() {
      return lastAuthInput;
    },
  };
}

class FakeModel implements VertexModelPort {
  chatCalls = 0;
  diaryCalls = 0;
  lastDiaryRequest: unknown;
  diaryError: Error | undefined;
  readonly diaryOptions: DiaryGenerationOptions[] = [];
  readonly #diaryResults: readonly unknown[];

  constructor(diaryResults: readonly unknown[]) {
    this.#diaryResults = diaryResults;
  }

  async generateChat() {
    this.chatCalls += 1;
    return {text: '오늘의 산책이 편안했나 봐.'};
  }

  async generateDiary(
    request: unknown,
    options: DiaryGenerationOptions = {repair: false},
  ) {
    this.diaryCalls += 1;
    this.lastDiaryRequest = request;
    this.diaryOptions.push(options);
    if (this.diaryError !== undefined) throw this.diaryError;
    const result = this.#diaryResults[Math.min(
      this.diaryCalls - 1,
      this.#diaryResults.length - 1,
    )];
    if (result instanceof Error) throw result;
    return result;
  }
}

async function withServer(
  handler: RequestListener,
  run: (baseUrl: string) => Promise<void>,
): Promise<void> {
  const server = createHttpServer(handler);
  await new Promise<void>((resolve, reject) => {
    server.once('error', reject);
    server.listen(0, '127.0.0.1', resolve);
  });
  const address = server.address() as AddressInfo;
  try {
    await run(`http://127.0.0.1:${address.port}`);
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => (error === undefined ? resolve() : reject(error)));
    });
  }
}

async function postJson(
  baseUrl: string,
  path: string,
  body: unknown,
  headers: Readonly<Record<string, string>> = {},
) {
  const response = await fetch(`${baseUrl}${path}`, {
    method: 'POST',
    headers: {'content-type': 'application/json', ...headers},
    body: JSON.stringify(body),
  });
  return {
    status: response.status,
    headers: response.headers,
    body: (await response.json()) as unknown,
  };
}
