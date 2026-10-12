# A. 무엇을·왜

- 외부 날씨 제공자나 위치 권한이 없어도 사용자가 일기 편집기에서 날씨 상태와 선택적 기온을 직접 기록할 수 있게 했다.
- 날씨를 사용하지 않는 선택도 그대로 유지하며, 저장된 일기·보관함·공유 이미지가 기존 `WeatherSnapshot`을 통해 같은 값을 사용한다.
- 제공자 기반 snapshot을 다른 항목만 편집했을 때는 provenance를 보존하고, 사용자가 날씨 값을 바꾼 경우에만 수동 입력 snapshot으로 바꾼다.

# C. Critical Path

- 위치 권한 요청, 외부 날씨 API, 백그라운드 수집은 추가하지 않았다. DEC-06이 미결정인 동안 날씨 값은 사용자 명시 입력 또는 `noWeather`뿐이다.
- 기온은 선택 사항이며 숫자가 아닌 입력은 저장하지 않고 편집 화면에 남긴다. 빈 날씨 상태도 domain 검증에서 거부한다.
- 일기 수정은 기존 snapshot identity, generation ID, source message ID와 사진 블록을 바꾸지 않고 날씨를 포함한 편집 가능 필드만 새 snapshot으로 저장한다.
- 관련 domain/controller/widget 테스트 18개와 focused analyzer를 통과했다.
