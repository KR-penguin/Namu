# Namu 남은 작업

> 기준일: 2026-10-12 · 범위: 현재 저장소와 승인된 제품 범위의 구현·출시 잔여 작업 · 상태: `[ ]` 미완료, `[x]` 근거 확인 완료

이 문서는 남은 작업의 단일 추적 문서다. 제품 범위와 결정 근거는 [`PROJECT_PLAN.md`](PROJECT_PLAN.md), 현재 구조와 진입점은 [`AI_README.md`](AI_README.md)를 따른다.
항목을 완료 처리할 때는 코드, 테스트, 실기기 결과 또는 운영 설정처럼 재확인 가능한 근거를 함께 남긴다.

## 1. 현재 기준선

다음은 이미 구현·검증된 범위다. 회귀가 발견되지 않는 한 새 작업으로 되돌리지 않는다.

- [x] Flutter Android/iOS scaffold와 Drift schema v3 migration
- [x] local-first 대화, 사진 보관·preview, 일기 생성·편집·보관·검색
- [x] persona와 승인된 기억의 제한적 prompt 주입
- [x] 다중 4:5 PNG 렌더링과 OS share sheet 연결
- [x] 자정 in-process timer와 foreground 미생성 일기 보정
- [x] 온보딩, AI 전송 동의·철회, 전체 로컬 삭제, JSON v1 내보내기
- [x] `ko`, `en`, `ja`, `zh-Hans`, `es` UI와 AI 응답 locale 계약
- [x] 2026-10-12 Flutter analyze 0 issue, Flutter test 502개, web release build 통과
- [x] 2026-10-12 Gateway test 41개, typecheck, production build, npm audit 통과
- [ ] Android release build 및 실기기 검증
- [ ] iOS archive 및 실기기 검증

현재 production Gateway는 의도적으로 요청을 거부하며 개발 인증 marker는 loopback 환경 전용이다.
현재 JSON export에는 사진 원본과 렌더 이미지가 없고 restore도 지원하지 않는다.

## 2. 우선순위

| 우선순위 | 의미 |
|---|---|
| P0 | 외부 beta 전에 끝나야 하는 보안·배포·실기기 차단 항목 |
| P1 | 핵심 제품 약속을 완성하는 기능과 데이터 정합성 |
| P2 | 공개 출시의 품질·운영·스토어 준비 |
| P3 | 출시 후 사용량 근거로 개선해도 되는 확장·최적화 |

## 3. P0 — 외부 beta 차단 항목

### P0-1. 열린 결정과 실제 제품 식별자 확정

의존성: 제품 책임자 결정, 출시 국가, Apple Developer·Play Console 계정.

- [ ] DEC-01: 최초 출시 국가와 최소 연령, 청소년 안전 범위를 확정한다.
- [ ] DEC-03: 익명 사용자 식별, Gateway 인증, attestation, quota 정책을 확정한다.
- [ ] DEC-13: 제품명과 Android application ID/iOS bundle ID를 확정한다.
- [ ] DEC-04 후속: DB·사진의 앱 계층 암호화와 key lifecycle 위협 모델을 검토하고 구현 또는 명시적 risk acceptance를 기록한다.
- [ ] DEC-05 운영값: Cloud Run/Vertex region, Gemini model, 요청 임시 데이터 보존 시간을 정한다.

완료 조건: 결정 register에 날짜·근거·담당자가 남고, 코드와 운영 문서가 같은 값을 참조하며 placeholder인 `com.example.namu`가 release 설정에 남지 않는다.

### P0-2. 모바일 release 기반

의존성: P0-1, 양대 스토어 계정과 인증서.

- [ ] Android/iOS에 최종 app ID, display name, version을 적용한다.
- [ ] Android debug signing을 release signing/Play App Signing으로 교체한다.
- [ ] iOS Team, provisioning, distribution signing을 설정한다.
- [ ] launcher icon, splash, 5개 언어의 앱 이름·사진 권한 문구를 적용한다.
- [ ] 필요한 iOS privacy manifest와 Android manifest 권한을 검토한다.

