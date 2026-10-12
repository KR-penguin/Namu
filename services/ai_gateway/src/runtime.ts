import type {GatewayDependencies} from './app.js';
import {
  DenyAllAuthAttestationVerifier,
  DevelopmentAuthAttestationVerifier,
} from './auth.js';
import type {RuntimeConfig} from './config.js';
import {InMemoryIdempotencyStore} from './idempotency.js';
import {JsonConsoleLogger} from './logger.js';
import type {AuthAttestationVerifier} from './ports.js';
import {InMemoryQuotaLimiter} from './quota.js';
import {VertexGeminiModel} from './vertex_model.js';

export function createRuntimeAuthVerifier(
  mode: RuntimeConfig['authMode'],
): AuthAttestationVerifier {
  return mode === 'development'
    ? new DevelopmentAuthAttestationVerifier()
    : new DenyAllAuthAttestationVerifier();
}

export function createRuntimeDependencies(
  config: RuntimeConfig,
): GatewayDependencies {
  return {
    auth: createRuntimeAuthVerifier(config.authMode),
    quota: new InMemoryQuotaLimiter(config.quota),
    idempotency: new InMemoryIdempotencyStore(config.idempotency),
    model: new VertexGeminiModel(config.vertex),
    logger: new JsonConsoleLogger(),
    bodyLimitBytes: config.bodyLimitBytes,
  };
}
