# PROJECT PLAN — AI 챗봇 일기 앱

> 상태: 제품 전 범위 비목표 확정·나머지 기획 초안 · 기준일: 2026-10-10 · 임시 제품명: Namu

## 1. 제품 정의

사용자가 하루 동안 AI 친구에게 텍스트와 사진으로 일상을 이야기하면 즉시 풍부한 반응을 받고, 하루가 끝날 때 대화 맥락이 Instagram 게시물형 일기로 정리되는 로컬 우선 모바일 앱이다.

### 해결하려는 문제

- SNS에 일상을 공유해도 원하는 때에 충분한 반응을 받기 어렵다.
- 전통적인 일기는 하루를 다시 정리해 써야 해서 습관을 유지하기 어렵다.
- 메신저 기록은 남지만 하루의 감정과 의미를 돌아보기 좋은 결과물은 아니다.
- 사용자는 사적인 원본 기록과 공개 가능한 결과물을 분리하고 싶다.

### 핵심 가치

1. **즉시성** — 말하는 순간 AI가 맥락 있는 질문·공감·반응을 준다.
2. **자동성** — 별도 작성 부담 없이 대화가 하루 일기 초안이 된다.
3. **소유권** — 대화·사진·일기의 장기 보관 기준 원본은 사용자 기기에 둔다.
4. **통제권** — AI가 만든 문장, 기분, 사진 순서, 기억을 사용자가 고치거나 지운다.
5. **공유성** — 사적인 하루를 보기 좋은 게시물 이미지로 바꾸되 공개는 사용자가 결정한다.

## 2. 목표 사용자

- 일기를 쓰고 싶지만 긴 글을 매일 직접 작성하기 어렵고, 사진도 맥락 있는 기록으로 정리하지 못하는 사람
- 오늘 있었던 일을 바로 이야기해 풍부한 반응을 받고 필요할 때만 하루 기록을 SNS에 공유하고 싶은 사람

초기 UI는 한국어·영어·일본어·중국어 간체·스페인어를 지원하는 18세 이상 iOS·Android 사용자를 가정한다. 기기 언어를 우선하고 미지원 언어와 중국어 번체는 영어로 대체하며, 출시 국가·연령 하한·청소년 보호 범위는 출시 전에 확정한다.

## 3. 제품 원칙

- AI는 친구 같은 말투를 쓰되 사람이나 치료사라고 속이지 않는다.
- AI 결과는 항상 편집 가능한 초안이며 원본 대화와 사진을 덮어쓰지 않는다.
- AI가 완성 이미지를 생성하지 않는다. versioned JSON으로 순서형 블록을 만들고 Flutter가 결정적으로 렌더링한다.
- 기분·기억은 AI의 해석임을 표시하며 원문에 없는 사건, 관계, 장소를 사실로 만들지 않는다.
- 대화·사진·기억을 광고 targeting에 사용하지 않는다.
- Instagram의 정보 위계만 참고해 상표·좋아요 UI를 복제하지 않으며, 사용자 콘텐츠 속 문장은 시스템 지침이 아닌 데이터로 취급한다.

## 제품 전 범위 비목표 — 확정

다음 항목은 MVP에서 미루는 기능이 아니라 제품의 전체 생애 동안 만들지 않는다.

- 사용자 간 feed, follow, like, comment, DM
- 사용자 확인 없는 Instagram 자동 게시
- 완전한 offline AI, 음성·동영상 메시지, AI 생성 사진
- 여러 AI 캐릭터와 동시 대화
- cloud sync, 다기기 복원, 공개 web profile
- 구독, 유료 테마, 광고 제거 결제
- 정신건강 진단·치료·상담 서비스

자해·위기 표현에 외부 도움과 긴급 경로를 안내하는 안전 대응은 상담 서비스가 아니므로 유지한다.

## 4. 핵심 사용자 여정