완료 조건: 깨끗한 checkout에서 release AAB와 iOS archive를 만들고 실제 기기에
설치·실행한다. 비밀 키와 인증서는 저장소에 들어가지 않는다.

### P0-3. production Gateway와 실제 Gemini 연결

의존성: DEC-03·DEC-05, GCP billing/project, Vertex API, shared data backend.

- [ ] GCP dev/stage/prod project와 최소 권한 service account를 구성한다.
- [ ] 앱의 익명 identity token을 OS secure storage에 보관하고 Gateway가 검증한다.
- [ ] Firebase App Check/Play Integrity/App Attest 또는 동등한 무결성 검증을 연결한다.
- [ ] process-local quota와 idempotency를 TTL·원자 CAS를 지원하는 shared backend로
      교체하고 사용자·일 단위 비용 상한을 둔다.
- [ ] Cloud Run stage/prod 배포, TLS, secret/env, Vertex model/region을 설정한다.
- [ ] 원문·사진·정밀 위치가 로그에 남지 않는지 staging에서 검증한다.
- [ ] revoke, 만료·위조 token, replay, 429, timeout, Vertex 5xx를 검증한다.

완료 조건: release 앱 → staging Gateway → Vertex의 chat/diary 실 E2E가 통과하고,
다중 instance와 재시작 후에도 quota·idempotency가 유지된다. production의 개발 bypass는
계속 차단된다.

### P0-4. 안전·개인정보·법적 공개물

의존성: DEC-01, 법적 검토, 실제 provider와 보존 정책.

- [ ] 5개 언어와 출시 지역에 맞는 위기 도움 경로를 client의 deterministic UI로
      제공하고, 모델 응답이 차단되거나 실패해도 노출되게 한다.
- [ ] 개인정보 처리방침, 이용약관, support URL, 데이터 보존·삭제 정책을 확정한다.
- [ ] AI, 사진 분석, 위치, 광고 동의를 목적별로 분리하고 철회 경로를 검증한다.
- [ ] App Store privacy nutrition label과 Play Data safety 답변을 실제 구현과 맞춘다.
- [ ] 전체 삭제가 DB, 사진, thumbnail, 공유/export 임시 파일, 기억, 서버 임시본을
      빠짐없이 처리하는지 검증한다.

완료 조건: 5개 언어 문구 검토와 privacy checklist가 승인되고, 민감 payload가 log,
analytics, crash report에 들어가지 않는 자동 검사가 통과한다.

### P0-5. Android/iOS 실기기 E2E

의존성: P0-2·P0-3, Android SDK/기기, macOS·Xcode·iPhone.

- [ ] API 24+ Android와 iOS 15+에서 onboarding → consent → 사진 → 실제 AI →
      수동/자동 일기 → 편집 → 보관 → 공유 → export → 삭제 흐름을 통과한다.
- [ ] 5개 locale 전환, 큰 글자, screen reader, 잘림, 대비, touch target을 확인한다.
- [ ] JPEG/PNG/HEIC, 회전 정보, 누락·손상 사진, 권한 거부를 확인한다.
- [ ] 앱 강제 종료, offline, timeout, 5xx, low-disk에서 데이터가 깨지지 않게 한다.
- [ ] 23:59/00:00, DST, 시간대 이동, 수동 시계 변경, 여러 날 미실행을 검증한다.
- [ ] 단일·다중 이미지, caption, 취소, Instagram 설치/미설치, OS fallback을 검증한다.
- [ ] OS backup/device transfer 제외와 앱 밖으로 만든 사본의 삭제 한계를 확인한다.

완료 조건: 양 플랫폼 release build의 device matrix 결과, 발견 이슈, 재검증 근거가
기록되고 P0/P1 데이터 유실·개인정보 결함이 0개다.

