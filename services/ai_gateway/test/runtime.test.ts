import assert from 'node:assert/strict';
import test from 'node:test';

import {
  DenyAllAuthAttestationVerifier,
  DevelopmentAuthAttestationVerifier,
} from '../src/auth.js';
import {JsonConsoleLogger} from '../src/logger.js';
import {createRuntimeAuthVerifier} from '../src/runtime.js';
import type {SafeRequestLog} from '../src/ports.js';

test('runtime authentication is deny-all unless local development is explicit', () => {
  assert.ok(
    createRuntimeAuthVerifier('deny') instanceof
      DenyAllAuthAttestationVerifier,
  );
  assert.ok(
    createRuntimeAuthVerifier('development') instanceof
      DevelopmentAuthAttestationVerifier,
  );
});

test('JSON logger projects only allowlisted request metadata', () => {
  const lines: string[] = [];
  const logger = new JsonConsoleLogger((line) => lines.push(line));
  const unsafeRuntimeValue = {
    event: 'request_complete',
    method: 'POST',
    route: '/v1/chat/reply',
    status: 200,
    latencyMs: 12,
    requestId: 'request-1',
    operation: 'chat',
    idempotency: 'created',
    body: 'private diary text',
    authorization: 'Bearer private-token',
    bodyHash: 'must-not-log-hashes',
  } as unknown as SafeRequestLog;

  logger.write(unsafeRuntimeValue);

  assert.equal(lines.length, 1);
  assert.deepEqual(JSON.parse(lines[0]!), {
    event: 'request_complete',
    method: 'POST',
    route: '/v1/chat/reply',
    status: 200,
    latencyMs: 12,
    requestId: 'request-1',
    operation: 'chat',
    idempotency: 'created',
  });
  assert.doesNotMatch(lines[0]!, /private diary|private-token|bodyHash/);
});
