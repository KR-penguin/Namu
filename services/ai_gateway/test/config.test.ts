import assert from 'node:assert/strict';
import test from 'node:test';

import {loadRuntimeConfig} from '../src/config.js';

test('runtime config fails fast when Vertex settings are missing', () => {
  assert.throws(
    () => loadRuntimeConfig({NODE_ENV: 'production'}),
    /GOOGLE_CLOUD_PROJECT.*GOOGLE_CLOUD_LOCATION.*NAMU_GEMINI_MODEL/,
  );
});

test('runtime config selects Vertex v1 settings from explicit env values', () => {
  const config = loadRuntimeConfig({
    NODE_ENV: 'production',
    GOOGLE_CLOUD_PROJECT: 'namu-project',
    GOOGLE_CLOUD_LOCATION: 'asia-northeast3',
    NAMU_GEMINI_MODEL: 'gemini-2.5-flash',
    PORT: '9090',
  });

  assert.equal(config.vertex.project, 'namu-project');
  assert.equal(config.vertex.location, 'asia-northeast3');
  assert.equal(config.vertex.model, 'gemini-2.5-flash');
  assert.equal(config.vertex.apiVersion, 'v1');
  assert.equal(config.vertex.timeoutMs, 15_000);
  assert.equal(config.vertex.chatMaxOutputTokens, 512);
  assert.equal(config.vertex.diaryMaxOutputTokens, 2_048);
  assert.equal(config.port, 9090);
  assert.equal(config.authMode, 'deny');
});

test('runtime config accepts explicit bounded Vertex generation budgets', () => {
  const config = loadRuntimeConfig({
    GOOGLE_CLOUD_PROJECT: 'namu-project',
    GOOGLE_CLOUD_LOCATION: 'asia-northeast3',
    NAMU_GEMINI_MODEL: 'gemini-approved',
    NAMU_VERTEX_TIMEOUT_MS: '12000',
    NAMU_VERTEX_CHAT_MAX_OUTPUT_TOKENS: '384',
    NAMU_VERTEX_DIARY_MAX_OUTPUT_TOKENS: '1536',
  });

  assert.equal(config.vertex.timeoutMs, 12_000);
  assert.equal(config.vertex.chatMaxOutputTokens, 384);
  assert.equal(config.vertex.diaryMaxOutputTokens, 1_536);
});

test('development auth bypass is rejected in production and Cloud Run', () => {
  const required = {
    GOOGLE_CLOUD_PROJECT: 'namu-project',
    GOOGLE_CLOUD_LOCATION: 'asia-northeast3',
    NAMU_GEMINI_MODEL: 'gemini-2.5-flash',
    NAMU_AUTH_MODE: 'development',
  };

  assert.throws(() =>
    loadRuntimeConfig({...required, NODE_ENV: 'production'}),
  );
  assert.throws(() =>
    loadRuntimeConfig({...required, NODE_ENV: 'development', K_SERVICE: 'api'}),
  );
  assert.equal(
    loadRuntimeConfig({...required, NODE_ENV: 'development'}).authMode,
    'development',
  );
});