### P0-6. 필수 CI

- [ ] PR마다 Flutter dependency fetch, analyze, test, web build를 실행한다.
- [ ] PR마다 Gateway `npm ci`, test, typecheck, build, audit를 실행한다.
- [ ] generated localization/Drift 파일의 미반영 변경을 검사한다.
- [ ] Android release build와 macOS runner의 iOS build job을 추가한다.
- [ ] main branch 보호와 필수 check를 설정한다.

완료 조건: 새 checkout에서 같은 검증이 재현되고 실패한 check로 main 반영을 막는다.

## 4. P1 — 핵심 제품 완성

### P1-1. 사진을 이해하는 AI pipeline

현재 AI는 opaque asset ID만 받아 사진 내용을 알 수 없다.

- [ ] 별도 사진 분석 동의와 철회·취소 UX를 만든다.
- [ ] EXIF를 제거한 크기 제한 derivative를 만들고 MIME·용량을 검증한다.
- [ ] Gemini multimodal 입력과 임시 upload 삭제를 Gateway 경계 안에 구현한다.
- [ ] 분석 실패 시 사진을 유지하면서 텍스트 기반 일기로 안전하게 fallback한다.
- [ ] 모델이 입력에 없는 photo ID를 반환하지 못하게 기존 allowlist를 유지한다.

완료 조건: 사진 내용에 맞는 배치가 검증되고 원본, EXIF, 임시본의 보존·삭제 계약이
자동 테스트와 개인정보 문서에 일치한다.

### P1-2. 날씨 snapshot

의존성: DEC-06, 날씨 provider 계정과 비용 정책.

- [ ] 위치 동의 시 당일 날씨를 가져오고 일기에 immutable snapshot으로 저장한다.
- [ ] 위치 거부·실패 때 도시 선택 → 수동 입력 → 생략 순의 fallback을 제공한다.
- [ ] 정밀 위치를 AI prompt와 log에 넣지 않는다.

완료 조건: 자동·수동·없음의 세 경로와 과거 일기 재열람이 offline에서도 동일하다.

### P1-3. 기억 제어와 관련성

의존성: DEC-07.

- [ ] 기억 전체 master switch를 추가하고 끄는 즉시 prompt 주입을 중단한다.
- [ ] 비민감 기억 자동 활성화의 별도 opt-in과 철회 정책을 구현한다.
- [ ] 최신 20개 고정 전달을 관련 기억의 제한된 선택으로 교체한다.
- [ ] 원본 메시지 삭제 시 연결 기억을 즉시 비활성화한다.

완료 조건: 조회·수정·삭제·개별/전체 비활성화가 재시작 후에도 유지되고, 꺼진 기억은
Gateway request에 포함되지 않는다.

### P1-4. media·일기 lifecycle과 저장공간

- [ ] 사진 import 중 실패·강제 종료를 복구하는 startup reconciler를 연결한다.
- [ ] 메시지/일기 삭제와 연결 기억 비활성화, reference-count 고아 사진 정리를 연결한다.
- [ ] stale share/export/staging 파일을 안전하게 정리한다.
- [ ] 일기 삭제 확인과 재생성 UX를 제공하고 finalized version의 보존 정책을 정한다.
- [ ] import, share, export 전에 여유 공간을 확인하고 안전한 거부·정리 안내를 제공한다.

완료 조건: transaction 중 어느 지점에서 종료해도 DB와 파일이 수렴하며, 참조 중인
원본을 지우지 않는 restart/low-disk 테스트가 통과한다.

### P1-5. Instagram 대상 공유

의존성: DEC-08과 양 플랫폼 spike 결과.

- [ ] Meta가 공식 지원하는 현재 경로와 단일/carousel 제한을 실기기에서 확인한다.
- [ ] 지원되는 경우 Instagram 작성 화면을 열고, 아니면 OS share sheet로 fallback한다.
- [ ] caption 복사, 설치되지 않음, 취소, 일부 파일 실패를 처리한다.
- [ ] 앱은 “게시됨”이 아니라 “공유 화면을 열었음”까지만 기록한다.

