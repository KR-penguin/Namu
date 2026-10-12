# Phase 3 — 5개 언어 현지화

## A. 무엇을·왜

- 한국어 `ko`, 영어 `en`, 일본어 `ja`, 중국어 간체 `zh-Hans`, 스페인어 `es` UI를 추가했다. 기기 locale을 우선하고 미지원 언어와 중국어 번체는 영어로 fallback한다.
- 각 언어 catalog에 같은 270개 ARB message를 두고 Flutter `gen_l10n`으로 화면 문구, 접근성 label, 오류·동의·개인정보 안내, 공유 PNG·caption과 JSON 내보내기 문구를 생성한다.
- 앱이 그리는 날짜·숫자·기온을 locale에 맞추고 스페인어의 쉼표 소수 입력을 지원한다. 새 persona가 아직 저장되지 않았을 때만 locale별 이름·말투 seed를 사용한다.
- Chat·Diary Gateway request를 schema v2로 올려 필수 `responseLocale`을 보낸다. Gemini 자연어는 현재 기기 언어에 맞추되 Chat 응답과 Diary 출력 schema v1은 유지한다.

## C. Critical Path

- 사용자가 쓴 대화·일기·기억, AI가 만든 기존 결과와 저장된 persona는 UI locale 전환으로 번역하거나 덮어쓰지 않는다. 새 persona의 최초 seed만 생성 시점 locale을 사용하므로 이후 변경은 사용자 데이터로 보존된다.
- Flutter `gen_l10n`이 요구하는 language-only `zh` catalog를 제품의 `zh-Hans`로 사용하되, resolver가 `zh-Hant`와 TW·HK·MO locale을 영어로 보내 번체 기기에 간체가 잘못 표시되지 않게 했다.
- Chat 답변, 수동 일기 생성과 자정 자동 생성은 요청 직전에 runtime locale을 다시 읽는다. Gateway는 5개 값 allowlist를 통과한 locale만 고정된 서버 소유 지시로 바꾸며 locale 문자열 자체를 instruction에 보간하지 않는다.
- request v1 또는 `responseLocale` 누락·미지원 값은 모델 호출 전에 거부된다. endpoint `/v1`과 output schema v1은 그대로지만 request body는 v2이므로 앱과 Gateway를 호환 버전으로 함께 배포해야 한다. Chat idempotency fingerprint에도 locale이 들어가 다른 언어 응답이 replay되지 않는다.
- protocol field·enum·ID·저장 날짜 key는 번역하지 않는다. 공유 PNG는 날짜·날씨·고정 copy만 locale에 맞추고 사용자의 요약·기분·본문은 그대로 렌더링한다. OS share sheet를 연 사실만 성공으로 표현하는 경계도 모든 번역에서 유지한다.
- 최종 통합 검증에서 Flutter test 500개, Flutter analyze 0 issue, web production build가 통과했다. Gateway test 41개와 Gateway typecheck·production build도 통과했다.

## D. 새로 도입한 것

- Flutter SDK의 `flutter_localizations`, `intl` 0.20.3, ARB 5개와 `gen_l10n` 생성 흐름
- `NamuFormatters`: locale-aware 날짜·숫자·섭씨 표시와 소수 입력 경계
- `AiResponseLocale`: `ko`/`en`/`ja`/`zh-Hans`/`es` wire tag만 허용하는 앱 enum
- Chat·Diary request schema v2의 필수 `responseLocale`; output schema는 v1 유지
