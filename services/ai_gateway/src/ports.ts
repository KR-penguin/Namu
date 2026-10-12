import type {ChatRequest, DiaryOutput, DiaryRequest} from './contracts.js';

export type GatewayOperation = 'chat' | 'diary';

export type AuthDecision =
  | {readonly ok: true; readonly principalId: string}
  | {readonly ok: false; readonly reason: 'unauthorized' | 'attestation'};

export interface AuthAttestationVerifier {
  verify(input: {
    readonly authorization: string | undefined;
    readonly attestation: string | undefined;
  }): Promise<AuthDecision>;
}

export type QuotaDecision =
  | {readonly allowed: true}
  | {readonly allowed: false; readonly retryAfterSeconds: number};

export interface QuotaLimiter {
  consume(
    principalId: string,
    operation: GatewayOperation,
  ): Promise<QuotaDecision>;
}

export interface VertexModelPort {
  generateChat(request: ChatRequest): Promise<{readonly text: string}>;
  generateDiary(
    request: DiaryRequest,
    options?: DiaryGenerationOptions,
  ): Promise<unknown>;
}

export interface DiaryGenerationOptions {
  readonly repair: boolean;
}

abstract class RedactedModelError extends Error {
  protected constructor(name: string, message: string) {
    super(message);
    this.name = name;
  }
}

export class ModelSafetyBlockedError extends RedactedModelError {
  constructor() {
    super('ModelSafetyBlockedError', 'The model blocked this request for safety.');
  }
}

export class ModelTimeoutError extends RedactedModelError {
  constructor() {
    super('ModelTimeoutError', 'The model request timed out.');
  }
}

export class ModelTruncatedError extends RedactedModelError {
  constructor() {
    super('ModelTruncatedError', 'The model output was truncated.');
  }
}

export class ModelFinishReasonError extends RedactedModelError {
  constructor() {
    super(
      'ModelFinishReasonError',
      'The model stopped with an unsupported finish reason.',
    );
  }
}

export class ModelInvalidResponseError extends RedactedModelError {
  constructor() {
    super('ModelInvalidResponseError', 'The model returned an invalid response.');
  }
}

export class ModelUnavailableError extends RedactedModelError {
  constructor() {
    super('ModelUnavailableError', 'The model is unavailable.');
  }
}

export type IdempotencyDisposition = 'created' | 'replayed';

export interface IdempotencyStore {
  execute<T>(
    key: string,
    fingerprint: string,
    action: () => Promise<T>,
  ): Promise<{readonly disposition: IdempotencyDisposition; readonly value: T}>;
}

export interface SafeRequestLog {
  readonly event: 'request_complete';
  readonly method: string;
  readonly route: string;
  readonly status: number;
  readonly latencyMs: number;
  readonly requestId?: string;
  readonly operation?: GatewayOperation;
  readonly idempotency?: IdempotencyDisposition;
}

export interface SafeLogger {
  write(entry: SafeRequestLog): void;
}

export interface GatewayResponseByOperation {
  readonly chat: {
    readonly schemaVersion: 1;
    readonly messageId: string;
    readonly text: string;
    readonly createdAtUtc: string;
  };
  readonly diary: DiaryOutput;
}