완료 조건: 사용자가 Instagram에서 최종 확인하는 흐름이 양 플랫폼에서 통과한다.
사용자 확인 없는 자동 게시는 구현하지 않는다.

### P1-6. 내보내기 범위 일치

현재 구현은 JSON metadata만 내보내며 사진·렌더·restore를 포함하지 않는다.

- [ ] 원본 사진과 렌더 결과를 포함한 atomic archive를 만들지, 계획을 JSON-only로
      변경할지 확정한다.
- [ ] 선택한 범위의 manifest, checksum, schema version, privacy 안내를 제공한다.
- [ ] 대용량·low-disk·부분 실패 때 불완전한 archive를 남기지 않는다.

완료 조건: `PROJECT_PLAN.md`, UI 문구, export manifest가 실제 파일 범위와 같고,
`restoreSupported=false`를 오해 없이 표시한다.

### P1-7. 하루 마감과 긴 대화 정책

- [ ] DEC-02의 여행·시간대 변경 시 하루 귀속 규칙을 확정한다.
- [ ] OS background adapter를 추가할지, foreground 보정만 제품 약속으로 둘지 확정한다.
- [ ] 정확한 자정 실행을 보장한다는 표현은 사용하지 않는다.
- [ ] 긴 하루의 256 KiB 한계를 넘지 않도록 bounded selection, 누적 요약 또는 chunk
      정책을 구현한다.

완료 조건: 장시간·다일·시간대 변경·중복 실행에서도 한 날짜에 한 일기가 생성되고,
requestTooLarge가 영구 실패 상태로 남지 않는다.

### P1-8. 배너 광고와 consent

의존성: DEC-01·DEC-09, 광고/CMP 계정.

- [ ] 광고 provider, 지역별 consent/CMP, personalized/non-personalized 정책을 확정한다.
- [ ] 보관함·설정처럼 집중을 덜 해치는 화면에만 banner를 배치한다.
- [ ] 대화 입력, 일기 생성 중, 공유 이미지에는 광고를 넣지 않는다.
- [ ] 광고 SDK에 대화·사진·일기·정밀 위치를 전달하지 않는지 검증한다.

완료 조건: 동의·거부·철회와 NPA fallback이 출시 지역별로 동작하며 핵심 기능은
광고 실패와 무관하게 작동한다.

## 5. P2 — 공개 출시 준비

### P2-1. 자동화된 품질과 성능 기준

- [ ] native `integration_test`로 핵심 journey를 자동화한다.
- [ ] 5개 locale, light/dark, 사진, 긴 글의 4:5 renderer golden을 추가한다.
- [ ] local save p95 300 ms, AI 첫 응답 p50 5 s/p95 12 s, diary p95 20 s를
      실제 기기·staging에서 측정하고 목표를 조정한다.
- [ ] 저사양 기기, 메모리 압박, 느린 네트워크, 강제 종료 soak test를 수행한다.

### P2-2. 관측성·운영·비용

- [ ] 원문 없이 성공률, latency, token/image cost, quota, safety, delete, share-open을
      측정하는 최소 telemetry를 설계한다.
- [ ] crash/ANR alert, 비용 budget, Gateway/Vertex 장애, rollback, key rotation,
      삭제 요청 처리 runbook을 만든다.
- [ ] model·prompt version을 결과 metadata와 품질 평가에 연결한다.
- [ ] dependency update와 보안 scan 정책을 CI에 추가한다.

### P2-3. 스토어와 beta 운영

- [ ] 5개 언어의 스토어 설명, screenshot, support 문서, 연령 등급, 광고 고지를 만든다.
- [ ] TestFlight와 Play internal testing에서 단계적 beta를 운영한다.
- [ ] crash/ANR, retention proxy, 일기 생성 성공률, 공유-open 성공률을 보고 release
      gate를 통과한다.

