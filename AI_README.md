# AI README

> 이 문서는 사람과 AI가 프로젝트 전체를 읽지 않고도 작업을 시작하기 위한 단일 진입점이다.
> 코드·구조·핵심 결정이 달라지면 관련 구현보다 이 문서를 먼저 갱신한다.

## 1. 현재 상태

| 항목 | 값 |
|---|---|
| 기준일 | 2026-10-12 |
| 단계 | Phase 3 — MVP 이후 최종 제품화 진행 중. 5개 언어 UI 현지화와 AI 응답 언어 계약 구현 완료 |
| 기획 상태 | 아래 영구 비목표는 승인됨. 나머지 `PROJECT_PLAN.md`는 작업용 초안 |
| 구현 | Android·iOS scaffold, Drift schema v3와 migration, local-first 메시지/일기 Gateway, persona·최근 대화·승인 기억의 제한적 Chat context, 사진 import·실제 로컬 preview, web/native production composition, 다중 page 일기 preview·편집·날짜별 보관·검색·재열람, 기억 승인·편집·삭제·개별 사용 중지/재사용, 다중 PNG 공유, chat 중단 복구, native IANA timezone, 자정 자동 초안·foreground 보정·날짜 회전, AI 데이터 전송 동의·철회와 Gateway 강제 경계 완료. 최초 실행 온보딩, 안전한 전체 로컬 삭제, versioned JSON 기록 내보내기, 로컬 수동 날씨 입력과 `ko`/`en`/`ja`/`zh-Hans`/`es` UI·AI 응답 언어 계약 완료 |
| 로컬 저장 결정 | 모바일은 Drift/SQLite + 앱 소유 media 파일, web preview는 명시적 transient memory adapter |
| SDK | Flutter 3.47.6 stable / Dart 3.13.5 (`.metadata` revision으로 추적) |
| 이 호스트의 SDK | `/home/sean/.cache/namu-project/flutter/3.47.6/flutter`에 격리 보관. 저장소에는 포함하지 않음 |
| App ID | scaffold 기본값 `com.example.namu` — 출시·외부 서비스 연결 전 반드시 교체 |
| 실행·테스트 명령 | `cd apps/mobile && flutter pub get && flutter analyze && flutter test`; 브라우저 검토는 `flutter run -d web-server --web-hostname 127.0.0.1` |
| 최근 검증 | 2026-10-12 전체 Flutter test 502개 통과·analyze 0 issue·web release build 성공. AI Gateway test 41개·typecheck·production build·npm audit 통과 |
| 로컬 빌드 제약 | 이 호스트에는 Android SDK가 없고 Linux에서는 iOS build를 할 수 없어 Android·iOS 실기기 build는 미검증 |
| 실제 코드 entry point | `apps/mobile/lib/main.dart` |
| 다음 한 작업 | DEC-01·DEC-03·DEC-13을 닫고 실제 앱 ID·release signing과 production Gateway 인증/attestation 구현 범위를 확정 |
| 제품명 | 미정. 문서에서는 임시로 `Namu` 사용 |
| 저장소의 기준 문서 | `AI_README.md`, `PROJECT_PLAN.md`, `REMAINING_WORK.md`, `Coding_Convention.md`, `prompt.md` |

오늘 UI에는 fixture가 없고 실제 repository/controller 상태만 표시한다. Gateway 설정이 없거나 AI 전송 동의가 없으면 사용자 메시지는 로컬에 실패 상태로 남고, 앱은 필요한 조치를 명시한다. 브라우저 검토는 반드시 실제 `apps/mobile/lib/main.dart`를 실행해야 하며 별도 hardcoded preview를 제품 상태로 취급하지 않는다. 아래 코드 지도에 없는 구현을 추정하지 말고, **확정 / 권장안 / 미정** 구분을 유지한다. 완료되지 않은 작업의 우선순위·의존성·완료 조건은 `REMAINING_WORK.md`를 단일 추적 문서로 사용한다.

## 2. 작업 시작 순서

1. 이 문서를 읽는다.
2. AI의 작업 태도와 보고 규칙은 `prompt.md`에서 확인한다.
3. 남은 작업을 고르거나 상태를 갱신할 때 `REMAINING_WORK.md`를 읽고, 제품 범위가 필요하면 `PROJECT_PLAN.md`의 해당 절만 읽는다.
4. 코드를 쓰거나 리뷰할 때 `Coding_Convention.md`를 읽는다.
5. 아래 코드 지도를 보고 작업 대상 feature와 직접 연결된 파일만 추가로 읽는다.
6. 작업으로 상태가 달라지면 이 문서를 먼저 갱신한 뒤 구현과 테스트를 변경한다.

사용자의 최신 요청이 항상 최우선이다. 그 밖에는 단일 서열 대신 책임에 맞는 기준을 사용한다: 작업 태도·보고는 `prompt.md`, 제품 범위·UX는 승인된 `PROJECT_PLAN.md`, 코드 작성은 `Coding_Convention.md`, 현재 구현 상태·탐색은 이 문서가 기준이다. 충돌을 발견하면 순위로 밀어붙이지 말고 실제 상태를 확인해 관련 문서를 함께 정리한다.

## 3. 기획 초안 기준 제품 한 문장

사용자가 Instagram DM처럼 AI와 일상을 나누면 즉시 풍부하게 반응하고, 하루가 끝날 때 대화와 사진을 편집 가능한 Instagram 게시물형 일기로 구성해 주는 로컬 우선(local-first) 모바일 앱이다.

## 4. 현재 기획 초안의 제품 원칙 — 승인 전 권장안

