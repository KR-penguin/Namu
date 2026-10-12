import {createHash} from 'node:crypto';
import type {
  IncomingHttpHeaders,
  IncomingMessage,
  RequestListener,
  ServerResponse,
} from 'node:http';
import {TextDecoder} from 'node:util';

import {
  chatReplyResponseSchema,
  chatRequestSchema,
  diaryRequestSchema,
  parseAllowedDiaryOutput,
  type ChatReplyResponse,
  type ChatRequest,
  type DiaryOutput,
  type DiaryRequest,
} from './contracts.js';
import {
  IdempotencyCapacityError,
  IdempotencyConflictError,
} from './idempotency.js';
import type {
  AuthAttestationVerifier,
  GatewayOperation,
  IdempotencyDisposition,
  IdempotencyStore,
  QuotaLimiter,
  SafeLogger,
  SafeRequestLog,
  VertexModelPort,
} from './ports.js';
import {
  ModelFinishReasonError,
  ModelInvalidResponseError,
  ModelSafetyBlockedError,
  ModelTimeoutError,
  ModelTruncatedError,
  ModelUnavailableError,
} from './ports.js';

export interface GatewayDependencies {
  readonly auth: AuthAttestationVerifier;
  readonly quota: QuotaLimiter;
  readonly idempotency: IdempotencyStore;
  readonly model: VertexModelPort;
  readonly logger: SafeLogger;
  readonly bodyLimitBytes: number;
  readonly now?: () => number;
  readonly newId?: () => string;
}

type KnownRoute =
  | '/healthz'
  | '/v1/chat/reply'
  | '/v1/diary/generate'
  | 'unmatched';

export function createGatewayHandler(
  dependencies: GatewayDependencies,
): RequestListener {
  if (dependencies.bodyLimitBytes <= 0) {
    throw new RangeError('bodyLimitBytes must be positive');
  }
  const now = dependencies.now ?? Date.now;
  const newId = dependencies.newId ?? cryptoRandomId;

  return (request, response) => {
    void handleRequest(request, response, dependencies, now, newId);
  };
}

async function handleRequest(
  request: IncomingMessage,
  response: ServerResponse,
  dependencies: GatewayDependencies,
  now: () => number,
  newId: () => string,
): Promise<void> {
  const startedAt = now();
  let route: KnownRoute = 'unmatched';
  let requestId: string | undefined;
  let operation: GatewayOperation | undefined;
  let idempotency: IdempotencyDisposition | undefined;

  try {
    route = resolveKnownRoute(request.url);
    if (route === '/healthz') {
      if (request.method !== 'GET') {
        response.setHeader('Allow', 'GET');
        sendError(response, 405, 'method_not_allowed');
        return;
      }
      sendJson(response, 200, {status: 'ok'});
      return;
    }
    if (route === 'unmatched') {
      sendError(response, 404, 'not_found');
      return;
    }
    if (request.method !== 'POST') {
      response.setHeader('Allow', 'POST');
      sendError(response, 405, 'method_not_allowed');
      return;
    }

    const authDecision = await verifyRequest(dependencies.auth, request.headers);
    if (!authDecision.ok) {
      request.resume();
      sendError(
        response,
        authDecision.reason === 'unauthorized' ? 401 : 403,
        authDecision.reason === 'unauthorized'
          ? 'unauthorized'
          : 'invalid_attestation',
      );
      return;
    }

    requireJsonContentType(request.headers);
    const rawJson = await readJsonBody(request, dependencies.bodyLimitBytes);
    const idempotencyKey = singleHeader(
      request.headers['idempotency-key'],
    );

    if (route === '/v1/chat/reply') {
      operation = 'chat';
      const parsed = chatRequestSchema.safeParse(rawJson);
      if (!parsed.success) throw new RequestValidationError();
      requestId = parsed.data.requestId;
      requireMatchingIdempotencyKey(idempotencyKey, requestId);
      const result = await executeChat({
        request: parsed.data,
        principalId: authDecision.principalId,
        idempotencyKey: requestId,
        dependencies,
        now,
        newId,
      });
      idempotency = result.disposition;
      sendJson(response, 200, result.value);
      return;
    }

    operation = 'diary';
    const parsed = diaryRequestSchema.safeParse(rawJson);
    if (!parsed.success) throw new RequestValidationError();
    requestId = parsed.data.generationId;
    requireMatchingIdempotencyKey(idempotencyKey, requestId);
    const result = await executeDiary({
      request: parsed.data,
      principalId: authDecision.principalId,
      idempotencyKey: requestId,
      dependencies,
    });
    idempotency = result.disposition;
    sendJson(response, 200, result.value);
  } catch (error) {
    handleError(response, error);
  } finally {
    const entry: SafeRequestLog = {
      event: 'request_complete',
      method: request.method ?? 'UNKNOWN',
      route,
      status: response.statusCode,
      latencyMs: Math.max(0, now() - startedAt),
      ...(requestId === undefined ? {} : {requestId}),
      ...(operation === undefined ? {} : {operation}),
      ...(idempotency === undefined ? {} : {idempotency}),
    };
    try {
      dependencies.logger.write(entry);
    } catch {
      // Logging must never expose data by turning a successful request into an
      // error response or by forwarding the logger's exception text.
    }
  }
}

