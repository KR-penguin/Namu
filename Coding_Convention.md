# Coding Convention

이 문서는 사람과 AI가 반드시 지켜야 할 핵심 규칙만 정의한다. 포매팅, import 순서, 일반적인 네이밍처럼 `dart format`과 analyzer가 검사할 내용은 반복하지 않는다. 규칙을 예외 처리해야 한다면 우회하지 말고 이유와 영향 범위를 코드 리뷰에 남긴다.

## AR-01. 구조와 의존 방향

- 코드는 기술 종류보다 feature를 기준으로 모은다. 각 feature 안에서 필요할 때만 presentation, application, domain, data/infrastructure 책임을 나눈다.
- Domain은 Flutter 위젯, DB, Vertex AI, 분석·광고·공유 SDK를 직접 알지 않는다.
- Widget 안에서 API/DB 호출, prompt 조립, 일기 생성 규칙을 구현하지 않는다.
- 외부 서비스와 플랫폼 SDK는 adapter/repository 경계 뒤에 두어 테스트 대역으로 바꿀 수 있게 한다.
- 다른 feature의 내부 상태나 저장 구현에 직접 접근하지 않는다. 공개된 모델 또는 use case를 통한다.
- 두 곳 이상에서 실제로 같은 의미로 쓰일 때만 공용화한다. 미래를 예상한 추상화와 빈 계층 파일은 만들지 않는다.

## DM-01. 도메인과 데이터

- 영속 데이터에는 하나의 명확한 source of truth를 둔다. 일기·대화의 기준 원본은 로컬 저장소다. 화면은 저장/취소 경계가 분명한 임시 edit draft를 가질 수 있지만 별도 영속 원본으로 취급하지 않는다.
- Domain 모델, DB row, 외부 API DTO를 분리한다. 한쪽 schema 변경이 앱 전체로 번지지 않게 경계에서 변환한다.
- Domain 모델과 상태는 가능한 한 불변으로 유지하고, 상태 변경은 소유한 use case/notifier 한 곳에서 수행한다.
- ID, `DiaryDayKey`, UTC timestamp를 혼용하지 않는다. 시각은 UTC로 저장하고, 하루는 label date·당시 timezone·cutoff·policy version을 snapshot한 key로 구분한다.
- migration 없이 저장 schema의 의미를 바꾸지 않는다. migration은 이전 실제 schema에서 올라오는 테스트를 함께 둔다.
- 파일과 DB를 함께 바꾸는 작업은 중단·재시도 시에도 복구 가능해야 한다. 고아 사진과 반쪽 일기를 만들지 않는다.

## AI-01. Gemini와 prompt 경계

- Vertex AI 서비스 계정, 비밀 키, 장기 자격 증명을 앱 또는 저장소에 포함하지 않는다. 특권 호출은 인증·할당량·악용 방지가 있는 Gateway를 통한다.
- prompt 템플릿과 구조화 응답 schema는 한곳에서 관리하고 각각 버전을 식별할 수 있게 한다.
- 사용자 메시지와 사진 속 문장은 **데이터**로 취급한다. 시스템 지침을 대체하는 명령으로 실행하지 않는다.
- 모델 응답은 신뢰하지 않는다. schema, 필수 필드, 길이, 허용 enum, 입력으로 전달한 photo ID를 검증한 뒤 Domain 모델로 바꾼다.
- 날짜와 날씨는 모델 생성값을 기준 원본으로 쓰지 않는다. 앱이 검증한 `DiaryDayKey`와 `WeatherSnapshot`을 입력하고 최종 일기에 그대로 조립한다.
- 파싱 실패, 안전 차단, timeout, 빈 응답에는 사용자 데이터를 잃지 않는 명시적인 fallback과 재시도 경로를 둔다.
- 모델 ID와 sampling 설정을 UI 또는 여러 feature에 하드코딩하지 않는다. Gateway의 버전된 설정에서 관리한다.
- AI 문구의 우연한 형태에 앱 동작을 의존시키지 않는다. 앱의 분기에는 구조화된 값만 사용한다.