- **대화가 주 경험이다.** 일기 작성 폼보다 친구와 메시지하는 감각을 우선한다.
- **일기는 초안이다.** AI가 생성하지만 사용자가 수정·재생성·삭제하고 최종본을 결정한다.
- **사용자 데이터가 우선이다.** 일기와 사진의 기준 원본은 사용자 기기에 둔다.
- **기억은 짧고 통제 가능해야 한다.** 원문 전체를 영구 주입하지 않고 중요한 사실만 요약하며 사용자가 조회·수정·삭제·비활성화할 수 있게 한다.
- **공유는 명시적이다.** 앱이 몰래 게시하지 않고, 지원되는 Instagram 경로 또는 OS share sheet에서 사용자가 최종 확인한다.
- **AI 결과를 그대로 신뢰하지 않는다.** 구조, 사진 참조, 날짜, 길이를 앱에서 검증한다.

## 5. 결정 상태

### 확정된 요구사항

- 생성형 AI로 Gemini를 사용한다.
- 클라이언트 구현은 Dart + Flutter로 시작한다.
- 텍스트와 사진을 대화에 첨부할 수 있다.
- 날짜, 날씨, 기분, 한 줄 요약이 포함된 일기를 하루 단위로 만든다.
- 일기 본문은 `글 → 사진 → 글`처럼 텍스트와 사진이 섞인 순서형 블록이다.
- 결과물은 밝은/어두운 테마를 지원하고 Instagram 피드에 공유할 수 있어야 한다.
- AI 이름, 프로필, 말투, 성격을 사용자가 바꿀 수 있다.
- 일기 보관함은 기기 안에 있으며 나중에 다시 열 수 있다.
- 다음 대화에 필요한 핵심 기억을 별도로 요약해 이후 프롬프트에 넣는다.
- 대화 화면은 Instagram Direct Message에서 익숙한 패턴을 참고한다. 그대로 복제하거나 Instagram 상표를 제품 UI에 사용하지 않는다.
- 수익화는 배너 광고를 기본으로 한다.

### 제품 전 범위 영구 비목표

2026-10-04 사용자 결정이다. MVP에서만 미루는 기능이 아니라 이 제품에서 만들지 않는다.

- 사용자 간 feed, follow, like, comment, DM
- 사용자 확인 없는 Instagram 자동 게시
- 완전한 offline AI, 음성·동영상 메시지, AI 생성 사진
- 여러 AI 캐릭터와 동시 대화
- cloud sync, 다기기 복원, 공개 web profile
- 구독, 유료 theme, 광고 제거 결제
- 정신건강 진단·치료·상담 서비스

위기 표현에 안전하게 안내하는 것은 상담 기능이 아니라 필수 안전 대응이므로 유지한다.

### 필수 기술 guardrail

- 모바일 앱에 장기 자격 증명을 두지 않는다. 특권 AI 호출은 인증·할당량·악용 방지 경계를 통한다.
- AI 응답은 schema와 앱의 기준 데이터를 검증한 뒤에만 저장·표시한다.

### 현재 권장안

아직 사용자 승인 또는 ADR로 확정되지 않은 기본안이다. 구현 전에 의존성, 운영비, 개인정보 영향을 다시 검증한다.

- Gemini 호출 환경은 Vertex AI를 예정한다.
- 기능 중심(feature-first) 구조 + 얇은 계층 분리를 사용한다.
- 상태 관리는 Riverpod, 화면 이동은 `go_router`, 로컬 구조화 데이터는 Drift/SQLite를 우선 검토한다.
- 사진은 앱 전용 로컬 저장소에 두고 DB에는 앱 내부 ID와 메타데이터만 저장한다.
- 특권 호출 경계의 우선 구현안은 Cloud Run 기반의 얇은 AI Gateway다.
- Gateway는 인증, App Check/무결성 확인, 사용자별 제한, 스키마 검증, 비용·안전 제어만 담당하고 일기 원문을 기본적으로 보관하지 않는다.
- 공유용 결과는 4:5 이미지 페이지(권장 1080×1350) 한 장 또는 carousel 여러 장으로 렌더링하고 Instagram/OS 공유 화면을 연다.
- 광고는 대화 입력창, 생성 중 화면, 공유 이미지 안에는 넣지 않는다. 보관함·설정처럼 집중을 덜 해치는 화면에만 둔다.

### 결정 register — 단일 기준

`open`은 구현 전 사용자 결정 또는 spike가 필요하고, `proposed`는 미승인 초안의 기본안, `decided`는 승인된 제품 기준, `excluded`는 제품 전 범위에서 금지된 기능이다. 결정되면 날짜와 근거를 이 표에 먼저 남긴다.

| ID | 상태 | 결정 | 현재 기본안 |
|---|---|---|---|
| DEC-01 | open | 출시 국가·최소 연령 | UI 언어는 DEC-14로 확정. 출시 국가와 18세 이상 가설은 별도 검증 |
| DEC-02 | open | 여행·시간대 변경 시 하루 귀속 | MVP 마감은 00:00 고정, `DiaryDayKey`에 당시 정책 snapshot 저장 |
| DEC-03 | open | 앱 사용자 식별·Gateway 인증·quota | 로컬 profile + 서버용 익명 식별 |
| DEC-04 | decided | 로컬 DB·파일·backup·export | Drift/SQLite + 앱 소유 media 파일 + OS backup 제외 + 수동 export. 앱 계층 암호화는 외부 beta 전 위협 모델에서 별도 결정(2026-10-04 spike) |
| DEC-05 | decided | Gateway 런타임·Vertex region·임시 데이터 보존 | Cloud Run Node.js 22 + TypeScript + `@google/genai` 2.x, region/model은 env, 원문·사진 비보존(2026-10-04 MVP 구현). 배포 region 값은 운영자가 결정 |
| DEC-06 | open | 날씨 provider·위치 거부 fallback | 동의 시 당일 snapshot, 아니면 도시 선택/수동/생략 |
| DEC-07 | open | 비민감 기억 자동 활성화 opt-in 범위 | 사용자 승인 기본, 자동 활성화는 별도 opt-in |
| DEC-08 | open | 단일/carousel export와 Instagram 전달 방식 | 4:5 page, Phase 0 실기기 검증 |
| DEC-09 | open | 광고 provider·배치·consent | AdMob 우선 검토, 친밀한 화면 제외 |
| DEC-10 | decided | iOS·Android 최소 지원 버전 | Android API 24+, iOS 15+. Flutter 3.47와 image_picker 1.2.3 기준(2026-10-04 MVP 구현) |
| DEC-11 | excluded | cloud sync·다기기 restore | 제품 전 범위 제외(2026-10-04 사용자 결정). 수동 export만 허용 |
| DEC-12 | decided | client stack | Dart + Flutter로 시작(2026-10-04 사용자 결정) |
| DEC-13 | open | Android application ID / iOS bundle ID | 실제 reverse-domain ID를 정하기 전 `com.example.namu`는 placeholder로만 사용 |
| DEC-14 | decided | 초기 앱 UI 언어와 fallback | `ko`, `en`, `ja`, `zh-Hans`, `es`; 기기 언어 우선, 미지원 locale은 영어 fallback(2026-10-10 사용자 요청 및 구현 결정) |