async function executeChat(input: {
  readonly request: ChatRequest;
  readonly principalId: string;
  readonly idempotencyKey: string;
  readonly dependencies: GatewayDependencies;
  readonly now: () => number;
  readonly newId: () => string;
}) {
  const fingerprint = chatRequestFingerprint(input.request);
  return input.dependencies.idempotency.execute(
    idempotencyNamespace(input.principalId, 'chat', input.idempotencyKey),
    fingerprint,
    async (): Promise<ChatReplyResponse> => {
      await requireQuota(input.dependencies.quota, input.principalId, 'chat');
      let modelResult: {readonly text: string};
      try {
        modelResult = await input.dependencies.model.generateChat(input.request);
      } catch (error) {
        throw normalizeModelError(error);
      }
      const parsed = chatReplyResponseSchema.safeParse({
        schemaVersion: 1,
        messageId: input.newId(),
        text: modelResult.text,
        createdAtUtc: new Date(input.now()).toISOString(),
      });
      if (!parsed.success) throw new ModelInvalidResponseError();
      return parsed.data;
    },
  );
}

async function executeDiary(input: {
  readonly request: DiaryRequest;
  readonly principalId: string;
  readonly idempotencyKey: string;
  readonly dependencies: GatewayDependencies;
}) {
  const fingerprint = requestFingerprint(input.request);
  return input.dependencies.idempotency.execute(
    idempotencyNamespace(input.principalId, 'diary', input.idempotencyKey),
    fingerprint,
    async (): Promise<DiaryOutput> => {
      await requireQuota(input.dependencies.quota, input.principalId, 'diary');
      try {
        return await generateAndValidateDiary(input, false);
      } catch (error) {
        if (!(error instanceof ModelInvalidResponseError)) throw error;
        return generateAndValidateDiary(input, true);
      }
    },
  );
}

async function generateAndValidateDiary(
  input: {
    readonly request: DiaryRequest;
    readonly dependencies: GatewayDependencies;
  },
  repair: boolean,
): Promise<DiaryOutput> {
  let modelResult: unknown;
  try {
    modelResult = await input.dependencies.model.generateDiary(input.request, {
      repair,
    });
  } catch (error) {
    throw normalizeModelError(error);
  }

  try {
    return parseAllowedDiaryOutput(modelResult, {
      photoAssetIds: new Set(
        input.request.messages.flatMap((message) =>
          message.photoAssetId === null ? [] : [message.photoAssetId],
        ),
      ),
      sourceMessageIds: new Set(
        input.request.messages.map((message) => message.id),
      ),
    });
  } catch {
    throw new ModelInvalidResponseError();
  }
}

function normalizeModelError(error: unknown): Error {
  if (
    error instanceof ModelSafetyBlockedError ||
    error instanceof ModelTimeoutError ||
    error instanceof ModelTruncatedError ||
    error instanceof ModelFinishReasonError ||
    error instanceof ModelInvalidResponseError ||
    error instanceof ModelUnavailableError
  ) {
    return error;
  }
  return new ModelUnavailableError();
}

async function verifyRequest(
  verifier: AuthAttestationVerifier,
  headers: IncomingHttpHeaders,
) {
  try {
    return await verifier.verify({
      authorization: singleHeader(headers.authorization),
      attestation: singleHeader(headers['x-app-attestation']),
    });
  } catch {
    throw new DependencyUnavailableError('auth_unavailable');
  }
}

async function requireQuota(
  quota: QuotaLimiter,
  principalId: string,
  operation: GatewayOperation,
): Promise<void> {
  try {
    const result = await quota.consume(principalId, operation);
    if (!result.allowed) throw new RateLimitError(result.retryAfterSeconds);
  } catch (error) {
    if (error instanceof RateLimitError) throw error;
    throw new DependencyUnavailableError('quota_unavailable');
  }
}

function requireMatchingIdempotencyKey(
  headerValue: string | undefined,
  bodyIdentity: string,
): void {
  if (headerValue === undefined || headerValue !== bodyIdentity) {
    throw new IdempotencyHeaderError();
  }
}

function requestFingerprint(value: object): string {
  return createHash('sha256').update(JSON.stringify(value)).digest('base64url');
}

function chatRequestFingerprint(request: ChatRequest): string {
  // Context is intentionally excluded: a client may retry after the user has
  // changed persona or approved a memory. The immutable local message remains
  // the idempotent operation identity and still detects content/key reuse.
  return requestFingerprint({
    schemaVersion: request.schemaVersion,
    responseLocale: request.responseLocale,
    requestId: request.requestId,
    messageId: request.messageId,
    text: request.text,
    photoAssetId: request.photoAssetId,
    createdAtUtc: request.createdAtUtc,
    dayKey: request.dayKey,
  });
}

