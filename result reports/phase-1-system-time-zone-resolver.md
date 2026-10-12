# A. 무엇을·왜

- Android `TimeZone.getDefault().id`와 iOS `TimeZone.current.identifier`를 `namu/time_zone` MethodChannel로 읽는 mobile resolver를 추가했다. `DateTime.timeZoneName` 약어로 일기 날짜 identity가 DST 전환 시 바뀌는 문제를 막기 위해서다.
- async `initialize()` / `refresh()` 후 sync `snapshotAt(DateTime UTC)`를 제공해 `LocalMidnightDiarySchedule.timeZoneAt`에 바로 주입할 수 있게 했다. 서울→뉴욕 갱신, 뉴욕 DST 겨울/여름 offset, 23시간 자정 경계, 잘못된 channel 값·platform 실패·동시 초기화·실패한 갱신의 상태 보존을 테스트했다.
- Browser preview는 `namu-web-preview-local-offset`라는 명시적 non-IANA ID를 쓴다. 이 adapter를 mobile production 일기 identity로 오인하지 않게 한다.

# C. Critical Path

- native ID를 bundled IANA tzdata에서 검증한 다음 그 시각의 offset을 계산하므로 ID와 offset이 하나의 규칙에서 나온다. 알 수 없는 ID, `GMT+09:00` 같은 fixed-offset 표기, 공백/타입 오류는 영속 `DiaryDayKey`가 되기 전에 거부한다.
- foreground 갱신이 실패해도 기존의 검증된 location을 교체하지 않아, ID와 rule이 어긋난 반쪽 상태를 노출하지 않는다. channel 예외의 native message/details는 Dart 예외에 포함하지 않는다.
- tzdata는 앱 버전에 묶이므로 국가의 시간대 법규가 바뀌면 `timezone` 패키지/tzdata를 앱 업데이트로 배포해야 한다. OS ID 갱신은 production lifecycle에서 foreground 복귀 전에 `refresh()`를 await해야 한다.
- 이 호스트에 Android SDK가 없고 Linux에서 iOS build를 할 수 없어 native channel은 실기기 build 검증이 남았다. Dart/core time 테스트 18개와 전체 Flutter 테스트는 통과했고, 해당 core/time analyzer는 오류 0건이다. 전체 analyzer에는 이 변경과 무관한 controller initializing-formal info 2건이 남아 있다.

# D. 새로 도입한 것

- `timezone` 0.11.1: IANA tzdata를 앱에 포함하고 UTC instant별 offset을 동기적으로 조회한다.
- `TimeZoneResolver`: platform 초기화·갱신과 자정 schedule의 동기 조회를 분리한 adapter 계약이다.
- `namu/time_zone` / `getTimeZoneId`: Android·iOS host와 Flutter 사이의 최소 MethodChannel 계약이다.