## 6. 목표 아키텍처

> §6–12는 `PROJECT_PLAN.md` 초안을 요약한 목표 설계이며 현재 구현이나 사용자 승인 완료를 뜻하지 않는다.

```text
Flutter app
  ├─ Chat / Diary / Archive / Persona / Settings UI
  ├─ Application use cases
  ├─ Domain models and repository interfaces
  ├─ Local DB + app-owned media files        ← 기준 원본
  ├─ AI Gateway client                       ← 짧은 요청만 전송
  └─ Share renderer + platform share adapter ← 사용자가 최종 게시
                     │
                     ▼
Thin AI Gateway (authentication, quota, schema, safety, telemetry)
                     │
                     ▼
Gemini on Vertex AI
```

의존 방향은 UI → application/domain ← data/infrastructure다. Flutter 위젯, DB 모델, Vertex 응답 타입이 서로 직접 퍼지지 않게 repository/adapter 경계에서 변환한다. 작은 MVP에서 계층마다 파일을 기계적으로 만들지는 않는다.

## 7. 코드 지도

현재 존재하는 진입점과 다음 increment의 목표 구조다. 없는 경로를 구현된 것으로 해석하지 않는다.

```text
apps/mobile/
  pubspec.yaml             # 채택한 Flutter/Dart 의존성 선언; lockfile 커밋 대상
  android/                 # Flutter 생성 Android host
  ios/                     # Flutter 생성 iOS host
  web/                     # Flutter 생성 호스트. 비영속 개발 검토용이며 공개 web profile이 아님
  lib/
    main.dart              # 실제 entry point; platform composition bootstrap 실행
    l10n/                  # 구현됨: locale당 270개 ARB message, gen_l10n 코드, locale resolver·날짜/숫자 formatter
    app/app_dependencies.dart # web transient/native Drift dependency graph와 DB lifecycle 소유
    app/namu_app.dart      # theme와 오늘 UI shell; 테스트 기본값은 in-memory 주입 유지
    core/database/         # 구현됨: Drift schema v3 메시지+일기+media+persona+memory 및 v1/v2→v3 migration
    core/network/          # 구현됨: Gateway config, bounded/cancellable HTTP transport, UTF-8 request/response budget, typed/redacted 오류 mapper
    core/storage/          # 구현됨: MethodChannel 기반 backup 제외 native 저장 root
    core/time/             # 구현됨: LocalDate, TimeZoneSnapshot, DiaryDayKey v1, native IANA ID + instant offset resolver, web preview fallback
    features/
      chat/                # 구현됨: Message, local-first use case/controller/UI, strict HTTP Gateway adapter
      consent/             # 구현됨: AI 데이터 전송 동의 model/controller, native backup-excluded 파일 저장, web transient adapter, Gateway decorator와 설정 UI
      onboarding/          # 구현됨: 로컬 저장·복구 불가·AI 정체성 고지, AI 전송 동의와 분리된 versioned 완료 상태
      diary/               # 구현됨: 출력 v1 model/decoder/domain, Drift 저장, 4:5 다중 page preview, 실제 사진·수동 날씨 편집·생성·확정 UI, foreground 보정+in-process 자정 자동 초안과 앱 composition
      media/               # 구현됨: 사진 domain/import/delete, gallery selector, backup-excluded native file adapter, 선택→import coordinator, Drift adapter, ID→ready metadata→bytes resolver와 안전한 preview widget
      today/               # 구현됨: 반응형 오늘 화면과 실제 local-first chat/diary/persona/photo interaction
      archive/             # 구현됨: 날짜·기분·한 줄 요약 AND token 로컬 검색, 오류복구, 모든 version 보존, 과거 일기 재열람 UI
      memory/              # 구현됨: 기억 model/use cases + memory source codec + transient/Drift repository, 일기 후보 변환과 사용자 승인·편집·삭제·개별 사용 중지/재사용 UI 및 앱 shell 연결
      persona/             # 구현됨: AI 프로필 model/controller/transient/Drift repository, 이름·말투·지침·반응 길이·4개 code-native avatar preset 설정
      settings/            # 부분 구현: AI·기억 진입, 안전한 전체 로컬 삭제, versioned JSON 수동 내보내기 완료. 사진 bundle 정책과 provider 날씨·광고·권한 설정은 미정
      share/               # 구현됨: 1080×1350 다중 PNG renderer, 사진 재인코딩, export/OS share 경계·검증·share_plus adapter와 일기 UI 연결
  test/app/namu_app_test.dart # 앱 shell smoke test
  test/core/time/          # 구현됨: 자정/DST 경계·identity·native timezone 초기화·갱신·실패 검증
  test/features/chat/      # 구현됨: local-first·실패·idempotent retry·날짜 조회 계약
  test/features/diary/     # 구현됨: v1 decode와 거부 경계 계약
services/ai_gateway/       # 구현됨: Cloud Run Node 22/TypeScript, Vertex Gemini, strict schema/auth/quota/idempotency/safety 경계
contracts/
  diary_generation/        # 구현됨: Gemini 일기 출력 v1 JSON Schema
docs/                      # ADR, API 계약, 운영 문서가 필요해질 때만
result reports/           # phase별 A/C/D 보고서
```

