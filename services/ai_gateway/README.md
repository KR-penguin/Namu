# Namu AI Gateway

Cloud Run에서 실행하는 Node.js 22 + TypeScript MVP Gateway다. 모바일 앱의 장기 자격 증명과 Vertex 권한을 분리하고, 인증·attestation·quota·idempotency·입출력 검증을 통과한 짧은 요청만 Gemini에 전달한다.

## 현재 보안 상태

- Vertex 호출은 `@google/genai` 2.x의 `vertexai: true`, `apiVersion: "v1"`과 Application Default Credentials(ADC)를 사용한다. API key나 서비스 계정 JSON을 코드·이미지에 넣지 않는다.
- production/Cloud Run의 기본 인증 adapter는 의도적으로 deny-all이다. `AI_README.md`의 DEC-03이 확정되고 실제 인증·App Attestation 검증 adapter가 `AuthAttestationVerifier`에 연결되기 전에는 외부 beta용으로 배포하면 안 된다.
- `NAMU_AUTH_MODE=development`는 로컬 계약 확인 전용이다. `NODE_ENV=production`이거나 Cloud Run의 `K_SERVICE`가 있으면 startup 단계에서 거부된다.
- 요청·응답 원문, prompt, token, 사진 bytes·경로는 저장하거나 log하지 않는다. JSON logger는 route/method/requestId/operation/status/latency/idempotency 결과만 allowlist로 출력한다.
- 사진 분석은 하지 않는다. `photoAssetId`는 순서 배치를 위한 opaque reference일 뿐이며 image bytes, storage key, 로컬 경로를 받지 않는다.

## Endpoint

| Method | Path | 설명 |
|---|---|---|
| `GET` | `/healthz` | 공개 process readiness (`{"status":"ok"}`) |
| `POST` | `/v1/chat/reply` | exact chat request v2 JSON → exact reply v1 JSON |
| `POST` | `/v1/diary/generate` | exact diary request v2 JSON → diary output v1 JSON |

두 POST endpoint는 다음 조건을 적용한다.

- `Content-Type: application/json`
- body 기본 상한 256 KiB
- `Idempotency-Key`가 chat의 `requestId` 또는 diary의 `generationId`와 정확히 일치
- 인증과 attestation 검증
- principal + operation별 quota
- Zod `.strict()` 요청·응답 검증
- request v2의 `responseLocale`은 `ko`, `en`, `ja`, `zh-Hans`, `es`만 허용하며 그 밖의 값은 모델 호출 전에 거부
- diary 응답의 `photoAssetId`와 `sourceMessageIds`를 실제 요청 ID allowlist와 대조
- 성공 응답과 오류 응답 모두 `Cache-Control: no-store`
- Vertex 안전 차단, timeout, 출력 truncation, invalid structured output을 서로 다른 redacted 오류로 분류
- Diary structured output이 malformed이거나 계약/ID allowlist를 위반한 경우에만 원문 결과를 재전송하지 않고 정확히 한 번 repair 요청

endpoint 경로의 `/v1`과 JSON body의 `schemaVersion`은 별도 버전이다. 현재 두 요청 body는 `schemaVersion: 2`와 `responseLocale`을 필수로 하며 이전 request v1 body는 strict validation으로 거부한다. Chat 응답과 Diary 모델 출력의 `schemaVersion`은 호환성을 위해 계속 1이다. Diary 모델 출력 기준은 [v1.schema.json](../../contracts/diary_generation/v1.schema.json)이며 서버가 같은 의미의 Zod 계약으로 다시 검증한다.

## 로컬 실행

Node.js 22가 필요하다.

```bash
npm ci
npm test
npm run typecheck
npm run build
```

실제 Vertex 호출에는 ADC와 세 필수 환경 변수가 필요하다.

```bash
gcloud auth application-default login
export GOOGLE_CLOUD_PROJECT="your-project"
export GOOGLE_CLOUD_LOCATION="your-region"
export NAMU_GEMINI_MODEL="your-approved-model"
export NAMU_AUTH_MODE="development"
npm run build
npm start
```

로컬 development 요청은 `Authorization: Bearer <local-principal>`과 `X-App-Attestation: development-bypass`가 모두 필요하다. 이 값들은 인증을 흉내 내는 marker일 뿐 실제 보안 수단이 아니다.

## 환경 변수

| 이름 | 필수/기본값 | 용도 |
|---|---|---|
| `GOOGLE_CLOUD_PROJECT` | 필수 | Vertex 프로젝트 |
| `GOOGLE_CLOUD_LOCATION` | 필수 | 운영자가 결정한 Vertex region |
| `NAMU_GEMINI_MODEL` | 필수 | 승인한 Gemini model ID |
| `PORT` | `8080` | Cloud Run HTTP port |
| `NAMU_AUTH_MODE` | `deny` | `deny` 또는 로컬 전용 `development` |
| `NAMU_JSON_BODY_LIMIT_BYTES` | `262144` | 압축 해제 없는 JSON byte 상한 |
| `NAMU_VERTEX_TIMEOUT_MS` | `15000` | SDK HTTP timeout. 현재 모바일 chat 20초·diary 30초보다 먼저 종료 |
| `NAMU_VERTEX_CHAT_MAX_OUTPUT_TOKENS` | `512` | chat 호출당 최대 출력 token |
| `NAMU_VERTEX_DIARY_MAX_OUTPUT_TOKENS` | `2048` | diary 호출당 최대 출력 token |
| `NAMU_QUOTA_MAX_REQUESTS` | `30` | fixed window의 principal/operation별 허용량 |
| `NAMU_QUOTA_WINDOW_MS` | `60000` | quota window |
| `NAMU_IDEMPOTENCY_TTL_MS` | `600000` | 성공 응답 replay TTL |
| `NAMU_IDEMPOTENCY_MAX_ENTRIES` | `1000` | process별 cache 상한 |