1. 첫 실행에서 기기 저장과 AI용 일시 전송의 차이를 설명하고 AI 이름·프로필·말투·성격을 고른다.
2. 오늘 화면에서 텍스트나 사진을 보내면 앱이 먼저 기기에 저장한다.
3. Gateway를 거친 Gemini가 최근 맥락과 허용된 기억을 참고해 바로 반응한다.
4. 현지 날짜가 바뀌면 background에서 마감을 시도하고, 놓쳤다면 다음 foreground에서 보정한다.
5. 앱의 날짜·날씨에 Gemini가 만든 기분·요약·본문·기억 후보를 합치고 검증해 게시물형 초안을 렌더링한다.
6. 사용자가 문장·기분·테마·사진 순서를 고쳐 확정하고, 보관함에서 다시 보거나 지원되는 Instagram 경로/OS share sheet에 전달한다.

## 5. 정보 구조와 화면

| 화면 | 핵심 역할 |
|---|---|
| 온보딩 | 데이터 처리 설명, AI persona, 사진 분석·날씨·알림 기능 선택 |
| 오늘/대화 | DM형 메시지, 사진 첨부, 생성 상태, 날짜 divider |
| 일기 미리보기 | 일기 card/carousel, 편집, 재생성, 확정, 공유 |
| 보관함 | 달력·목록, 과거 일기 검색과 재열람 |
| 기억 관리 | AI가 기억하는 사실의 조회, 승인, 수정, 삭제 |
| AI 설정 | 이름, 프로필 이미지, 말투, 성격, 반응 길이·강도 |
| 설정 | 테마, 사진 분석·날씨·알림, 개인정보, 광고 동의, 내보내기·삭제 |

### 대화 UX

- Instagram DM에서 익숙한 말풍선, 사진 메시지, 날짜 구분, typing/streaming 상태를 참고한다.
- 사용자 메시지는 네트워크 응답을 기다리지 않고 로컬에 나타난다.
- 실패한 AI 답변은 원본 메시지를 남긴 채 재시도할 수 있다.
- 광고를 메시지 사이, 입력창 바로 위, AI 응답·일기 생성 중에 삽입하지 않는다.

### 게시물형 일기 UX

첨부 이미지는 **큰 미디어 캔버스 + 별도 정보·액션 영역**의 참고 자료로 사용한다.

- 모바일은 중앙의 4:5 일기 card 또는 carousel과 하단 편집/action sheet를 사용한다.
- 넓은 화면은 중앙 결과물과 우측 날짜·날씨·기분·요약·공유 panel을 사용할 수 있다.
- 흰색/검은색을 기본으로 한 light/dark 일기 테마를 제공한다.
- 본문은 `text → photo → text`를 포함할 수 있는 순서형 block이다.
- 긴 내용은 작은 글자로 우겨 넣지 않고 1080×1350 page 여러 장으로 나눈다.
- 원본 사진은 보존하고 일기에는 crop/focal point 정보만 저장한다.
- 좋아요·댓글 수처럼 실제 기능이 아닌 장식은 표시하지 않는다.

온보딩은 권한 목적과 대안을 설명하되 OS 권한 창은 사진 선택·날씨 활성화·알림 설정 등 실제 사용 시점에만 연다.

## 6. MVP 범위 — 승인 전 제안

### 포함

- Flutter 기반 iOS·Android 앱, 계정 없는 로컬 프로필, 5개 언어 UI, 로컬 저장 대화와 같은 언어의 Gemini 응답
- AI 이름, 프로필, 말투·성격 프리셋 및 간단한 custom instruction
- 날짜별 대화의 자동 보정/수동 일기 생성: 날짜·날씨·기분·한 줄 요약·text/photo 본문
- 문장·기분·테마·사진 순서 편집·재생성과 달력/목록 보관함의 offline 재열람
- 기억 후보 추출, 승인/자동 기억 선택, 수정·삭제, 기능 끄기
- 게시용 단일/다중 이미지 렌더와 Instagram/시스템 공유
- 고정 banner 광고·지역별 동의·non-personalized fallback과 전체 삭제·JSON + 사진 내보내기
- offline/timeout/앱 종료 후 복구와 중복 생성 방지

