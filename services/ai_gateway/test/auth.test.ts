import assert from 'node:assert/strict';
import test from 'node:test';

import {
  DenyAllAuthAttestationVerifier,
  DevelopmentAuthAttestationVerifier,
} from '../src/auth.js';

test('deny-all authentication fails closed', async () => {
  const verifier = new DenyAllAuthAttestationVerifier();

  assert.deepEqual(
    await verifier.verify({
      authorization: 'Bearer token',
      attestation: 'attestation',
    }),
    {ok: false, reason: 'unauthorized'},
  );
});

test('development verifier requires both explicit headers', async () => {
  const verifier = new DevelopmentAuthAttestationVerifier();

  assert.deepEqual(
    await verifier.verify({
      authorization: 'Bearer local-user',
      attestation: 'development-bypass',
    }),
    {ok: true, principalId: 'local-user'},
  );
  assert.deepEqual(
    await verifier.verify({
      authorization: undefined,
      attestation: 'development-bypass',
    }),
    {ok: false, reason: 'unauthorized'},
  );
  assert.deepEqual(
    await verifier.verify({
      authorization: 'Bearer local-user',
      attestation: undefined,
    }),
    {ok: false, reason: 'attestation'},
  );
  assert.deepEqual(
    await verifier.verify({
      authorization: 'Bearer local-user',
      attestation: 'real-looking-but-not-dev-marker',
    }),
    {ok: false, reason: 'attestation'},
  );
});
