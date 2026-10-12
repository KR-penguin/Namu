import type {
  AuthAttestationVerifier,
  AuthDecision,
} from './ports.js';

export class DenyAllAuthAttestationVerifier
  implements AuthAttestationVerifier
{
  async verify(_input: {
    readonly authorization: string | undefined;
    readonly attestation: string | undefined;
  }): Promise<AuthDecision> {
    return {ok: false, reason: 'unauthorized'};
  }
}

/**
 * Local-only bypass for exercising the HTTP contract without an identity
 * provider. Runtime configuration prevents this adapter on Cloud Run and in
 * production. It is not an authentication mechanism.
 */
export class DevelopmentAuthAttestationVerifier
  implements AuthAttestationVerifier
{
  async verify(input: {
    readonly authorization: string | undefined;
    readonly attestation: string | undefined;
  }): Promise<AuthDecision> {
    const match = /^Bearer ([^\s]{1,256})$/.exec(input.authorization ?? '');
    if (match?.[1] === undefined) {
      return {ok: false, reason: 'unauthorized'};
    }
    if (input.attestation !== 'development-bypass') {
      return {ok: false, reason: 'attestation'};
    }
    return {ok: true, principalId: match[1]};
  }
}