Flutter 생성 platform 파일, Flutter `gen_l10n` 결과와 Drift/build_runner 생성 파일은 version control 대상이다. 이 세 도구 외에 프로젝트 자체의 별도 code generator는 없다. 새 최상위 디렉터리나 핵심 패턴을 도입하면 이 지도를 먼저 갱신한다.

오늘 UI는 실제 repository/controller 상태를 표시하며 sample fixture를 만들지 않는다. native production은 Drift와 앱 전용 media 파일에 저장하고, browser preview는 재실행 시 사라지는 transient adapter임을 전제로 한다. `web/`은 실제 `lib/main.dart`를 브라우저에서 확인하기 위한 Flutter 호스트일 뿐이며 제품 배포 표면, 공개 web profile, cloud sync/backup/restore가 아니다. Gemini는 Gateway URL·인증이 설정된 경우에만 호출하며, 설정이 없으면 로컬 메시지를 실패 상태로 보존한다. 데스크톱 폭은 대화와 일기를 함께 보여주고 모바일 폭은 화면을 전환한다.
대화 목록이 저장·복원된 뒤에는 같은 날짜의 일기 source snapshot을 갱신하므로, 넓은 화면에서도 첫 메시지 직후 수동 일기 생성 버튼이 활성화된다.

### Phase 1에서 확정한 구현 경계

- repository·domain·application을 UI와 분리해 로컬 저장, 실패 복구, 중복 방지를 테스트하는 경계를 채택했다.
- DEC-04 spike를 거쳐 모바일 영속 저장과 사진 파일은 현재 코드 지도의 한 가지 방식으로 채택했다. 브라우저는 제품 배포 대상이 아니라 검토 surface다.
- AI는 `ChatReplyGateway`와 일기 generation port 뒤에 둔다. Gateway URL이 없을 때 가짜 AI 성공을 만들지 않고 연결 필요 상태를 표시한다.
- 공유는 사용자가 누른 뒤 OS 공유 화면을 여는 것까지만 성공으로 기록한다.
- 외부 계정·키·광고 ID가 없으면 adapter와 설정 검증까지 구현하고 실제 과금/게시 성공을 주장하지 않는다.

### 채택한 저장 도구와 생성 규칙

- runtime: `flutter_localizations`(SDK), `drift`, `drift_flutter`, `path_provider`, `path`, `http`(Gateway client), `image_picker`(사용자 주도 gallery 선택), `share_plus`(OS 공유 화면), `timezone`(native IANA ID의 시각별 UTC offset 계산용 bundled tzdata)
- development: `drift_dev`, `build_runner`
- 생성: `cd apps/mobile && dart run build_runner build --delete-conflicting-outputs`
- localization 생성: `cd apps/mobile && flutter gen-l10n`; `lib/l10n/app_*.arb`가 원본이고 생성된 `app_localizations*.dart`도 version control에 둔다.
- migration snapshot/step 생성: schemaVersion을 올린 뒤 `dart run drift_dev make-migrations`
- 생성된 `*.g.dart`, `drift_schemas/`, migration step/test는 원본과 함께 version control에 둔다. 직접 수정하지 않는다.
- 모바일 DB와 media root는 cloud backup·device transfer에서 제외한다. web preview에는 Drift/IndexedDB를 만들지 않는다.
- production bootstrap은 `kIsWeb`에서 명시적 in-memory repository graph를 만들고, native에서는 하나의 `AppDatabase`를 다섯 Drift repository가 공유한다. AI 동의와 온보딩 완료 repository는 web에서 transient memory, native에서 같은 backup-excluded root의 서로 다른 versioned JSON 파일을 사용한다. bootstrap은 자정 coordinator/foreground observer를 먼저 종료한 뒤 owned native DB를 닫는다.
- native 저장 root는 `namu/storage` MethodChannel로 얻는다. Android는 `noBackupFilesDir`, iOS는 Application Support 하위 Namu 경로에 backup 제외 resource flag를 매번 확인한다. web에서는 typed unavailable이며 영속 파일처럼 가장하지 않는다.
- 기록 JSON 수동 내보내기 v1은 native에서만 사용자가 확인 dialog를 거쳐 실행한다. 대화·일기·참조 사진 metadata·persona·기억·AI 전송 동의를 backup 제외 root의 `exports/data`에 원자적으로 staging한 뒤 OS 공유/저장 화면을 연다. 이 JSON은 복원 format이 아니며 photo bytes·storage key·게시용 render는 포함하지 않는다. browser review에서는 내보내기를 비활성화한다.
- 전체 로컬 데이터 삭제는 native에서 실행 중인 coordinator/controller와 DB를 먼저 닫고, symlink와 허용 root를 검증한 뒤 backup 제외 앱 저장 root 전체를 지우고 새 dependency graph를 만든다. DB/WAL, 메시지·일기·사진·persona·기억·내부 export·동의·온보딩이 대상이며 앱 밖으로 공유한 사본은 회수하지 못한다. web review에서는 transient graph만 새로 만든다.
- 현재 DB schema version은 3다. `messages`는 ID PK와 `(requestId, role)` unique, 전체 `DiaryDayKey`, UTC microseconds, 상태/content CHECK를 저장한다. `diary_entries`는 generation ID와 정확한 `(dayKey, version)` unique, full v1 snapshot JSON, 상태/UTC CHECK를 저장한다. `media_assets`, singleton `ai_personas`, `memory_facts`도 제약과 index를 갖고 저장한다. migration은 `lib/core/database/app_database.steps.dart`, snapshots는 `drift_schemas/app_database/`에 있고 generated verifier와 실제 v1/v2 file reopen test가 v3 보존을 검증한다.
- chat repository는 해당 `DiaryDayKey`의 중단된 전송을 load 전에 복구한다. 같은 `requestId`의 assistant 응답이 이미 저장된 `pending` user는 `sent`로 맞추고, 응답이 없는 `pending` user는 원본·ID·idempotency request ID를 유지한 `failed`로 바꿔 사용자가 재시도할 수 있게 한다. 복구 자체는 Gateway를 호출하지 않는다.
- 지원 하한은 Android API 24, iOS 15다. `image_picker`는 gallery 선택만 사용하며 앱이 카메라·음성·동영상 기능을 추가한다는 뜻이 아니다.
- Android release manifest는 AI Gateway 연결에 필요한 `android.permission.INTERNET`만 선언한다. 사진은 system picker를 사용하므로 광범위한 media storage 권한을 선언하지 않는다.
- `PhotoSelector` → `ImagePickerPhotoSelector`는 gallery 단일 선택만 노출한다. 취소는 `null`, 선택된 `XFile.path`는 native adapter만 해석하는 opaque token이며 application에는 MIME/byte length만 함께 전달한다. web 선택/영속 저장은 typed unavailable이다.