### 후속 후보

- 사용자 지정 마감 시각, 주간·월간 회고, “그날의 기억”, 추가 layout과 다른 SNS 공유
- 온디바이스 민감정보 전처리

## 7. 기능 요구사항

### FR-01. 메시지와 사진

- 텍스트/사진 메시지는 AI 호출보다 먼저 로컬에 저장한다.
- 사진은 앱 전용 저장소로 복사하고 DB에는 opaque asset ID와 metadata만 둔다.
- JPEG, PNG, HEIC를 우선 지원하되 AI에는 크기 제한을 적용한 파생본만 보낸다.
- 위치를 포함한 불필요한 EXIF는 AI 전송과 공유 export에서 제거한다.
- 사진 분석을 거부하면 저장·배치는 가능하지만 AI는 사진 내용을 추론하지 않는다.
- 설정에서 사진 분석을 언제든 끌 수 있으며 철회 뒤 새 요청에는 사진 bytes/설명을 보내지 않는다.
- 호출 실패 시 `failed/retryable` 상태를 보존하고 같은 request ID로 재시도한다.
- 사진 복사·export 전 여유 공간을 확인하고, 부족하면 원본을 지우지 않은 채 정리 가능한 파생 파일을 안내한다.

### FR-02. 하루와 마감

- `DiaryDayKey`는 label date, 당시 IANA timezone, cutoff, policy version을 snapshot한다.
- MVP cutoff는 00:00으로 고정한다. 사용자 지정은 귀속·migration 정책을 정한 후속 기능이다.
- iOS/Android의 일반 background 작업은 정각 실행을 보장하지 않으므로 “최선 노력 실행 + 다음 앱 실행 시 보정”을 제품 약속으로 삼는다.
- 같은 `DiaryDayKey`와 generation key는 성공 일기를 하나만 만든다.
- 23:59/00:00, 시간대 이동, DST, 날짜 수동 변경, 여러 날 미접속을 처리한다.
- 메시지가 없는 날은 자동 생성하지 않으며 사용자가 원하면 빈 날 기록을 직접 만든다.

### FR-03. 일기 생성·편집

- 최종 `DiaryEntry`에는 앱의 `DiaryDayKey`·`WeatherSnapshot`과 Gemini의 `mood`, `oneLineSummary`, `blocks`, `theme`, `memoryCandidates`가 있다.
- 모델 출력은 JSON Schema로 검증하며 입력에 없는 asset ID와 허용되지 않은 block을 거부한다.
- Gemini가 반환한 날짜·날씨 문구는 기준값으로 사용하지 않는다.
- 사진이 없으면 text-only, 텍스트가 짧으면 photo-led layout으로 자연스럽게 fallback한다.
- 초안/확정 상태를 구분하고 확정 뒤 재생성은 새 version으로 보존한다.
- 사용자는 텍스트, 기분, 사진 포함/제외·순서, light/dark theme를 바꿀 수 있다.
- 원본 메시지 삭제가 확정 일기를 자동 변경하지 않는다. 일기는 생성 시점 snapshot이다.

### FR-04. 날씨와 기분

- 날씨는 위치 동의 시 수집한 당일 snapshot, 선택 도시, 수동 입력 중 하나를 사용한다.
- 위치 거부/조회 실패 시 “날씨 없음”으로 정상 동작한다.
- 과거 날을 나중에 생성할 수 있으므로 조회값에는 provider, 관측 시각, 대략 위치를 저장한다.
- 기분은 짧은 label과 선택적 intensity로 표현하고 AI 추정임을 표시한다.
- 사용자가 기분을 수정·삭제할 수 있으며 질환·건강 상태를 추론하지 않는다.

### FR-05. 장기 기억

