# A. 무엇을·왜

- 사용자가 승인한 AI 기억을 삭제하지 않고 `사용 중지`한 뒤 필요할 때 `다시 사용`할 수 있게 했다.
- 후보 기억은 기존처럼 먼저 명시적으로 승인해야 하며, 승인 전 후보를 활성·비활성 토글로 우회할 수 없게 했다.
- 상태 변경 뒤 목록의 `사용 중`·`사용 안 함` 배지와 다음 AI 대화에 포함되는 active 기억 집합이 즉시 같은 저장 상태를 반영한다.

# C. Critical Path

- 중지는 로컬 사실을 삭제하지 않고 status만 `inactive`로 영속화한다. Chat context adapter는 기존 계약대로 `active` 상태만 전송하므로 중지한 기억은 새 AI 요청에 포함되지 않는다.
- 민감한 후보도 승인 전에는 토글할 수 없다. 과거에 명시적으로 승인된 뒤 중지된 기억만 사용자 동작으로 다시 활성화할 수 있다.
- mutation 실패 시 현재 화면 상태를 보존하고 repository 또는 기억 원문이 포함된 오류를 사용자에게 노출하지 않는다.
- 관련 controller/widget 테스트 18개와 focused analyzer를 통과했다.

# D. 새로 도입한 것

- 새 의존성 없이 `SetMemoryFactActive` application use case를 추가해 reversible status 변경과 repository 저장을 한 경계에 모았다.