### P2-4. 문서 정합성

- [ ] `apps/mobile/README.md`의 “외부 서비스·영속 저장소 미연결” 설명을 현재 구현에
      맞게 고치고 root quickstart를 작성한다.
- [ ] export 범위, notification, background 마감 정책 결정 후 `PROJECT_PLAN.md`와
      실제 UI 표현을 동기화한다.
- [ ] Gateway 배포/runbook과 값 없는 `.env.example`을 제공한다.

## 6. P3 — 사용량 근거가 필요한 개선

- [ ] 보관함 달력 view와 장기 데이터 pagination/SQL 검색 최적화
- [ ] 일기 사진의 crop/focal-point 편집과 renderer 계약
- [ ] 사용자가 요청할 때만 제공하는 일기 reminder의 가치 검증 및 구현 여부 결정
- [ ] prompt·model 품질 평가 세트와 실패 사례 기반 회귀 개선

P3도 제품 범위 안이지만 P0/P1/P2의 안정성과 개인정보 보호보다 먼저 진행하지 않는다.

## 7. 권장 실행 순서

1. DEC-01·03·13과 DEC-04·05 후속 결정을 닫는다.
2. 실제 app identity/signing과 stage Gateway 인증·shared quota를 병렬로 구축한다.
3. 사진 분석, 날씨, 기억, media lifecycle, 공유, export의 P1 vertical slice를 완성한다.
4. Android/iOS release E2E로 정책과 구현을 검증하고 결함을 닫는다.
5. CI, 관측성, 법적 문서, 스토어 자산을 고정한 뒤 제한 beta를 연다.
6. beta 지표와 사용자 피드백을 근거로 공개 출시 여부를 결정한다.

## 8. 전체 완료 정의

다음 조건이 모두 충족될 때 “최종 완성”으로 본다.

- [ ] P0와 P1 항목이 모두 완료되고 P2 출시 gate가 통과했다.
- [ ] Flutter/Gateway 자동 검사와 Android/iOS release E2E가 재현 가능하다.
- [ ] 개인정보·동의·삭제·안전 대응이 5개 언어와 출시 지역에서 검토됐다.
- [ ] 코드, UI, `AI_README.md`, `PROJECT_PLAN.md`, 이 문서가 같은 상태를 말한다.
- [ ] secrets, 사용자 원문, 사진 bytes, 정밀 위치가 저장소와 운영 log에 없다.
- [ ] 알려진 P0/P1 결함이 0개이고 남은 P2/P3 trade-off가 명시적으로 승인됐다.

## 9. 제품 전체의 영구 비목표

다음은 backlog가 아니다. 유사 기능을 제안하거나 구현하지 않는다.

- 사용자 간 feed, follow, like, comment, DM
- 사용자 확인 없는 Instagram 자동 게시
- 완전한 offline AI, 음성·동영상 메시지, AI 생성 사진
- 여러 AI 캐릭터와 동시 대화
- cloud sync, 다기기 복원, 공개 web profile
- 구독, 유료 theme, 광고 제거 결제
- 정신건강 진단·치료·상담 서비스

위기 표현에 지역화된 도움 경로를 보여 주는 것은 상담 서비스가 아니라 안전장치이므로
P0에 유지한다.

## 10. 갱신 규칙

- 새 작업은 기존 항목과 중복 여부, 영구 비목표 여부를 먼저 확인한다.
- 완료 체크에는 PR/commit, 테스트 명령, device matrix 또는 운영 변경 링크를 남긴다.
- 결정이 필요한 항목은 임의 구현하지 않고 해당 DEC를 먼저 갱신한다.
- 현재 상태가 바뀌면 `AI_README.md`를 먼저 갱신하고 이 문서를 같은 변경에서 맞춘다.
- 월 1회 또는 beta milestone마다 우선순위, 의존성, 완료 근거를 정리한다.