- 하루 마감 때 다음 대화에 도움이 되는 짧고 독립적인 사실 후보만 추출한다.
- 각 후보에는 category, source message IDs, 민감도, 생성·수정 시각을 둔다.
- 기본은 일기 확정 화면에서 후보를 승인하는 방식이다. 명시적으로 opt-in하면 비민감 후보만 자동 활성화할 수 있다.
- 건강, 성생활, 금융정보, 인증정보, 정밀 위치는 자동 기억하지 않는다.
- 다음 대화에는 전체 기록이 아니라 현재 맥락과 관련된 활성 기억만 제한된 수로 넣는다.
- 모순은 임의 덮어쓰기하지 않고 사용자에게 최신 사실을 선택하게 한다.
- 원문 메시지를 지우면 연결 기억을 즉시 비활성화하고, 독립 기억으로 유지할지 다시 승인받기 전에는 주입하지 않는다.
- 사용자는 기억 전체를 조회·수정·삭제하고 기억 기능을 끌 수 있다.

### FR-06. 보관·삭제·내보내기

- 저장된 일기는 네트워크 없이 열리고 날짜·기분·한 줄 요약으로 찾을 수 있다.
- 사진 누락이나 손상은 앱 crash 대신 placeholder와 복구 안내로 처리한다.
- 삭제는 DB row, thumbnail, 앱 sandbox의 export staging/cache, 임시 upload, 참조 없는 원본을 함께 정리한다.
- 수동 내보내기는 versioned JSON, 원본 사진, 렌더 결과를 묶는다. 앱 밖에 저장·공유된 사본은 앱이 회수할 수 없음을 알린다.
- 앱 삭제/기기 분실 시 복구할 수 없다는 제품 제약을 온보딩과 설정에 알린다.

### FR-07. Instagram 공유

- 앱이 게시용 image 한 장 또는 carousel 여러 장과 복사 가능한 caption을 로컬에서 만든다.
- 목표는 사용자 주도 Instagram 피드 공유이며, 최종 계정·공개 범위·게시 여부는 사용자가 Instagram에서 결정한다.
- Meta `Sharing to Feed`, Instagram 대상 native share, OS share sheet 중 플랫폼별 지원 경로는 Phase 0 실기기 검증 후 선택한다. composer 직접 진입을 미리 보장하지 않는다.
- Graph API 등을 이용한 silent/자동 게시는 제품 전 범위에서 구현하지 않는다.
- Instagram 미설치, 형식 미지원, 공유 취소 시 저장/OS share sheet fallback을 제공한다.
- 외부 앱으로 넘긴 뒤 실제 게시 성공을 확정할 수 없다고 가정하고 “공유 화면 열림”만 기록한다.
- iOS/Android별 다중 이미지, caption 전달, 지원 Instagram version은 Phase 0 실기기 spike로 확정한다.

### FR-08. 광고

- banner는 보관함/설정 등 몰입을 덜 해치는 고정 영역에만 노출한다.
- 대화 입력, 일기 본문·편집, 공유 이미지, 위기 대응 화면에는 광고를 넣지 않는다.
- 동의 전 개인화 광고 식별자를 쓰지 않으며 대화·사진·기분·기억을 광고 SDK에 전달하지 않는다.
- 광고 load 실패나 차단기가 기록·생성·공유를 막지 않는다.

## 8. AI·시스템 설계

### 호출 구조

```text
Flutter app → authenticated AI Gateway → Gemini on Vertex AI
```

- Flutter에 Vertex 서비스 계정이나 장기 key를 넣지 않는다.
- Gateway가 앱 무결성, 인증/익명 ID, rate limit, token/image 상한, model·prompt version, schema, safety, 비용을 통제한다.
- 서버는 원문을 기본 저장하지 않고 민감 payload를 log하지 않는다. 재생성에 필요한 기준 원본은 기기에 둔다.
- 이미지 임시 저장이 필요하면 짧은 만료와 처리 후 삭제를 적용한다.

### 입력 context

1. 고정 안전/행동 정책
2. allowlist로 검증한 응답 locale(`ko`, `en`, `ja`, `zh-Hans`, `es`)
3. 사용자가 정한 AI persona와 현재 대화에 관련된 승인 기억
4. 앱이 확정한 `DiaryDayKey`·`WeatherSnapshot`(일기 생성 시)
5. 제한된 최근 메시지·누적 요약과 현재 메시지·동의된 사진 파생본