function idempotencyNamespace(
  principalId: string,
  operation: GatewayOperation,
  idempotencyKey: string,
): string {
  return JSON.stringify([principalId, operation, idempotencyKey]);
}

function resolveKnownRoute(rawUrl: string | undefined): KnownRoute {
  if (rawUrl === undefined) return 'unmatched';
  try {
    const pathname = new URL(rawUrl, 'http://gateway.invalid').pathname;
    return pathname === '/healthz' ||
      pathname === '/v1/chat/reply' ||
      pathname === '/v1/diary/generate'
      ? pathname
      : 'unmatched';
  } catch {
    return 'unmatched';
  }
}

function requireJsonContentType(headers: IncomingHttpHeaders): void {
  const contentType = singleHeader(headers['content-type']);
  if (contentType?.split(';', 1)[0]?.trim().toLowerCase() !== 'application/json') {
    throw new UnsupportedMediaTypeError();
  }
}

async function readJsonBody(
  request: IncomingMessage,
  limitBytes: number,
): Promise<unknown> {
  const rawLength = singleHeader(request.headers['content-length']);
  if (rawLength !== undefined) {
    const length = Number(rawLength);
    if (!Number.isSafeInteger(length) || length < 0) {
      request.resume();
      throw new RequestValidationError();
    }
    if (length > limitBytes) {
      request.resume();
      throw new PayloadTooLargeError();
    }
  }

  const chunks: Buffer[] = [];
  let received = 0;
  try {
    for await (const chunk of request) {
      const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
      received += buffer.length;
      if (received > limitBytes) {
        request.resume();
        throw new PayloadTooLargeError();
      }
      chunks.push(buffer);
    }
  } catch (error) {
    if (error instanceof PayloadTooLargeError) throw error;
    throw new RequestValidationError();
  }

  try {
    const source = new TextDecoder('utf-8', {fatal: true}).decode(
      Buffer.concat(chunks, received),
    );
    return JSON.parse(source) as unknown;
  } catch {
    throw new RequestValidationError();
  }
}

function singleHeader(
  value: string | readonly string[] | undefined,
): string | undefined {
  return typeof value === 'string' ? value : undefined;
}

function handleError(response: ServerResponse, error: unknown): void {
  if (response.headersSent) {
    response.end();
    return;
  }
  if (error instanceof UnsupportedMediaTypeError) {
    sendError(response, 415, 'unsupported_media_type');
  } else if (error instanceof PayloadTooLargeError) {
    sendError(response, 413, 'payload_too_large');
  } else if (error instanceof IdempotencyHeaderError) {
    sendError(response, 400, 'invalid_idempotency_key');
  } else if (error instanceof RequestValidationError) {
    sendError(response, 400, 'invalid_request');
  } else if (error instanceof IdempotencyConflictError) {
    sendError(response, 409, 'idempotency_conflict');
  } else if (error instanceof RateLimitError) {
    response.setHeader('Retry-After', String(error.retryAfterSeconds));
    sendError(response, 429, 'rate_limited');
  } else if (error instanceof ModelSafetyBlockedError) {
    sendError(response, 422, 'safety_blocked');
  } else if (error instanceof ModelTimeoutError) {
    sendError(response, 504, 'model_timeout');
  } else if (error instanceof ModelTruncatedError) {
    sendError(response, 502, 'model_truncated');
  } else if (error instanceof ModelFinishReasonError) {
    sendError(response, 502, 'invalid_model_response');
  } else if (error instanceof ModelInvalidResponseError) {
    sendError(response, 502, 'invalid_model_response');
  } else if (error instanceof ModelUnavailableError) {
    sendError(response, 502, 'model_unavailable');
  } else if (
    error instanceof DependencyUnavailableError ||
    error instanceof IdempotencyCapacityError
  ) {
    sendError(
      response,
      503,
      error instanceof DependencyUnavailableError
        ? error.publicCode
        : 'temporarily_unavailable',
    );
  } else {
    sendError(response, 500, 'internal_error');
  }
}

function sendError(
  response: ServerResponse,
  status: number,
  code: string,
): void {
  sendJson(response, status, {error: {code}});
}

function sendJson(response: ServerResponse, status: number, body: unknown): void {
  response.statusCode = status;
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.end(JSON.stringify(body));
}

function cryptoRandomId(): string {
  return globalThis.crypto.randomUUID();
}

class RequestValidationError extends Error {}
class UnsupportedMediaTypeError extends Error {}
class PayloadTooLargeError extends Error {}
class IdempotencyHeaderError extends Error {}

class RateLimitError extends Error {
  constructor(readonly retryAfterSeconds: number) {
    super('Rate limited.');
  }
}

class DependencyUnavailableError extends Error {
  constructor(readonly publicCode: 'auth_unavailable' | 'quota_unavailable') {
    super('A required dependency is unavailable.');
  }
}
