import assert from 'node:assert/strict';
import test from 'node:test';

import {
  BlockedReason,
  FinishReason,
  type GenerateContentResponse,
} from '@google/genai';

import {
  ModelFinishReasonError,
  ModelInvalidResponseError,
  ModelSafetyBlockedError,
  ModelTimeoutError,
  ModelTruncatedError,
  ModelUnavailableError,
} from '../src/ports.js';
import {
  buildChatGenerationParameters,
  buildDiaryGenerationParameters,
  VertexGeminiModel,
} from '../src/vertex_model.js';
import {validChatRequest, validDiaryOutput, validDiaryRequest} from './fixtures.js';

const modelConfig = {
  project: 'project',
  location: 'location',
  model: 'model',
  apiVersion: 'v1' as const,
  timeoutMs: 15_000,
  chatMaxOutputTokens: 512,
  diaryMaxOutputTokens: 2_048,
};

test('generation parameters apply one candidate, per-operation budgets, and safety settings', () => {
  const chat = buildChatGenerationParameters(
    'model',
    validChatRequest(),
    15_000,
    512,
  );
  const diary = buildDiaryGenerationParameters(
    'model',
    validDiaryRequest(),
    15_000,
    2_048,
  );

  assert.equal(chat.config?.candidateCount, 1);
  assert.equal(chat.config?.maxOutputTokens, 512);
  assert.equal(diary.config?.candidateCount, 1);
  assert.equal(diary.config?.maxOutputTokens, 2_048);
  assert.equal(chat.config?.safetySettings?.length, 4);
  assert.deepEqual(diary.config?.safetySettings, chat.config?.safetySettings);
});

test('generation prompts require the validated response locale and keep it untrusted', () => {
  const chat = buildChatGenerationParameters(
    'model',
    {...validChatRequest(), responseLocale: 'ja'},
    15_000,
  );
  const diary = buildDiaryGenerationParameters(
    'model',
    {...validDiaryRequest(), responseLocale: 'es'},
    15_000,
  );

  const chatInstruction = String(chat.config?.systemInstruction);
  const diaryInstruction = String(diary.config?.systemInstruction);
  assert.match(chatInstruction, /responseLocale.*untrusted/i);
  assert.match(chatInstruction, /locale tag ja/i);
  assert.match(diaryInstruction, /responseLocale.*untrusted/i);
  assert.match(diaryInstruction, /locale tag es/i);
  assert.match(JSON.stringify(chat.contents), /chat_reply_v2/);
  assert.match(JSON.stringify(diary.contents), /diary_generation_v2/);
});

test('diary repair attempt is explicit and does not include rejected output', () => {
  const parameters = buildDiaryGenerationParameters(
    'model',
    validDiaryRequest(),
    15_000,
    2_048,
    {repair: true},
  );
  const serialized = JSON.stringify(parameters);

  assert.match(String(parameters.config?.systemInstruction), /repair attempt/i);
  assert.doesNotMatch(serialized, /rejected output|previous output/i);
});

test('Vertex response safety and finish reasons become typed redacted failures', async () => {
  const cases = [
    {
      response: responseOf({blockReason: BlockedReason.SAFETY}),
      error: ModelSafetyBlockedError,
    },
    {
      response: responseOf({finishReason: FinishReason.SAFETY}),
      error: ModelSafetyBlockedError,
    },
    {
      response: responseOf({finishReason: FinishReason.MAX_TOKENS}),
      error: ModelTruncatedError,
    },
    {
      response: responseOf({finishReason: FinishReason.OTHER}),
      error: ModelFinishReasonError,
    },
  ] as const;

  for (const current of cases) {
    const model = new VertexGeminiModel(modelConfig, async () => current.response);
    await assert.rejects(model.generateDiary(validDiaryRequest()), current.error);
  }
});

test('Vertex malformed structured output is invalid rather than unavailable', async () => {
  const model = new VertexGeminiModel(
    modelConfig,
    async () => responseOf({text: '{not-json'}),
  );

  await assert.rejects(
    model.generateDiary(validDiaryRequest()),
    ModelInvalidResponseError,
  );
});

test('Vertex provider timeout is distinguished from an unavailable dependency', async () => {
  const timeout = new Error('private provider detail');
  timeout.name = 'AbortError';
  const timeoutModel = new VertexGeminiModel(modelConfig, async () => {
    throw timeout;
  });
  const unavailableModel = new VertexGeminiModel(modelConfig, async () => {
    throw new Error('private response body');
  });

  await assert.rejects(
    timeoutModel.generateChat(validChatRequest()),
    ModelTimeoutError,
  );
  await assert.rejects(
    unavailableModel.generateChat(validChatRequest()),
    ModelUnavailableError,
  );
});

function responseOf(options: {
  readonly text?: string;
  readonly finishReason?: FinishReason;
  readonly blockReason?: BlockedReason;
}): GenerateContentResponse {
  return {
    ...(options.blockReason === undefined
      ? {}
      : {promptFeedback: {blockReason: options.blockReason}}),
    candidates: [
      {
        finishReason: options.finishReason ?? FinishReason.STOP,
        content: {role: 'model', parts: [{text: options.text ?? JSON.stringify(validDiaryOutput())}]},
      },
    ],
    get text() {
      return options.text ?? JSON.stringify(validDiaryOutput());
    },
  } as GenerateContentResponse;
}