오래된 원문 전체를 매번 보내지 않는다. context budget과 선택 이유를 추적하되 원문을 telemetry에 남기지 않는다.

### 일기 출력 계약

Gemini 출력의 최상위 필드는 `schemaVersion`, `mood`, `oneLineSummary`, `theme`, `blocks`, `memoryCandidates`다. 날짜와 날씨는 앱이 조립한다. `blocks`는 `{type: text, text}` 또는 `{type: photo, photoAssetId}`만 허용하며 배열 순서가 렌더 순서다.

- 앱은 type, 길이, enum, 사진 소유권과 참조 무결성을 검사한다.
- 검증 실패는 제한된 1회 repair 뒤 안전한 기본 layout 또는 재시도 가능한 오류로 끝낸다.
- 모델/프롬프트/schema version과 request/generation ID를 결과 metadata에 남긴다.

### 핵심 로컬 모델

`UserPreferences`, `AiPersona`, `DiaryDayKey`, `Message`, `MediaAsset`, `WeatherSnapshot`, `DiaryEntry`, `DiaryBlock`, `MemoryFact`, `GenerationRun`, `ShareExport`.

각 모델의 상세 field는 구현 직전 schema 문서/코드에서 확정한다. ID, UTC instant, local date/timezone, status, version은 처음부터 둔다.

## 9. 비기능 요구사항

### 신뢰성·성능 목표

- 로컬 메시지 저장·표시 p95 300ms, 일반 네트워크 AI 첫 응답 p50 5초/p95 12초를 목표로 측정한다.
- 하루 일기 생성 p95 20초를 목표로 하며 진행·취소·재시도를 제공한다.
- 강제 종료 뒤 pending 메시지와 generation job을 복구하고, 재시도로 중복 일기·기억이 생기지 않게 한다.
- 긴 한글/영문, 큰 글자, 저사양 기기에서도 export가 overflow/crash하지 않는다.
- low-disk에서는 새 사진·export를 안전하게 거부하고 원본·DB를 손상시키지 않으며 파생 cache 정리 수단을 제공한다.

### 개인정보·보안

- 모든 전송은 TLS를 사용하고 인증 token은 OS secure storage에 보관한다.
- 대화/일기/사진/정밀 위치/전체 prompt를 log, analytics, crash report에 남기지 않는다.
- App Check 또는 동등한 앱 검증, 사용자·일별 quota, request size 제한을 둔다.
- Gateway는 무인증/만료 증명, replay, quota, MIME·크기, 임시 파일 만료와 민감 log redaction을 자동 시험한다.
- 앱 콘텐츠는 OS cloud backup 대상에서도 제외한다. 로컬 암호화와 key 복구 수준은 위협 모델 spike 뒤 결정한다.
- 데이터 삭제, AI 전송, 광고 동의는 서로 분리하고 언제든 철회 가능하게 한다.
- 자해·위기 표현에는 진단 대신 지역화된 도움 정보와 긴급 경로를 제공한다.

### 접근성·국제화·비용

- screen reader, 동적 글자 크기, 대비, touch target, 색 이외의 상태 표현을 지원한다.
- 한국어·영어·일본어·중국어 간체·스페인어 UI를 제공하며 날짜·숫자·단위·소수 입력과 접근성·오류·개인정보·공유 문구를 locale에 맞춘다. 사용자·AI의 저장 콘텐츠와 persona는 언어 전환 시 자동 번역하지 않는다.
- 최근 context window, 요약, 이미지 축소·중복 방지, 사용자 quota로 비용을 제어한다.
- model/prompt version별 품질, latency, token/image 비용을 함께 관찰한다.

## 10. 성공 지표

**North Star:** 주간 활성 사용자당 확정한 일기 날짜 수.