### Chat Gateway request v2 / output v1 client 계약

- base URL은 compile-time `NAMU_GATEWAY_BASE_URL` 또는 명시적 주입으로만 설정한다. 기본 URL을 추측하지 않는다.
- `POST /v1/chat/reply`, request JSON `schemaVersion: 2`, `Idempotency-Key`를 사용한다. endpoint의 `/v1`과 응답 `schemaVersion: 1`은 유지한다.
- request에는 필수 `responseLocale`과 request/message ID, text/photo asset ID, UTC instant, 전체 `DiaryDayKey` identity, 현재 persona, 제한된 최근 대화, 사용자가 승인한 활성 기억만 담는다. 앱은 요청 직전에 기기 locale을 다시 읽어 `ko`/`en`/`ja`/`zh-Hans`/`es` 중 하나를 보내며, 사용자 콘텐츠·persona·기억·locale은 모두 untrusted data다.
- 최근 대화는 현재 요청을 제외하고 UTC/ID 순으로 정렬해 최대 30개, 활성 기억은 수정 시각 최신순 최대 20개만 전송한다. candidate/inactive 기억과 로컬 경로는 전송하지 않는다.
- auth·app attestation header는 주입 provider가 만들며 저장하거나 log하지 않는다. 고정 content/idempotency header를 덮어쓸 수 없다.
- response는 schemaVersion/messageId/text/createdAtUtc의 정확한 필드만 허용하고 status·JSON 오류를 typed category로 변환한다. raw body를 오류 문구나 log에 넣지 않는다.
- 공용 HTTP transport는 Chat 20초/Diary 30초의 전체 요청·stream deadline, 실제 요청 abort, 기본 256 KiB response 상한, JSON MIME 검증, 자격 증명 header allowlist를 적용한다. transport 자체는 자동 재시도하지 않으며 서버의 안정적인 공개 code와 상한이 있는 `Retry-After`만 typed 오류로 노출한다.
- chat·diary 화면은 typed Gateway 오류를 원문 없이 현재 UI locale의 안전한 안내로 바꾼다. 안전 차단은 모델 안전 기준에 따른 차단으로만 설명하고, 로컬 원본 보존과 가능한 재시도 시점을 함께 알린다.
- HTTPS만 허용하며 loopback HTTP는 명시적인 개발 opt-in에서만 허용한다.
- 실제 로컬 Gateway 계약 확인은 loopback URL과 `NAMU_DEVELOPMENT_PRINCIPAL`이 함께 지정된 경우에만 development auth marker를 보낸다. 이 marker는 로컬 전용이며 production 인증을 대체하지 않는다.
- chat request JSON은 기본 UTF-8 256 KiB 이하만 허용한다. 초과 요청은 auth provider와 network 호출 전에 `requestTooLarge`로 거부하고, 서버 413도 같은 typed category로 변환한다. 배포 Gateway 한도와 client 주입값은 반드시 일치시킨다.

### Diary Gateway request v2 / output v1 client 계약

- `POST /v1/diary/generate`, request JSON `schemaVersion: 2`, `Idempotency-Key=generationId`를 사용한다. endpoint의 `/v1`과 일기 생성 출력 `schemaVersion: 1`은 유지한다.
- request는 필수 `responseLocale`, generationId, 전체 `DiaryDayKey`, 앱 기준 `WeatherSnapshot`, 현재 `AiPersona`, 그 날짜의 정렬된 message snapshot을 보낸다. runtime locale은 각 수동·자동 생성 요청 직전에 다시 읽으며, message에는 ID/role/text/photo asset ID/UTC 시각만 있고 로컬 경로는 절대 넣지 않는다.
- response body는 `contracts/diary_generation/v1.schema.json`의 생성 결과 자체이며, 앱 decoder가 exact fields와 허용 photo/source ID를 다시 검증한다. 날짜·날씨는 response에서 받지 않는다.
- 사진 bytes 전송·분석은 별도 동의와 크기/EXIF 파생본 경계가 준비되기 전에는 하지 않는다. opaque photo ID만으로 모델이 사진 내용을 안다고 가장하지 않으며 대화 내 순서 배치에만 사용할 수 있다.
- chat과 같은 HTTPS/auth/attestation/redaction/typed 오류 규칙을 적용하며 raw request/response나 사용자 원문을 log하지 않는다.
- diary request에도 같은 기본 UTF-8 256 KiB 사전 한도와 413 typed mapping을 적용한다.

