import assert from 'node:assert/strict';
import test from 'node:test';

import {
  chatReplyResponseSchema,
  chatRequestSchema,
  diaryOutputSchema,
  diaryRequestSchema,
  parseAllowedDiaryOutput,
} from '../src/contracts.js';
import {
  validChatRequest,
  validDiaryOutput,
  validDiaryRequest,
} from './fixtures.js';

test('chat v2 request and v1 response schemas reject extra fields', () => {
  const request = validChatRequest();
  const response = {
    schemaVersion: 1,
    messageId: 'assistant-1',
    text: '오늘의 산책이 편안했나 봐.',
    createdAtUtc: '2026-10-04T08:01:00.000Z',
  };

  assert.deepEqual(chatRequestSchema.parse(request), request);
  assert.deepEqual(chatReplyResponseSchema.parse(response), response);
  assert.throws(() => chatRequestSchema.parse({...request, prompt: 'override'}));
  assert.throws(() =>
    chatReplyResponseSchema.parse({...response, internalPrompt: 'secret'}),
  );
});

test('request locale accepts only the five product locales', () => {
  const locales = ['ko', 'en', 'ja', 'zh-Hans', 'es'] as const;

  for (const responseLocale of locales) {
    assert.equal(
      chatRequestSchema.parse({...validChatRequest(), responseLocale})
        .responseLocale,
      responseLocale,
    );
    assert.equal(
      diaryRequestSchema.parse({...validDiaryRequest(), responseLocale})
        .responseLocale,
      responseLocale,
    );
  }

  assert.throws(() =>
    chatRequestSchema.parse({...validChatRequest(), responseLocale: 'fr'}),
  );
  assert.throws(() =>
    diaryRequestSchema.parse({...validDiaryRequest(), responseLocale: 'ko-KR'}),
  );
});

test('chat request requires text or an opaque photo reference', () => {
  assert.throws(() =>
    chatRequestSchema.parse({
      ...validChatRequest(),
      text: null,
      photoAssetId: null,
    }),
  );
});

test('chat context is exact, ordered, and contains only active-memory data', () => {
  const request = validChatRequest();

  assert.throws(() =>
    chatRequestSchema.parse({
      ...request,
      recentMessages: [
        {...request.recentMessages[0], localPath: '/private/message.json'},
      ],
    }),
  );
  assert.throws(() =>
    chatRequestSchema.parse({
      ...request,
      activeMemories: [
        {...request.activeMemories[0], status: 'candidate'},
      ],
    }),
  );
  assert.throws(() =>
    chatRequestSchema.parse({
      ...request,
      recentMessages: [
        {
          ...request.recentMessages[0],
          id: request.messageId,
        },
      ],
    }),
  );
});

test('diary v2 request requires exact sorted message data only', () => {
  const request = validDiaryRequest();

  assert.deepEqual(diaryRequestSchema.parse(request), request);
  assert.throws(() =>
    diaryRequestSchema.parse({
      ...request,
      messages: [...request.messages].reverse(),
    }),
  );
  assert.throws(() =>
    diaryRequestSchema.parse({
      ...request,
      messages: [
        {...request.messages[0], localPath: '/private/photo.jpg'},
        request.messages[1],
      ],
    }),
  );
});

test('diary weather provenance controls its nullable fields', () => {
  const request = validDiaryRequest();

  assert.throws(() =>
    diaryRequestSchema.parse({
      ...request,
      weather: {
        provenance: 'noWeather',
        condition: '맑음',
        temperatureCelsius: null,
        providerId: null,
        observedAtUtc: null,
      },
    }),
  );
});

test('diary output is exact and restricted to supplied photo/source ids', () => {
  const output = validDiaryOutput();

  assert.deepEqual(diaryOutputSchema.parse(output), output);
  assert.deepEqual(
    parseAllowedDiaryOutput(output, {
      photoAssetIds: new Set(['photo-1']),
      sourceMessageIds: new Set(['message-1', 'message-2']),
    }),
    output,
  );
  assert.throws(() =>
    parseAllowedDiaryOutput(
      {
        ...output,
        blocks: [{type: 'photo', photoAssetId: 'unknown-photo'}],
      },
      {
        photoAssetIds: new Set(['photo-1']),
        sourceMessageIds: new Set(['message-1', 'message-2']),
      },
    ),
  );
  assert.throws(() =>
    parseAllowedDiaryOutput(
      {
        ...output,
        memoryCandidates: [
          {fact: '사용자는 산책을 좋아한다.', sourceMessageIds: ['unknown']},
        ],
      },
      {
        photoAssetIds: new Set(['photo-1']),
        sourceMessageIds: new Set(['message-1', 'message-2']),
      },
    ),
  );
});