## AS-01. 상태와 비동기 작업

- 프로젝트에서 채택한 한 상태 관리 방식을 기본으로 한다. 다른 방식을 섞으려면 이유와 전환 범위를 먼저 문서화한다.
- 비동기 화면은 loading, data/empty, error, 재시도 가능 여부를 표현한다.
- 화면 종료 뒤 도착한 응답, 중복 탭, 취소, 오래된 응답이 최신 상태를 덮는 경우를 처리한다.
- 반드시 끝나야 하는 작업은 `await`한다. 의도적인 fire-and-forget은 코드에서 의도와 실패 처리 위치가 드러나야 한다.
- 전송, 저장, 업로드, 하루 마감은 idempotent하게 만든다. 같은 request/generation key의 재시도가 중복 메시지·일기·기억을 만들면 안 된다.
- 자정에 앱이 실행 중이라고 가정하지 않는다. 같은 `DiaryDayKey`별 1회 생성을 보장하고 다음 실행 기회에 누락분을 보정한다. MVP cutoff는 00:00이며 바꾸려면 귀속·migration 정책을 먼저 정한다.
- `BuildContext`는 비동기 경계를 넘은 뒤 그대로 사용하지 않는다. controller, stream, subscription은 생성한 계층에서 해제한다.

## UI-01. Flutter UI

- Widget은 렌더링과 사용자 이벤트 전달에 집중한다. 업무 규칙은 Widget 밖에서 테스트 가능해야 한다.
- 색상, typography, spacing, 문구, route를 화면마다 복제하지 않고 각각 theme/token, localization, router에서 관리한다.
- 플랫폼별 동작은 UI 곳곳의 `Platform.is...` 분기가 아니라 작은 platform adapter 뒤에 둔다.
- 긴 한국어/영어 문장, 큰 글자 설정, 작은 화면, 키보드가 열린 상태에서 잘리거나 조작 불가능한 UI를 만들지 않는다.
- 의미 있는 이미지와 버튼에는 접근성 label을 제공한다. 색만으로 상태를 전달하지 않는다.
- 공유용 일기는 화면 screenshot에 의존하지 않고, 고정된 export 규격을 가진 renderer로 만든다.

## PV-01. 개인정보와 보안

- 대화, 일기, 사진, 위치, AI 기억은 민감정보로 취급하고 기능에 필요한 최소 데이터만 외부로 전송한다.
- 원문 대화, 일기, 사진 bytes/경로, 정밀 위치, token, 전체 prompt를 log, analytics, crash report에 남기지 않는다.
- 광고 SDK에 대화·일기·사진·기억을 넘기거나 광고 ID와 결합하지 않는다.
- 인증 token은 OS 보안 저장소에 둔다. 사용자 콘텐츠는 앱 전용 저장 영역을 사용하고 정한 암호화·백업 정책을 지킨다.
- 사진은 전송/공유 전에 EXIF 위치 등 불필요한 metadata를 제거한다.
- 권한은 사용 시점에 목적과 대안을 설명하고 최소 범위로 요청한다. 거부해도 가능한 핵심 기능은 유지한다.
- 공유는 사용자의 명시적 동작으로만 시작하며, 외부 앱을 열기 전에 공유될 결과를 미리 보여준다.
- 삭제는 DB row뿐 아니라 thumbnail, 앱 sandbox의 export staging/cache, 임시 업로드, 참조 없는 원본, AI 기억 등 파생 데이터까지 포함한다. 외부 앱이나 파일 영역으로 나간 사본은 회수할 수 없음을 알린다.
- 원문 메시지 삭제 시 연결 기억을 즉시 비활성화한다. 사용자가 독립 기억으로 다시 승인하기 전에는 다음 prompt에 넣지 않는다.

## TE-01. 테스트