### AI 데이터 전송 동의 경계

- 현재 정책 버전에 명시적으로 동의하기 전에는 chat reply와 diary generation Gateway decorator가 호출을 거부한다. 화면 gate는 설명 UX이며 보안 경계 자체가 아니다.
- native 동의 상태는 DB가 아닌 같은 backup-excluded 앱 저장 root의 작은 JSON 파일에 저장한다. web review는 재실행 시 사라지는 in-memory 상태만 사용한다.
- 철회 뒤에는 새 AI 호출을 차단한다. 로컬 대화·일기·사진은 삭제하지 않으며, 전체 데이터 삭제와는 별도 동작이다.
- 현재 AI request에는 텍스트, persona, 제한된 대화/승인 기억, 사진의 opaque ID·메타데이터만 포함되고 사진 bytes는 보내지 않는다. 정책 문구와 실제 payload가 달라지면 policy version과 동의 화면을 함께 갱신한다.

### 최초 실행 온보딩 경계

- 온보딩 완료와 AI 데이터 전송 동의는 별도 상태다. 사용자는 동의를 결정하지 않은 상태로 온보딩을 마치고 로컬 기록만 사용할 수 있다.
- 온보딩은 기기 로컬 저장과 cloud sync/backup·다기기 복원 미제공, 앱 삭제·기기 분실 뒤 복구 불가, AI가 사람이 아닌 생성형 모델이며 오류할 수 있음, 동의 시 전송되는 최소 데이터를 명시한다.
- native 완료 상태는 AI 동의와 같은 backup-excluded 저장 root의 versioned JSON으로, web review는 재실행 시 사라지는 in-memory 상태로 관리한다. 전체 로컬 데이터 삭제는 둘 다 초기화한다.

### 전체 로컬 데이터 삭제 경계

- native 삭제는 실행 중인 자정/foreground 작업, controller, HTTP client와 DB를 먼저 닫은 뒤 backup 제외 앱 저장 root 전체를 지우고 fresh dependency graph를 만든다.
- 삭제 대상 root는 절대 경로와 충분한 깊이, 실제 directory 여부를 검사한다. symlink를 따라가지 않고 broad/unsafe root나 알 수 없는 filesystem entry는 삭제 대신 거부한다.
- web review는 transient graph만 초기화하며 기기 파일 삭제처럼 표현하지 않는다. 앱 밖으로 공유한 export 사본은 회수할 수 없다.
- 이 기능은 앱이 소유한 데이터의 logical deletion이다. flash 저장장치의 forensic recovery 방지나 cryptographic erase를 보장하지 않으며, 외부 beta 전 DEC-04 위협 모델에서 앱 계층 암호화와 key lifecycle을 별도로 결정한다.

### UI 현지화 경계

- 초기 지원 UI locale은 한국어 `ko`, 영어 `en`, 일본어 `ja`, 중국어 간체 `zh-Hans`, 스페인어 `es`다. 기기 locale을 우선하며 미지원 언어와 중국어 번체는 영어로 fallback한다.
- `app_en.arb`, `app_ko.arb`, `app_ja.arb`, `app_zh.arb`, `app_es.arb`는 각각 같은 270개 message를 가지며 Flutter `gen_l10n`으로 생성한다. Flutter의 language-only `zh` catalog는 제품의 `zh-Hans`를 제공하기 위한 것이고 resolver가 `zh-Hant`·TW·HK·MO를 영어 fallback으로 막는다.
- 앱 문구, 접근성 label, 오류·동의·삭제 안내, 공유 PNG·caption과 export 안내는 ARB와 Flutter localization delegate를 사용한다. 날짜·숫자·섭씨 표시는 locale formatter를 쓰고 스페인어의 쉼표 소수 입력도 허용한다. protocol enum, schema field, ID, 저장된 날짜 key는 번역하지 않는다.
- 사용자가 쓴 대화·일기·기억, AI 생성 결과와 이미 저장된 persona 값은 언어 전환 시 자동 번역하지 않는다. 새 persona가 아직 저장되지 않았을 때만 최초 기기 locale의 이름·말투 seed를 쓰며, 이후에는 사용자 데이터로 취급한다.
- Chat·Diary request는 요청 때마다 runtime locale을 읽고 request v2의 필수 `responseLocale`으로 보낸다. Gateway는 allowlist로 검증한 고정 서버 지시만 사용해 자연어 응답 언어를 정하며, 출력 JSON의 field·enum·ID와 output schema v1은 번역하거나 바꾸지 않는다.
- 안전·개인정보 문구는 의미를 줄이거나 기능을 과장하지 않는다. 제품의 영구 비목표와 사진 원본 미전송, 로컬 저장·복구 불가, 공유 화면까지만 여는 경계를 모든 locale에서 동일하게 유지한다.

## 8. 핵심 도메인과 불변식

| 모델 | 역할 | 지켜야 할 것 |
|---|---|---|
| `DiaryDayKey` | 사용자 기준 하루 | label date, 당시 timezone, cutoff(초기 00:00), policy version을 함께 고정한다 |
| `Message` | 사용자/AI 메시지 | 저장 후 전송하며 실패 상태도 보존한다 |
| `MediaAsset` | 앱이 관리하는 사진 | AI에는 로컬 경로 대신 opaque ID를 전달한다 |
| `DiaryEntry` | 하루 일기 snapshot | 같은 날짜에 기본 1개, 재생성은 version으로 추적한다 |
| `DiaryBlock` | text 또는 photo 순서 블록 | photo는 반드시 같은 날의 유효한 asset ID만 참조한다 |
| `MemoryFact` | 다음 대화용 핵심 기억 | 원문 출처, 상태, 수정 시각을 갖고 사용자가 삭제 가능하다 |
| `AiPersona` | AI 이름·프로필·말투 | 안전 지침보다 우선할 수 없다 |

