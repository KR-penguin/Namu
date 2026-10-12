# A. 무엇을·왜

- 첫 실행에서 AI 데이터 전송 내용을 설명하고 `동의`, `로컬 기록만 사용` 중 하나를 명시적으로 선택하는 `AiDataConsentGate`를 추가했다.
- 동의 상태는 현재 정책 버전, 선택, UTC 결정 시각만 앱 전용·backup 제외 저장소의 `settings/ai-data-consent-v1.json`에 저장한다. browser 검토 환경은 영속 저장처럼 가장하지 않고 in-memory adapter를 사용한다.
- chat 답변과 diary 생성 Gateway 각각에 consent decorator를 추가했다. 현재 정책에 동의하지 않았거나 파일이 없거나 알 수 없는 정책 버전이면 실제 Gateway delegate를 호출하지 않는다.
- 설정에서 현재 상태를 검토하고 동의 또는 철회할 수 있는 `AiDataConsentSettingsSheet`를 추가했다.
- 안내 문구는 현재 데이터 흐름을 그대로 반영한다. 글·최근 대화·승인 기억·persona·사진 첨부 정보는 Gateway로 전송될 수 있지만, 사진 원본 bytes는 현재 전송하지 않는다.

# C. Critical Path

- 운영 composition은 같은 `AiDataConsentRepository` 인스턴스를 controller와 두 Gateway decorator에 반드시 주입해야 한다. UI gate만 연결하면 우회 호출이 가능하므로 보안 경계가 아니다.
- native는 기존 `AppStoragePaths`와 `FileAiDataConsentRepository`를 연결하고, web preview는 `InMemoryAiDataConsentRepository`를 연결한다.
- 원래 `ChatReplyGateway`를 `ConsentRequiredChatReplyGateway`로 감싼 뒤 `SendMessage`에 주입하고, 원래 `DiaryGenerationGateway`를 `ConsentRequiredDiaryGenerationGateway`로 감싼 뒤 수동 생성 controller와 자동 하루 마감 coordinator 양쪽에 같은 guarded instance를 주입한다.
- 앱 home 앞에 `AiDataConsentGate(controller: consentController, child: todayScreen)`를 놓는다. 설정 진입점에서는 `AiDataConsentSettingsSheet(controller: consentController)`를 연다. controller는 앱 composition 계층이 생성·dispose한다.
- 철회 전에 이미 시작된 HTTP 요청을 취소하는 기능은 이 decorator의 범위가 아니다. 철회 완료 뒤 시작되는 모든 chat/diary 요청은 차단된다. HTTP cancellation까지 요구한다면 transport cancel token을 별도 설계해야 한다.
- 파일이 없거나 malformed이거나 알 수 없는 정책 버전이면 `undecided`로 해석해 fail closed한다. 파일 I/O 자체가 실패하면 오류를 반환하고 delegate는 호출하지 않는다.
- 검증: consent focused tests 13개 통과, 해당 lib/test analyzer 오류 0건.

# D. 새로 도입한 것

- 새 package는 없다.
- current-policy acceptance를 매 AI 호출 시 확인하는 Gateway decorator 패턴을 도입했다.
- consent 결정만 저장하는 backup-excluded JSON adapter와 browser용 transient in-memory adapter를 도입했다.
