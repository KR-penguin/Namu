# A. 무엇을·왜

- 실제 `apps/mobile/lib/main.dart`를 브라우저에서 실행해 검토할 수 있도록 Flutter 3.47.6의 공식 `web/` host scaffold를 추가했다.
- 바로 앞의 앱 코드를 우회하는 별도 프리뷰는 두지 않았다. 브라우저도 동일한 `NamuBootstrap`과 web transient repository graph를 실행한다.
- 생성기가 만든 counter 예제 test는 제거하고, 기존 Android/iOS migration metadata를 보존한 채 web platform 기록만 추가했다.

# C. Critical Path

- `web/`은 배포 제품, 공개 web profile, cloud sync/backup/restore가 아니다. 재실행 시 데이터가 사라지는 개발 검토 surface로만 사용한다.
- `flutter build web`이 성공해 production entry point의 web import 경계를 검증했다. Chrome에서 bootstrap widget test 1개, VM에서 bootstrap/app widget test 15개가 통과했다.
- 생성된 icon은 Flutter 기본 placeholder다. 출시 브랜드 icon으로 간주하지 않는다.

# D. 새로 도입한 것

- Flutter 공식 web host scaffold(`index.html`, manifest, favicon/icon asset)를 추가했다. 신규 Dart/Flutter package나 영속 web 저장소는 추가하지 않았다.