필수 불변식:

- 날짜 경계와 자동 생성은 `DiaryDayKey`를 사용해 시간대 변경, 서머타임, 중복 실행에도 같은 하루를 두 번 만들지 않아야 한다.
- AI 응답이 모르는 사진 ID를 반환하면 저장하지 않는다.
- 일기 삭제 시 파생 렌더 파일과 참조되지 않는 사진의 정리 여부를 함께 처리한다.
- 원본 메시지 수정/삭제가 기존 일기에 미치는 정책은 사용자에게 명확히 보인다. 기본은 생성된 일기를 snapshot으로 유지하는 것이다.
- 공유는 성공 여부를 앱이 확정할 수 없다고 가정한다. “Instagram에 게시됨”이 아니라 “공유 화면을 열었음”만 기록한다.

## 9. 핵심 흐름

### 메시지와 사진

1. 입력을 로컬 DB에 `pending`으로 저장한다.
2. 사진은 앱 전용 저장소로 복사하고 방향·크기 메타데이터를 정규화한다.
3. 화면은 opaque asset ID를 로컬 media metadata에서 해석한 뒤 `ready` 앱 소유 파일의 bytes만 읽어 크기를 제한해 표시한다. 삭제·손상·미지원 환경에서는 콘텐츠를 노출하지 않는 placeholder를 쓴다.
4. AI Gateway에는 현재 메시지, 제한된 최근 맥락, 관련 기억, 필요한 사진만 보낸다.
5. 응답을 저장하고 `sent`/`failed` 상태를 갱신한다. 재시도는 같은 요청 ID를 사용한다.
6. 재시작 load에서 남은 `pending` user를 점검한다. assistant가 이미 있으면 user만 `sent`로 마무리하고, 없으면 `failed`로 표시해 명시적 재시도를 제공한다.

### 하루 마감

1. `DiaryDayKey`에 속한 메시지와 사진을 시간순으로 고정한다.
2. 이미 성공한 generation key가 있는지 확인한다.
3. 검증된 날짜와 `WeatherSnapshot`을 입력으로 주고, Gemini에는 versioned JSON 계약으로 본문·기분·기억 후보를 요청한다.
4. 앱/서버가 schema, 길이, 사진 ID를 검증하고 날짜·날씨는 앱의 기준값으로 조립한다.
5. 유효한 `DiaryEntry`를 먼저 저장한 뒤 공유용 이미지를 렌더링한다.
6. 실패하면 원본 대화는 그대로 두고 다음 foreground에서 안전하게 재시도한다.
7. 실행 중에는 다음 로컬 00:00을 one-shot timer로 best-effort 처리하고, 시작·foreground마다 메시지가 있지만 일기가 없는 과거 날짜를 오래된 순서로 보정한다. 모바일 OS가 background 정각 실행을 보장한다고 가정하지 않는다.
8. 자동 생성 ID는 전체 `DiaryDayKey`에서 결정적으로 만들며, 네트워크·저장 실패 뒤 앱을 다시 시작해도 같은 idempotency key로 재시도한다. 동시 보정은 하나만 실행한다.
9. 자정 schedule의 production timezone resolver는 Android `TimeZone.getDefault().id` / iOS `TimeZone.current.identifier`를 MethodChannel로 초기화·foreground 갱신하고, bundled IANA tzdata로 시각별 UTC offset을 계산한다. `DateTime.timeZoneName`의 EST/EDT 같은 약어를 영속 ID로 쓰지 않는다. Browser preview fallback ID는 IANA ID가 아님을 코드와 문서에 명시하고 영속 제품 adapter로 취급하지 않는다.
10. 시작·foreground·자정 timer가 새 활성 `DiaryDayKey`를 감지하면 UI의 대화/일기 controller도 즉시 같은 날짜로 회전시킨다. 보정 생성 성공 여부가 날짜 전환을 막아서는 안 된다.

### 기억

1. AI가 짧은 후보를 만들되 민감정보는 기본 자동 기억에서 제외한다.
2. 중복·모순을 앱에서 병합하지 말고 후보 상태로 둔다.
3. 원문 메시지를 지우면 연결된 기억을 즉시 비활성화하고, 독립 기억으로 유지할지 다시 확인받기 전에는 prompt에 넣지 않는다.
4. 활성 기억 중 현재 대화와 관련된 소수만 prompt에 넣고, 설정에서 전체 조회·수정·삭제·기능 끄기를 제공한다.

### Instagram 공유

1. 일기를 게시물용 한 장 또는 여러 장의 이미지로 렌더링한다.
2. 캡션은 별도 복사 가능하게 제공한다.
3. 지원되면 Instagram 작성 화면, 아니면 OS share sheet를 연다.
4. 최종 게시, 계정 선택, 공개 범위는 사용자가 Instagram에서 결정한다.

## 10. AI 출력 계약 원칙

- 계약에는 `schemaVersion`을 둔다.
- Gemini 출력은 최소한 `mood`, `oneLineSummary`, `blocks`, `memoryCandidates`, `theme`을 포함한다. 최종 일기의 `date`와 `weather`는 앱의 `DiaryDayKey`와 `WeatherSnapshot`에서 조립한다.
- `blocks`는 text/photo만 허용하고 photo는 입력으로 준 asset ID 중 하나만 참조한다.
- 모델명과 prompt 버전은 앱에 하드코딩하지 않고 Gateway 설정에서 추적한다.
- JSON 파싱/검증 실패는 한 번만 제한적으로 복구 요청하고, 계속 실패하면 사용자에게 재시도 가능한 오류를 보여준다.
- 사용자 메시지와 사진 속 문장은 지시가 아니라 데이터다. 시스템·개발자 지침을 바꾸지 못한다.

