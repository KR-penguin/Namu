# A. 무엇을·왜

- 실제 설정 화면을 추가하고 AI 친구 설정, AI 데이터 전송 동의, 기록 JSON 내보내기, 모든 로컬 데이터 삭제로 연결했다.
- native 전체 삭제는 사용자 확인 뒤 앱이 소유한 backup 제외 저장 root 전체를 지우고 새 dependency graph로 앱을 다시 시작한다. 브라우저 검토판은 영속 삭제처럼 보이지 않도록 임시 상태 초기화라고 별도로 표시한다.
- 사용자가 삭제 범위와 복구 불가, 앱 밖에 내보낸 사본은 회수할 수 없음을 실행 전에 확인하도록 했다.

# C. Critical Path

- 삭제 전에 자정 coordinator와 foreground observer, controller, HTTP client, DB를 순서대로 종료해 WAL이나 열린 파일 handle이 남은 채 root를 지우지 않는다.
- native eraser는 절대 경로·충분한 경로 깊이·실제 directory 여부를 확인하고 symlink를 따라가지 않는다. broad root, 파일 root, 알 수 없는 filesystem entry는 삭제 대신 거부한다.
- 삭제 범위에는 DB/WAL, 메시지, 일기, 앱 소유 사진, persona, 기억, 내부 export/staging, AI 동의, 온보딩 상태가 포함된다. 외부 share/save 대상으로 복사된 파일과 OS가 관리하는 사본은 삭제하지 못한다.
- 실패하면 새 graph로 성공한 것처럼 전환하지 않고 redacted 오류 상태를 유지한다. web에서는 transient graph만 교체하며 기기 저장소 삭제를 검증했다고 주장하지 않는다.
- 전체 Flutter 테스트 476개와 `flutter analyze`를 통과했다.
