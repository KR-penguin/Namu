import {z} from 'zod';

const nonBlank = (maximum: number) =>
  z
    .string()
    .min(1)
    .max(maximum)
    .refine((value) => value.trim().length > 0, 'must not be blank');

const localDateSchema = z
  .string()
  .regex(/^\d{4}-\d{2}-\d{2}$/)
  .refine((value) => {
    const parsed = new Date(`${value}T00:00:00.000Z`);
    return !Number.isNaN(parsed.valueOf()) &&
      parsed.toISOString().slice(0, 10) === value;
  }, 'must be a valid calendar date');

const utcInstantSchema = z
  .string()
  .max(40)
  .regex(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z$/)
  .refine((value) => !Number.isNaN(Date.parse(value)), 'must be a UTC instant');

export const responseLocaleSchema = z.enum([
  'ko',
  'en',
  'ja',
  'zh-Hans',
  'es',
]);

export const diaryDayKeySchema = z
  .object({
    labelDate: localDateSchema,
    timeZoneId: nonBlank(128),
    cutoffMinutes: z.literal(0),
    policyVersion: z.literal(1),
  })
  .strict();

const personaSchema = z
  .object({
    id: nonBlank(128),
    name: nonBlank(40),
    avatarSeed: nonBlank(128),
    tone: nonBlank(160),
    customInstructions: z.string().max(1_000),
    reactionLength: z.enum(['concise', 'balanced', 'expressive']),
  })
  .strict();

const contextMessageSchema = z
  .object({
    id: nonBlank(128),
    role: z.enum(['user', 'assistant']),
    text: nonBlank(20_000).nullable(),
    photoAssetId: nonBlank(256).nullable(),
    createdAtUtc: utcInstantSchema,
  })
  .strict()
  .superRefine((value, context) => {
    if (value.text === null && value.photoAssetId === null) {
      context.addIssue({
        code: 'custom',
        message: 'text or photoAssetId is required',
        path: ['text'],
      });
    }
  });

const activeMemorySchema = z
  .object({
    id: nonBlank(128),
    fact: nonBlank(1_000),
    category: z.enum([
      'preference',
      'routine',
      'relationship',
      'place',
      'milestone',
      'other',
    ]),
    updatedAtUtc: utcInstantSchema,
  })
  .strict();

const chatMessagePayloadShape = {
  messageId: nonBlank(128),
  text: nonBlank(20_000).nullable(),
  photoAssetId: nonBlank(256).nullable(),
  createdAtUtc: utcInstantSchema,
};

export const chatRequestSchema = z
  .object({
    schemaVersion: z.literal(2),
    responseLocale: responseLocaleSchema,
    requestId: nonBlank(128),
    ...chatMessagePayloadShape,
    dayKey: diaryDayKeySchema,
    persona: personaSchema,
    recentMessages: z.array(contextMessageSchema).max(30),
    activeMemories: z.array(activeMemorySchema).max(20),
  })
  .strict()
  .superRefine((value, context) => {
    if (value.text === null && value.photoAssetId === null) {
      context.addIssue({
        code: 'custom',
        message: 'text or photoAssetId is required',
        path: ['text'],
      });
    }
    const seenMessageIds = new Set<string>();
    for (let index = 0; index < value.recentMessages.length; index += 1) {
      const message = value.recentMessages[index];
      if (message === undefined) continue;
      if (message.id === value.messageId || !seenMessageIds.add(message.id)) {
        context.addIssue({
          code: 'custom',
          message: 'recent message ids must be unique and exclude the request',
          path: ['recentMessages', index, 'id'],
        });
      }
      if (index === 0) continue;
      const previous = value.recentMessages[index - 1];
      if (previous === undefined) continue;
      const byInstant = Date.parse(previous.createdAtUtc) -
        Date.parse(message.createdAtUtc);
      if (byInstant > 0 || (byInstant === 0 && previous.id > message.id)) {
        context.addIssue({
          code: 'custom',
          message: 'recent messages must be sorted by UTC instant then id',
          path: ['recentMessages', index],
        });
      }
    }

    const seenMemoryIds = new Set<string>();
    for (let index = 0; index < value.activeMemories.length; index += 1) {
      const memory = value.activeMemories[index];
      if (memory === undefined) continue;
      if (!seenMemoryIds.add(memory.id)) {
        context.addIssue({
          code: 'custom',
          message: 'active memory ids must be unique',
          path: ['activeMemories', index, 'id'],
        });
      }
      if (index === 0) continue;
      const previous = value.activeMemories[index - 1];
      if (previous === undefined) continue;
      const byInstant = Date.parse(memory.updatedAtUtc) -
        Date.parse(previous.updatedAtUtc);
      if (byInstant > 0 || (byInstant === 0 && previous.id > memory.id)) {
        context.addIssue({
          code: 'custom',
          message: 'active memories must be sorted by updated UTC then id',
          path: ['activeMemories', index],
        });
      }
    }
  });

export const chatReplyResponseSchema = z
  .object({
    schemaVersion: z.literal(1),
    messageId: nonBlank(128),
    text: nonBlank(20_000),
    createdAtUtc: utcInstantSchema,
  })
  .strict();

