import assert from 'node:assert/strict';
import test from 'node:test';

import {
  IdempotencyConflictError,
  InMemoryIdempotencyStore,
} from '../src/idempotency.js';
import {InMemoryQuotaLimiter} from '../src/quota.js';

test('idempotency cache replays one in-flight action per principal and key', async () => {
  const store = new InMemoryIdempotencyStore({
    ttlMs: 60_000,
    maxEntries: 10,
    now: () => 1_000,
  });
  let calls = 0;
  let release!: () => void;
  const gate = new Promise<void>((resolve) => {
    release = resolve;
  });
  const action = async () => {
    calls += 1;
    await gate;
    return {text: 'safe response'};
  };

  const first = store.execute('principal:chat:key', 'fingerprint-a', action);
  const replay = store.execute('principal:chat:key', 'fingerprint-a', action);
  release();

  assert.deepEqual(await first, {
    disposition: 'created',
    value: {text: 'safe response'},
  });
  assert.deepEqual(await replay, {
    disposition: 'replayed',
    value: {text: 'safe response'},
  });
  assert.equal(calls, 1);
});

test('idempotency cache rejects the same key with a different body fingerprint', async () => {
  const store = new InMemoryIdempotencyStore({
    ttlMs: 60_000,
    maxEntries: 10,
    now: () => 1_000,
  });

  await store.execute('principal:chat:key', 'fingerprint-a', async () => ({
    text: 'response',
  }));

  await assert.rejects(
    store.execute('principal:chat:key', 'fingerprint-b', async () => ({
      text: 'must not run',
    })),
    IdempotencyConflictError,
  );
});

test('failed actions are not cached', async () => {
  const store = new InMemoryIdempotencyStore({
    ttlMs: 60_000,
    maxEntries: 10,
    now: () => 1_000,
  });
  let attempts = 0;

  await assert.rejects(
    store.execute('principal:chat:key', 'fingerprint-a', async () => {
      attempts += 1;
      throw new Error('model failed');
    }),
  );
  await store.execute('principal:chat:key', 'fingerprint-a', async () => {
    attempts += 1;
    return {text: 'recovered'};
  });

  assert.equal(attempts, 2);
});

test('quota is isolated by principal and operation', async () => {
  let now = 1_000;
  const quota = new InMemoryQuotaLimiter({
    maxRequests: 2,
    windowMs: 60_000,
    now: () => now,
  });

  assert.deepEqual(await quota.consume('alice', 'chat'), {allowed: true});
  assert.deepEqual(await quota.consume('alice', 'chat'), {allowed: true});
  const limited = await quota.consume('alice', 'chat');
  assert.equal(limited.allowed, false);
  assert.equal(limited.retryAfterSeconds, 60);
  assert.deepEqual(await quota.consume('alice', 'diary'), {allowed: true});
  assert.deepEqual(await quota.consume('bob', 'chat'), {allowed: true});

  now += 60_000;
  assert.deepEqual(await quota.consume('alice', 'chat'), {allowed: true});
});
