export interface RuntimeConfig {
  readonly port: number;
  readonly authMode: 'deny' | 'development';
  readonly bodyLimitBytes: number;
  readonly quota: {
    readonly maxRequests: number;
    readonly windowMs: number;
  };
  readonly idempotency: {
    readonly ttlMs: number;
    readonly maxEntries: number;
  };
  readonly vertex: {
    readonly project: string;
    readonly location: string;
    readonly model: string;
    readonly apiVersion: 'v1';
    readonly timeoutMs: number;
    readonly chatMaxOutputTokens: number;
    readonly diaryMaxOutputTokens: number;
  };
}

export function loadRuntimeConfig(
  env: Readonly<Record<string, string | undefined>>,
): RuntimeConfig {
  const requiredNames = [
    'GOOGLE_CLOUD_PROJECT',
    'GOOGLE_CLOUD_LOCATION',
    'NAMU_GEMINI_MODEL',
  ] as const;
  const missing = requiredNames.filter((name) => !nonBlank(env[name]));
  if (missing.length > 0) {
    throw new Error(`Missing required environment: ${missing.join(', ')}`);
  }

  const authModeValue = env['NAMU_AUTH_MODE'] ?? 'deny';
  if (authModeValue !== 'deny' && authModeValue !== 'development') {
    throw new Error('NAMU_AUTH_MODE must be deny or development');
  }
  if (
    authModeValue === 'development' &&
    (env['NODE_ENV'] === 'production' || nonBlank(env['K_SERVICE']))
  ) {
    throw new Error(
      'Development authentication bypass is forbidden in production or Cloud Run',
    );
  }

  return {
    port: positiveInteger(env['PORT'], 8080, 'PORT'),
    authMode: authModeValue,
    bodyLimitBytes: positiveInteger(
      env['NAMU_JSON_BODY_LIMIT_BYTES'],
      256 * 1_024,
      'NAMU_JSON_BODY_LIMIT_BYTES',
    ),
    quota: {
      maxRequests: positiveInteger(
        env['NAMU_QUOTA_MAX_REQUESTS'],
        30,
        'NAMU_QUOTA_MAX_REQUESTS',
      ),
      windowMs: positiveInteger(
        env['NAMU_QUOTA_WINDOW_MS'],
        60_000,
        'NAMU_QUOTA_WINDOW_MS',
      ),
    },
    idempotency: {
      ttlMs: positiveInteger(
        env['NAMU_IDEMPOTENCY_TTL_MS'],
        10 * 60_000,
        'NAMU_IDEMPOTENCY_TTL_MS',
      ),
      maxEntries: positiveInteger(
        env['NAMU_IDEMPOTENCY_MAX_ENTRIES'],
        1_000,
        'NAMU_IDEMPOTENCY_MAX_ENTRIES',
      ),
    },
    vertex: {
      project: env['GOOGLE_CLOUD_PROJECT']!.trim(),
      location: env['GOOGLE_CLOUD_LOCATION']!.trim(),
      model: env['NAMU_GEMINI_MODEL']!.trim(),
      apiVersion: 'v1',
      timeoutMs: positiveInteger(
        env['NAMU_VERTEX_TIMEOUT_MS'],
        15_000,
        'NAMU_VERTEX_TIMEOUT_MS',
      ),
      chatMaxOutputTokens: positiveInteger(
        env['NAMU_VERTEX_CHAT_MAX_OUTPUT_TOKENS'],
        512,
        'NAMU_VERTEX_CHAT_MAX_OUTPUT_TOKENS',
      ),
      diaryMaxOutputTokens: positiveInteger(
        env['NAMU_VERTEX_DIARY_MAX_OUTPUT_TOKENS'],
        2_048,
        'NAMU_VERTEX_DIARY_MAX_OUTPUT_TOKENS',
      ),
    },
  };
}

function nonBlank(value: string | undefined): value is string {
  return value !== undefined && value.trim().length > 0;
}

function positiveInteger(
  rawValue: string | undefined,
  fallback: number,
  name: string,
): number {
  if (rawValue === undefined) return fallback;
  if (!/^\d+$/.test(rawValue)) {
    throw new Error(`${name} must be a positive integer`);
  }
  const parsed = Number(rawValue);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return parsed;
}