필수 Vertex 변수 하나라도 없으면 process가 listen하기 전에 fail-fast한다. Cloud Run 서비스 계정에는 최소 범위의 Vertex 호출 권한만 부여한다.

## 데이터와 prompt 경계

- 사용자 text, persona custom instruction, 최근 message, 사용자가 승인한 활성 memory와 요청의 `responseLocale`은 `untrusted JSON data`로만 model contents에 넣는다. 사용자 제공 문자열을 system instruction에 보간하지 않는다.
- 서버가 Zod allowlist로 검증한 `responseLocale`은 미리 정의된 서버 소유 언어 지시문에만 매핑한다. Chat text와 Diary의 mood·summary·text block·memory fact를 해당 언어로 생성하되 JSON field, enum, opaque ID는 바꾸지 않도록 요구한다.
- Chat request v2는 현재 message 외에 UTC/ID 정렬된 최근 message 최대 30개와 최신 활성 memory 최대 20개만 허용한다. candidate/inactive memory, source message ID, 로컬 경로는 계약에 없다.
- system instruction은 정신건강 진단·치료·상담을 금지하고, 즉각적 위기 정황에는 지역 긴급 서비스와 가까운 신뢰 가능한 사람에게 도움을 요청하도록 안내한다.
- 입력에 없는 사건·감정·사진 내용·날씨를 날조하지 않도록 요구한다.
- Diary 호출은 Vertex structured output JSON schema를 사용하고 결과를 Zod 및 요청 ID allowlist로 다시 검증한다.
- 두 operation 모두 candidate 한 개와 명시적인 출력 token budget을 사용한다. harassment, hate speech, sexually explicit, dangerous content는 `BLOCK_MEDIUM_AND_ABOVE`로 명시한다.
- 안전 차단과 truncation, 지원하지 않는 finish reason, timeout은 repair하지 않는다. Diary의 malformed JSON 또는 앱 계약 위반만 한 번 repair하고 두 번째 실패는 그대로 종료한다.
- 서버에는 DB나 object storage가 없다. 처리 중 메모리 외에 요청 원문이나 사진을 보존하지 않는다.

모델 관련 공개 오류 body에는 아래의 안정적인 code만 포함되며 SDK 오류 문구나 모델 출력은 포함하지 않는다.

| HTTP | code | 의미 |
|---|---|---|
| `422` | `safety_blocked` | prompt 또는 candidate가 안전 정책으로 차단됨 |
| `502` | `model_truncated` | 최대 출력 token 또는 continuation 경계에서 종료됨 |
| `502` | `invalid_model_response` | 구조화 응답 또는 finish reason이 계약을 만족하지 않음 |
| `502` | `model_unavailable` | 분류 가능한 세부정보를 공개하지 않는 provider 장애 |
| `504` | `model_timeout` | Vertex SDK deadline 초과 |

## MVP의 단일 instance 한계

`InMemoryQuotaLimiter`와 `InMemoryIdempotencyStore`는 process-local이다. idempotency cache에는 원문 request가 아니라 SHA-256 fingerprint와 성공 response만 TTL 동안 메모리에 남는다. Chat fingerprint는 재시도 중 바뀔 수 있는 persona/recent context/memory를 제외하고 불변 message identity·content와 응답 locale을 기준으로 한다. process 재시작 시 사라지며 여러 Cloud Run instance 사이에서 quota나 replay가 공유되지 않는다.

따라서 외부 beta 또는 여러 instance 배포 전에 다음을 해야 한다.

1. DEC-03에 맞는 실제 auth + attestation adapter를 연결한다.
2. quota와 idempotency를 TTL·원자적 compare-and-set을 지원하는 shared backend로 교체한다.
3. idempotency response의 짧은 보존 기간을 개인정보 처리방침과 일치시킨다.
4. abuse, replay, revoked identity, provider 장애를 staging에서 검증한다.

## Container

```bash
docker build -t namu-ai-gateway .
docker run --rm -p 8080:8080 \
  -e GOOGLE_CLOUD_PROJECT \
  -e GOOGLE_CLOUD_LOCATION \
  -e NAMU_GEMINI_MODEL \
  namu-ai-gateway
```

runtime image는 non-root `node` 사용자로 실행한다. Cloud Run에는 ADC가 서비스 계정에서 공급되므로 key 파일을 mount하거나 image에 복사하지 않는다.

## 구조

- `src/contracts.ts`: exact request v2 / output v1 Zod 계약과 Vertex JSON schema
- `src/app.ts`: 최소 Node HTTP handler와 오류/redaction 경계
- `src/ports.ts`: auth, quota, idempotency, Vertex, logger port
- `src/vertex_model.ts`: ADC 기반 `@google/genai` Vertex adapter와 system prompt
- `src/runtime.ts`: process-local MVP adapter 조립
- `src/server.ts`: Cloud Run entry point와 graceful shutdown