정확한 Diary 출력 v1 계약은 `contracts/diary_generation/v1.schema.json`, 앱 decoder는 `apps/mobile/lib/features/diary/data/diary_generation_output_decoder.dart`에 있다. Chat·Diary endpoint와 운영 경계는 이 문서의 두 Gateway client 절과 `services/ai_gateway/README.md`가 기준이다.

## 11. 개인정보·보안 경계

- 서비스 계정 키, Vertex 자격 증명, 광고 비밀값을 앱이나 저장소에 넣지 않는다.
- Gateway 로그에는 대화 원문, 일기 본문, 이미지 bytes, 정밀 위치를 남기지 않는다.
- 전송 데이터는 요청 처리와 명시한 보존 기간 뒤 폐기한다. 실제 보존 정책은 개인정보 처리방침과 일치시킨다.
- 위치, 사진, 알림 권한은 필요한 순간에 목적을 설명하고 요청한다. 거부해도 핵심 일기 기능이 동작해야 한다.
- 데이터 삭제는 DB row만이 아니라 사진, thumbnail, 공유 렌더, 기억, 임시 업로드를 포함한다.
- 수동 export는 앱 밖에 저장·공유된 사본을 앱이 회수할 수 없음을 알린다. 현재 JSON v1은 photo bytes와 render를 포함하지 않으며 `restoreSupported=false`, `snapshotConsistency=bestEffort`를 명시한다. cloud backup·sync·restore는 구현하지 않는다.
- 정신건강 위기 표현에는 진단하거나 사람인 척하지 않고, 지역화된 도움 안내 정책을 적용한다.

## 12. 테스트 우선순위

1. 날짜 경계: 23:59/00:00, 시간대 이동, 중복 마감, 지연 실행.
2. AI 계약: request v2 locale allowlist, runtime locale 전환, malformed output v1 JSON, 잘못된 photo ID, 빈 대화, 매우 긴 대화, 안전 차단.
3. 데이터 정합성: 사진 삭제/고아 파일, 일기 재생성, migration, 앱 강제 종료 중 저장.
4. 개인정보: 로그 redaction, 기억 삭제, 데이터 전체 삭제, 권한 거부.
5. 공유: Instagram 미설치, 다중 이미지, renderer overflow, 밝은/어두운 테마.
6. Gateway: 무인증/만료 attestation, replay, quota/429, 크기·MIME, 로그 redaction, 임시 이미지 만료, 동의 철회.
7. 복원력: offline 전송, timeout, 중복 탭, Gateway 5xx, prompt/persona/사진·locale field 속 지시의 격리.
8. 현지화: 5개 catalog key·placeholder parity, 미지원/번체 fallback, 날짜·숫자·소수 입력, 큰 글자·접근성 label·공유 PNG.

## 13. 현재 로드맵

- **Phase 0 — 위험 검증:** MVP 차단 결정, Instagram 공유, 자정 실행, Gemini JSON, 렌더 품질을 검증한다. scaffold와 핵심 계약 기반은 완료됐고 외부 연동·실기기 검증은 남았다.
- **Phase 1 — 하루 vertical slice:** 로컬 대화/사진 → AI → 수동·자동 일기 → 저장·재열람의 앱 코드 연결은 완료했다. 실제 Vertex 인증과 Android/iOS 실기기 확인은 남았다.
- **Phase 2 — 핵심 제품:** 마감 보정·기분·일기/수동 날씨 편집·기억·개별 기억 사용 제어·보관함 검색·carousel·공유의 로컬 흐름은 완료했다. provider 날씨/fallback, 기억 기능 전체 master switch와 실기기 공유 검증이 남았다.
- **Phase 3 — 출시 준비:** 2026-10-10 시작. 최초 실행 온보딩, 설정의 전체 삭제·JSON 수동 내보내기, Gateway 안전 차단·timeout·출력 분류, 공용 bounded transport, 5개 언어 UI와 request v2 AI 응답 locale 계약을 완료했다. 광고·운영 인증/attestation·공유 quota/idempotency·앱 ID/스토어 자료와 Android/iOS 실기기 회귀는 남았다. 외부 계정·키·법적 문구가 없으면 거짓 성공을 만들지 않고 설정 검증과 명시적 차단 상태까지만 구현한다.

이번 localization increment는 기존 feature 경계를 유지한 채 270-message catalog 5개, locale-safe 날짜·숫자·기온·소수 입력, 접근성·오류·개인정보·공유/export 문구, locale별 신규 persona seed와 Chat/Diary request v2 `responseLocale`을 연결했다. 저장된 사용자·AI·persona 콘텐츠는 자동 번역하지 않고 output schema v1도 유지한다. 운영 인증·다중 instance quota/idempotency는 DEC-03·DEC-13과 shared backend/보존 정책이 정해질 때까지 production deny-all 경계를 유지한다. 배너 광고와 provider 날씨도 DEC-01·DEC-06·DEC-09가 정해지기 전에는 임의 provider나 동의 문구를 넣지 않는다.

Phase가 끝나면 `prompt.md` 형식에 따라 `result reports/`에 A/C/D만 기록한다.

## 14. AI 작업자가 남겨야 할 최신 정보

구현 후 이 문서의 다음 항목이 항상 사실이어야 한다.

- 현재 phase와 완료/진행/차단 상태
- 실제 실행·테스트 명령
- 실제 디렉터리 지도와 핵심 entry point
- 채택한 의존성 및 바꾼 결정 ID
- DB schema/version과 migration 위치
- AI schema/prompt 버전과 위치
- 알려진 critical risk 및 다음 한 작업

세부 구현 설명이나 긴 변경 이력은 이 문서에 쌓지 않는다. 이 문서는 지도이며, 정확한 계약·ADR·phase 보고서로 링크한다.
