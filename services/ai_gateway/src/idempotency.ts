import type {IdempotencyStore} from './ports.js';

export class IdempotencyConflictError extends Error {
  constructor() {
    super('The idempotency key was already used for another request.');
    this.name = 'IdempotencyConflictError';
  }
}

export class IdempotencyCapacityError extends Error {
  constructor() {
    super('The in-memory idempotency cache is at capacity.');
    this.name = 'IdempotencyCapacityError';
  }
}

interface CacheEntry {
  readonly fingerprint: string;
  readonly promise: Promise<unknown>;
  settled: boolean;
  expiresAt: number;
}

export class InMemoryIdempotencyStore implements IdempotencyStore {
  readonly #entries = new Map<string, CacheEntry>();
  readonly #ttlMs: number;
  readonly #maxEntries: number;
  readonly #now: () => number;

  constructor(options: {
    readonly ttlMs: number;
    readonly maxEntries: number;
    readonly now?: () => number;
  }) {
    if (options.ttlMs <= 0 || options.maxEntries <= 0) {
      throw new RangeError('idempotency limits must be positive');
    }
    this.#ttlMs = options.ttlMs;
    this.#maxEntries = options.maxEntries;
    this.#now = options.now ?? Date.now;
  }

  async execute<T>(
    key: string,
    fingerprint: string,
    action: () => Promise<T>,
  ): Promise<{
    readonly disposition: 'created' | 'replayed';
    readonly value: T;
  }> {
    this.#prune();
    const existing = this.#entries.get(key);
    if (existing !== undefined) {
      if (existing.fingerprint !== fingerprint) {
        throw new IdempotencyConflictError();
      }
      return {
        disposition: 'replayed',
        value: (await existing.promise) as T,
      };
    }

    this.#makeRoom();
    const entry: CacheEntry = {
      fingerprint,
      promise: Promise.resolve().then(action),
      settled: false,
      expiresAt: this.#now() + this.#ttlMs,
    };
    this.#entries.set(key, entry);

    try {
      const value = (await entry.promise) as T;
      entry.settled = true;
      entry.expiresAt = this.#now() + this.#ttlMs;
      return {disposition: 'created', value};
    } catch (error) {
      if (this.#entries.get(key) === entry) this.#entries.delete(key);
      throw error;
    }
  }

  #prune(): void {
    const now = this.#now();
    for (const [key, entry] of this.#entries) {
      if (entry.settled && entry.expiresAt <= now) this.#entries.delete(key);
    }
  }

  #makeRoom(): void {
    if (this.#entries.size < this.#maxEntries) return;
    for (const [key, entry] of this.#entries) {
      if (entry.settled) {
        this.#entries.delete(key);
        return;
      }
    }
    throw new IdempotencyCapacityError();
  }
}