const weatherSchema = z.discriminatedUnion('provenance', [
  z
    .object({
      provenance: z.literal('noWeather'),
      condition: z.null(),
      temperatureCelsius: z.null(),
      providerId: z.null(),
      observedAtUtc: z.null(),
    })
    .strict(),
  z
    .object({
      provenance: z.literal('manual'),
      condition: nonBlank(160),
      temperatureCelsius: z.number().finite().min(-100).max(100).nullable(),
      providerId: z.null(),
      observedAtUtc: z.null(),
    })
    .strict(),
  z
    .object({
      provenance: z.literal('provider'),
      condition: nonBlank(160),
      temperatureCelsius: z.number().finite().min(-100).max(100).nullable(),
      providerId: nonBlank(128),
      observedAtUtc: utcInstantSchema,
    })
    .strict(),
]);

const diaryMessageSchema = contextMessageSchema;

export const diaryRequestSchema = z
  .object({
    schemaVersion: z.literal(2),
    responseLocale: responseLocaleSchema,
    generationId: nonBlank(128),
    dayKey: diaryDayKeySchema,
    weather: weatherSchema,
    persona: personaSchema,
    messages: z.array(diaryMessageSchema).max(500),
  })
  .strict()
  .superRefine((value, context) => {
    const seenIds = new Set<string>();
    for (let index = 0; index < value.messages.length; index += 1) {
      const message = value.messages[index];
      if (message === undefined) continue;
      if (!seenIds.add(message.id)) {
        context.addIssue({
          code: 'custom',
          message: 'message ids must be unique',
          path: ['messages', index, 'id'],
        });
      }
      if (index === 0) continue;
      const previous = value.messages[index - 1];
      if (previous === undefined) continue;
      const byInstant = Date.parse(previous.createdAtUtc) -
        Date.parse(message.createdAtUtc);
      if (byInstant > 0 || (byInstant === 0 && previous.id > message.id)) {
        context.addIssue({
          code: 'custom',
          message: 'messages must be sorted by UTC instant then id',
          path: ['messages', index],
        });
      }
    }
  });

const diaryBlockSchema = z.discriminatedUnion('type', [
  z.object({type: z.literal('text'), text: nonBlank(20_000)}).strict(),
  z
    .object({type: z.literal('photo'), photoAssetId: nonBlank(256)})
    .strict(),
]);

const memoryCandidateSchema = z
  .object({
    fact: nonBlank(1_000),
    sourceMessageIds: z
      .array(nonBlank(128))
      .min(1)
      .max(100)
      .refine(
        (values) => new Set(values).size === values.length,
        'source message ids must be unique',
      ),
  })
  .strict();

export const diaryOutputSchema = z
  .object({
    schemaVersion: z.literal(1),
    mood: nonBlank(160),
    oneLineSummary: nonBlank(500),
    theme: z.enum(['light', 'dark']),
    blocks: z.array(diaryBlockSchema).min(1).max(100),
    memoryCandidates: z.array(memoryCandidateSchema).max(100),
  })
  .strict();

export class ModelOutputValidationError extends Error {
  constructor() {
    super('Model output did not satisfy the v1 contract.');
    this.name = 'ModelOutputValidationError';
  }
}

export function parseAllowedDiaryOutput(
  value: unknown,
  allowed: {
    readonly photoAssetIds: ReadonlySet<string>;
    readonly sourceMessageIds: ReadonlySet<string>;
  },
): DiaryOutput {
  const parsed = diaryOutputSchema.safeParse(value);
  if (!parsed.success) throw new ModelOutputValidationError();

  for (const block of parsed.data.blocks) {
    if (
      block.type === 'photo' &&
      !allowed.photoAssetIds.has(block.photoAssetId)
    ) {
      throw new ModelOutputValidationError();
    }
  }
  for (const candidate of parsed.data.memoryCandidates) {
    if (
      candidate.sourceMessageIds.some(
        (messageId) => !allowed.sourceMessageIds.has(messageId),
      )
    ) {
      throw new ModelOutputValidationError();
    }
  }
  return parsed.data;
}

export type ChatRequest = z.infer<typeof chatRequestSchema>;
export type ChatReplyResponse = z.infer<typeof chatReplyResponseSchema>;
export type DiaryRequest = z.infer<typeof diaryRequestSchema>;
export type DiaryOutput = z.infer<typeof diaryOutputSchema>;
export type ResponseLocale = z.infer<typeof responseLocaleSchema>;

export const CHAT_MODEL_OUTPUT_JSON_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['text'],
  properties: {
    text: {type: 'string'},
  },
} as const;

export const DIARY_OUTPUT_JSON_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: [
    'schemaVersion',
    'mood',
    'oneLineSummary',
    'theme',
    'blocks',
    'memoryCandidates',
  ],
  properties: {
    schemaVersion: {type: 'integer', enum: [1]},
    mood: {type: 'string'},
    oneLineSummary: {type: 'string'},
    theme: {type: 'string', enum: ['light', 'dark']},
    blocks: {
      type: 'array',
      minItems: 1,
      items: {
        anyOf: [
          {
            type: 'object',
            additionalProperties: false,
            required: ['type', 'text'],
            properties: {
              type: {type: 'string', enum: ['text']},
              text: {type: 'string'},
            },
          },
          {
            type: 'object',
            additionalProperties: false,
            required: ['type', 'photoAssetId'],
            properties: {
              type: {type: 'string', enum: ['photo']},
              photoAssetId: {type: 'string'},
            },
          },
        ],
      },
    },
    memoryCandidates: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['fact', 'sourceMessageIds'],
        properties: {
          fact: {type: 'string'},
          sourceMessageIds: {
            type: 'array',
            minItems: 1,
            items: {type: 'string'},
          },
        },
      },
    },
  },
} as const;
