# A. 무엇을·왜

- Chat과 Diary가 함께 사용하는 bounded/cancellable HTTP transport와 redacted response mapper를 추가했다. 요청 시작부터 response stream 완료까지 하나의 deadline을 적용하고, 초과·취소·비 JSON·과대 응답을 typed 오류로 구분한다.
- Gateway는 Vertex 안전 차단, timeout, 출력 truncation, 지원하지 않는 finish reason, 잘못된 구조화 응답을 안정적인 공개 오류 code로 분류한다. Diary의 malformed/계약 위반 출력만 정확히 한 번 repair하고 다른 실패는 재시도하지 않는다.
- 화면은 raw SDK·HTTP 오류나 응답 body 대신 안전한 한국어 안내와 로컬 원본 보존 상태를 표시한다.

# C. Critical Path

- client response는 기본 256 KiB를 넘으면 실제 HTTP 요청을 abort한다. 선언 길이와 stream 누적 길이를 모두 검사하며 `application/json` 이외의 MIME은 성공 body로 해석하지 않는다.
- 자격 증명 header는 allowlist 경계에서만 주입하며 고정 content/idempotency header를 덮어쓸 수 없다. 오류 body는 짧은 allowlisted code만 읽고 원문은 network layer 밖으로 전달하지 않는다. `Retry-After`도 숫자 초만 허용하고 24시간으로 상한을 둔다.
- Vertex 호출은 candidate 1개, Chat 512/Diary 2048 output token, 15초 provider timeout과 명시적 안전 threshold를 사용한다. 안전 차단·timeout·truncation은 repair하지 않아 비용 증가와 정책 우회를 막는다.
- production 인증 adapter는 DEC-03이 정해질 때까지 deny-all이다. 현재 quota/idempotency는 process-local이므로 여러 Cloud Run instance 또는 외부 beta 전에 원자적 TTL을 제공하는 shared backend로 교체해야 한다.
- Flutter 전체 테스트 476개·정적 분석, Gateway 테스트 37개·typecheck·production build를 통과했다.

# D. 새로 도입한 것

- 새 의존성 없이 `GatewayHttpTransport`와 `throwForGatewayError` 공용 경계를 도입했다. 서버와 앱은 `safety_blocked`, `model_timeout`, `model_truncated`, `invalid_model_response` 등 안정적인 공개 code로만 실패 의미를 공유한다.
