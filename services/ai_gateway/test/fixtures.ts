export function validChatRequest() {
  return {
    schemaVersion: 2 as const,
    responseLocale: 'ko' as const,
    requestId: 'request-1',
    messageId: 'message-1',
    text: '오늘은 천천히 산책했어.',
    photoAssetId: null,
    createdAtUtc: '2026-10-04T08:00:00.000Z',
    dayKey: {
      labelDate: '2026-10-04',
      timeZoneId: 'Asia/Seoul',
      cutoffMinutes: 0 as const,
      policyVersion: 1 as const,
    },
    persona: {
      id: 'persona-1',
      name: '모아',
      avatarSeed: 'warm-tree',
      tone: '따뜻하고 호기심 있게',
      customInstructions: '질문은 한 번에 하나만 해줘.',
      reactionLength: 'expressive' as const,
    },
    recentMessages: [
      {
        id: 'previous-1',
        role: 'assistant' as const,
        text: '오늘은 어떤 하루였어?',
        photoAssetId: null,
        createdAtUtc: '2026-10-04T07:59:00.000Z',
      },
    ],
    activeMemories: [
      {
        id: 'memory-1',
        fact: '사용자는 산책을 좋아한다.',
        category: 'preference' as const,
        updatedAtUtc: '2026-10-03T08:00:00.000Z',
      },
    ],
  };
}

export function validDiaryRequest() {
  return {
    schemaVersion: 2 as const,
    responseLocale: 'ko' as const,
    generationId: 'generation-1',
    dayKey: {
      labelDate: '2026-10-04',
      timeZoneId: 'Asia/Seoul',
      cutoffMinutes: 0 as const,
      policyVersion: 1 as const,
    },
    weather: {
      provenance: 'provider' as const,
      condition: '맑음',
      temperatureCelsius: 21.5,
      providerId: 'weather-provider',
      observedAtUtc: '2026-10-04T07:30:00.000Z',
    },
    persona: {
      id: 'persona-1',
      name: '모아',
      avatarSeed: 'warm-tree',
      tone: '따뜻하고 호기심 있게',
      customInstructions: '짧은 질문으로 하루를 돌아보게 해줘.',
      reactionLength: 'expressive' as const,
    },
    messages: [
      {
        id: 'message-1',
        role: 'user' as const,
        text: '오늘은 천천히 산책했어.',
        photoAssetId: null,
        createdAtUtc: '2026-10-04T08:00:00.000Z',
      },
      {
        id: 'message-2',
        role: 'assistant' as const,
        text: '어떤 풍경이 기억에 남아?',
        photoAssetId: 'photo-1',
        createdAtUtc: '2026-10-04T08:02:00.000Z',
      },
    ],
  };
}

export function validDiaryOutput() {
  return {
    schemaVersion: 1 as const,
    mood: '평온함',
    oneLineSummary: '천천히 걸으며 여유를 찾은 하루.',
    theme: 'light' as const,
    blocks: [
      {type: 'text' as const, text: '천천히 걸으며 주변을 바라봤다.'},
      {type: 'photo' as const, photoAssetId: 'photo-1'},
    ],
    memoryCandidates: [
      {
        fact: '사용자는 천천히 산책하는 것을 좋아한다.',
        sourceMessageIds: ['message-1', 'message-2'],
      },
    ],
  };
}
