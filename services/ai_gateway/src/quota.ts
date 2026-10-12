import type {
  GatewayOperation,
  QuotaDecision,
  QuotaLimiter,
} from './ports.js';

interface Bucket {
  count: number;
  windowStartedAt: number;
}

export class InMemoryQuotaLimiter implements QuotaLimiter {
  readonly #buckets = new Map<string, Bucket>();
  readonly #maxRequests: number;
  readonly #windowMs: number;
  readonly #now: () => number;

  constructor(options: {
    readonly maxRequests: number;
    readonly windowMs: number;
    readonly now?: () => number;
  }) {
    if (options.maxRequests <= 0 || options.windowMs <= 0) {
      throw new RangeError('quota limits must be positive');
    }
    this.#maxRequests = options.maxRequests;
    this.#windowMs = options.windowMs;
    this.#now = options.now ?? Date.now;
  }

  async consume(
    principalId: string,
    operation: GatewayOperation,
  ): Promise<QuotaDecision> {
    const now = this.#now();
    const key = `${operation}\u0000${principalId}`;
    let bucket = this.#buckets.get(key);
    if (bucket === undefined || now - bucket.windowStartedAt >= this.#windowMs) {
      bucket = {count: 0, windowStartedAt: now};
      this.#buckets.set(key, bucket);
    }

    if (bucket.count >= this.#maxRequests) {
      return {
        allowed: false,
        retryAfterSeconds: Math.max(
          1,
          Math.ceil(
            (bucket.windowStartedAt + this.#windowMs - now) / 1_000,
          ),
        ),
      };
    }

    bucket.count += 1;
    this.#prune(now);
    return {allowed: true};
  }

  #prune(now: number): void {
    for (const [key, bucket] of this.#buckets) {
      if (now - bucket.windowStartedAt >= this.#windowMs) {
        this.#buckets.delete(key);
      }
    }
  }
}