- 설치 → 첫 메시지 → 24시간 내 첫 일기 생성 → 검토·편집 → 확정 → 공유 화면 진입 funnel
- 주간 대화·완성 일기 수, D1/D7/D30 유지율, 보관함 재열람률, persona/기억 사용률
- 일기 재생성·대규모 수정·사실 오류 신고율, 기억 승인/수정/삭제율, AI 응답 신고율
- 생성 성공률·p95 latency·사용자당 AI 비용, 전체 삭제 성공률, 광고 화면 이탈률

초기 목표치는 내부 alpha 2주로 baseline을 만든 뒤 beta 전에 확정한다.

## 11. 주요 위험과 대응

| 위험 | 대응 |
|---|---|
| 자정 background 실행 지연 | 최선 노력 + foreground 보정 + 날짜별 idempotency |
| “기기 저장”을 “외부 전송 없음”으로 오해 | 저장/AI 처리 동의를 분리해 설명 |
| 환각·잘못된 기억 | 구조화 결과, source 연결, 사용자 편집·승인 |
| 사진과 대화의 민감성 | 최소 전송, EXIF 제거, payload logging 금지, 짧은 임시 보존 |
| Instagram 정책·수신 동작 변경 | 공식 flow 실기기 회귀 시험, OS share/save fallback |
| 긴 글·사진의 layout 붕괴 | page 분할, block 상한, golden/export test |
| Gemini 비용·지연 | context 요약, 사진 축소, quota, 교체 가능한 model 설정 |
| 광고가 친밀한 경험을 훼손 | 안전한 화면에만 고정 banner, 내용 기반 targeting 금지 |
| 기기 분실로 기록 소실 | 수동 export 제공, 복원 불가 범위를 온보딩·설정에 반복 고지 |
| 정서적 의존·위기 대화 | AI 정체성 고지, 안전 응답과 외부 도움 경로 |

## 12. 구현 전 결정 gate

결정의 단일 기준은 `AI_README.md`의 `open` register다. 영구 비목표는 향후 구현 후보나 결정 gate에 다시 올리지 않는다. Phase 1 전에 특히 날짜 귀속(DEC-02), 인증(DEC-03), 로컬 보호·수동 export(DEC-04), Gateway/보존(DEC-05), 공유(DEC-08)를 닫아야 한다.

## 13. 개발 단계

| Phase | 범위 | 완료 조건 |
|---|---|---|
| 0 위험 검증 | Instagram 공유, 자정 background, Gemini JSON, 1080×1350 renderer spike | 차단 결정·데이터 보존·기술 선택 확정 |
| 1 하루 vertical slice | 로컬 대화/사진 → AI → 수동 일기 → 저장·재열람 | 실기기 E2E와 원본 보존·실패 복구 통과 |
| 2 핵심 제품 | 마감 보정, 날씨·기분, 편집, 기억, carousel, 공유 | 네트워크 단절 시 로컬 기능·재시도, 중복·시간대·AI 오류·사진 누락 통과 |
| 3 출시 준비 | 광고/동의, 삭제·내보내기, 접근성, 비용, 관측성, 안전 | 지표와 개인정보·성능·안전 guardrail 검증 |

각 Phase 후 `result reports/`에 `A. 무엇을·왜`, `C. Critical Path`, 필요 시 `D. 새로 도입한 것`만 기록한다.

## 14. 기술 검증 근거

- Apple은 일반 background 작업의 실제 실행 시점을 시스템이 결정한다고 설명한다: [Choosing Background Strategies](https://developer.apple.com/documentation/BackgroundTasks/choosing-background-strategies-for-your-app).
- Android periodic work도 특정 시각 실행을 보장하지 않는다: [Background work options](https://developer.android.com/develop/background-work/background-tasks/data-transfer-options).
- Vertex AI 호출은 앱에 고정 자격 증명을 넣지 않는 Gateway 구조를 기본으로 검토한다: [Gemini API in Vertex AI quickstart](https://cloud.google.com/vertex-ai/generative-ai/docs/start/quickstart).
- Instagram 연동은 구현 시점의 공식 문서를 다시 검증한다: [Instagram Platform](https://developers.facebook.com/docs/instagram-platform/).
