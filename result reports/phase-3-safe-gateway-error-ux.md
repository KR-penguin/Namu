# A. 무엇을·왜

Chat 답변과 일기 초안 생성에서 Gateway의 typed 오류를 안전한 한국어 안내로 변환했다. 사용자는 안전 차단, 일시적 제한, timeout, 네트워크 문제, 인증·기기 검증 문제, 너무 크거나 불완전한 응답을 구분해 볼 수 있고, 로컬 원본이 기기에 남아 있음을 함께 확인할 수 있다. 안전 차단은 진단·상담 문구가 아니라 모델의 안전 기준에 따른 처리 제한으로만 설명한다.

# C. Critical Path

오류 안내는 예외 객체의 문자열, HTTP 상태 코드, Gateway 응답 본문을 이어 붙이지 않는다. 따라서 사용자 원문이나 민감한 서버 상세가 snackbar로 노출되지 않는다. Chat 전송 실패는 기존 local-first 흐름대로 사용자 메시지를 `failed` 상태로 보존하고 같은 요청 ID로 명시적 재시도를 제공한다. 일기 생성 실패도 원본 대화와 기존 일기를 변경하지 않는다.

`Retry-After`는 서버가 이미 상한을 적용한 advisory duration만 초·분·시간 단위로 올림해 보여준다. 자동 재시도나 백그라운드 호출은 추가하지 않았다. `idempotencyConflict`는 같은 요청을 무한 재시도하도록 유도하지 않고 Chat은 새 메시지, Diary는 앱 재실행 뒤 새 생성으로 안내한다.

# D. 새로 도입한 것

새 의존성 없이 `gatewayFailureMessage`라는 공용 presentation mapper를 추가했다. Chat과 Diary가 동일한 typed category 의미와 redaction 규칙을 공유한다.
