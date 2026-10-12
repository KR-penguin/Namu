# Phase 3 — AI 응답 언어 계약

## A. 무엇을·왜

Chat·Diary Gateway 요청을 strict JSON `schemaVersion: 2`로 올리고 `responseLocale`을 필수화했다. 앱은 `AiResponseLocale` enum을 통해 `ko`, `en`, `ja`, `zh-Hans`, `es`만 전송하며, Gateway도 같은 allowlist를 Zod에서 검증한다. Chat 응답과 Diary 생성 결과의 출력 schemaVersion은 기존 1을 유지해 저장·표시 계약을 불필요하게 바꾸지 않았다.

Gateway는 검증된 locale을 서버 소유 지시문에 매핑해 Chat의 text와 Diary의 자연어 값이 해당 언어로 생성되도록 요구한다. 요청 payload의 locale, persona, message 등은 계속 untrusted data로 취급한다.

## C. Critical Path

- request v1과 `responseLocale` 누락·미지원 locale은 모델 호출 전에 strict validation으로 거부된다. endpoint 경로 `/v1`은 유지되지만 body schemaVersion은 2이므로 구형 클라이언트와 새 Gateway를 혼용하면 400이 발생한다. 앱과 Gateway를 호환되는 버전으로 함께 배포해야 한다.
- locale 문자열을 원문 그대로 system instruction에 보간하지 않는다. Zod allowlist를 통과한 union만 고정된 서버 소유 문구에 매핑하므로 locale field를 통한 prompt injection 경계를 유지한다.
- Chat idempotency fingerprint에는 response locale을 포함했다. 같은 request ID를 다른 언어로 재사용하면 이전 언어 응답을 조용히 replay하지 않고 conflict로 거부한다.
- JSON field 이름, enum 값, photo/message ID는 번역하지 말라는 지시를 유지해 구조화 응답 decoder와 ID allowlist 검증이 locale 변화로 깨지지 않게 했다.
- 검증: Gateway 테스트 41개 통과, TypeScript typecheck와 production build 통과. Flutter locale enum 및 Chat/Diary HTTP adapter 집중 테스트 62개 통과.

## D. 새로 도입한 것

- `AiResponseLocale`: 앱과 wire tag 사이를 제한하는 pure Dart enum.
- Gateway request schema v2: `responseLocale` 필수 필드와 5개 locale allowlist.