- 기능과 버그 수정은 테스트부터 시작한다. 버그는 재현 테스트가 먼저이고 날짜·개수·길이 등 경계값을 포함한다.
- Domain 규칙과 use case는 빠른 unit test로 보호한다. DB, 파일, 네트워크, Vertex AI, 광고·공유 SDK는 테스트 대역으로 교체 가능해야 한다.
- 일반 테스트가 운영 서비스, 실제 과금 API, 사용자 데이터에 접근하면 안 된다.
- 다음 흐름은 반드시 회귀 테스트 대상이다.
  - 메시지/사진 저장과 복원, offline 재시도
  - 23:59/00:00, 시간대 변경, 중복 하루 마감
  - AI schema 오류, 알 수 없는 photo ID, 안전 차단
  - 일기 재생성·삭제와 고아 파일 정리
  - 기억 생성·주입·수정·삭제
  - export overflow와 공유 취소/Instagram 미설치
- Gateway는 무인증·위조/만료 attestation, replay/idempotency, quota/429, 크기·MIME 오류, 로그 redaction, 임시 이미지 만료, 동의 철회를 검증한다.
- prompt, persona, 메시지, 사진 속 지시가 상위 안전 지침을 바꾸지 못하는 계약 테스트를 둔다.
- 생성 문장의 정확한 표현을 고정하지 않는다. schema, 제약, 필수 의미, 안전한 fallback을 검증한다.
- 핵심 사용자 흐름만 소수의 widget/integration/golden test로 보호한다. 모든 화면에 같은 종류의 테스트를 강제하지 않는다.

## DP-01. 의존성과 생성 코드

- 패키지는 필요성이 명확할 때만 추가한다. 유지보수 상태, license, 앱 크기, 권한·개인정보, 대체 가능성을 확인한다.
- 앱의 `pubspec.lock`은 커밋한다. 기능과 무관한 주요 SDK upgrade는 분리한다. 기능에 필수이면 같은 변경에 포함하되 이유, migration, 검증 결과를 남긴다.
- `*.g.dart`, `*.freezed.dart` 같은 생성 파일을 직접 수정하지 않는다. 원본이나 설정을 고친 뒤 다시 생성한다.
- 생성 명령과 생성 파일 커밋 정책은 `AI_README.md`에 기록하고 프로젝트 전체에서 일관되게 적용한다.
- 새 의존성이 architecture, 빌드, 권한, 데이터 흐름을 바꾸면 코드보다 `AI_README.md`를 먼저 갱신한다.

## DO-01. 문서와 주석

- 작업 전 `AI_README.md`를 읽는다.
- 구조, 데이터 흐름/schema, 외부 API, route, 핵심 의존성, 실행·생성 명령, 보안 가정, 현재 phase가 바뀌면 구현보다 `AI_README.md`를 먼저 갱신한다.
- 코드와 문서가 다르면 추측하지 말고 실제 상태를 확인해 함께 고친다.
- 주석은 코드의 번역이 아니라 그 방식이 필요한 이유, 제약, 실패 가능성을 설명한다.
- 되돌리기 어렵거나 여러 feature에 영향을 주는 결정만 ADR로 남긴다. 사소한 선택까지 문서화하지 않는다.
- Phase 종료 리뷰는 `prompt.md`가 정한 `result reports/`의 A/C/D 형식을 따른다.

## GT-01. Git과 커밋

- `main`에 직접 커밋하지 않는다. 작업 branch에서 검토 가능한 단위로 변경한다.
- 커밋 제목은 영어 명령형으로 쓰며 다음 형식을 기본으로 한다.

  ```text
  type(scope): imperative summary
  ```

- `type`은 의도에 맞는 `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `build`, `ci`, `perf`를 사용한다. `scope`는 도움이 될 때만 쓴다.
- 예: `feat(chat): add photo attachment preview`, `fix(diary): prevent duplicate day generation`.
- 본문은 변경 이유, 중요한 제약, migration/운영 절차가 있을 때만 추가한다.
- 서로 무관한 변경을 한 커밋에 섞지 않는다. 생성 결과는 그것을 만든 원본 변경과 함께 커밋한다.
- secret, 개인 데이터, 로컬 환경 파일, 생성된 사용자 콘텐츠는 commit하지 않는다.
