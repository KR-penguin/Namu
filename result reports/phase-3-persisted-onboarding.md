# A. 무엇을·왜

최초 실행에서 기록이 기기에만 저장되고 앱 삭제·기기 분실 뒤에는 복구할 수 없다는 점, 대화 상대가 사람이 아닌 생성형 AI라는 점, AI 기능을 선택하면 전송되는 데이터 범위를 한 화면에 명시했다. 온보딩 완료를 AI 데이터 전송 동의와 별도로 저장해, 사용자가 동의를 보류한 `undecided` 상태에서도 로컬 기록을 시작할 수 있게 했다.

native는 backup-excluded 앱 저장 root에 `settings/onboarding-v1.json`을 atomic staging/rename으로 저장하고, browser preview는 다시 실행하면 사라지는 in-memory 상태를 쓴다. production dependency graph·bootstrap·app gate에 연결했고, 전체 로컬 데이터 삭제 후에는 온보딩도 다시 나오도록 같은 root lifecycle에 두었다.

# C. Critical Path

- 온보딩 완료는 AI 전송 허가가 아니다. `undecided`로 시작해도 chat·diary Gateway decorator가 외부 호출을 계속 거부한다.
- AI 전송을 선택한 경우에는 동의 저장이 성공한 뒤에만 온보딩 완료를 저장한다. 동의 저장 실패를 완료로 잘못 기록하지 않는다.
- AI 동의 저장을 읽지 못해도 로컬 시작은 허용하지만, 동의 확인이 되지 않은 AI 요청은 fail-closed 경계에서 차단된다.
- 온보딩 파일이 없거나 손상되었거나 알 수 없는 version이면 완료로 간주하지 않고 안내를 다시 보여 준다. I/O 실패는 내용을 노출하지 않는 재시도 상태로 표시한다.
- 로컬 저장의 앱 계층 암호화와 키 복구 정책은 기존 DEC-04 외부 beta 전 위협 모델 결정이 남아 있다. 이 온보딩은 현재 확정된 backup·sync·restore 미제공 범위만 고지한다.
