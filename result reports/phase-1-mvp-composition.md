# A. 무엇을·왜

- 실제 `NamuBootstrap`이 web에서는 transient repository, native에서는 하나의 Drift DB와 backup 제외 media/동의 저장소를 조립하도록 연결했다. 검토용 fixture가 제품 entry를 대신하지 않게 했다.
- native IANA timezone resolver를 앱 시작 전에 초기화하고 foreground에서 먼저 갱신한 뒤, 자정 one-shot timer와 시작/foreground 누락 보정을 실행한다. 활성 날짜가 바뀌면 chat과 diary controller를 함께 회전한다.
- 앱 종료 시 daily-close coordinator와 lifecycle observer를 먼저 정리하고 그 뒤 owned DB를 닫는 idempotent close 순서를 추가했다.
- 첫 실행 AI 데이터 전송 동의와 설정의 철회 화면을 production graph에 연결했다. chat/diary Gateway decorator가 같은 동의 repository를 매 호출 확인하므로 UI를 우회해도 미동의 요청은 외부로 나가지 않는다. 동의 직후에는 과거의 누락된 마감 일기를 다시 보정한다.
- chat/diary JSON은 UTF-8 256 KiB를 넘으면 auth provider나 network보다 먼저 typed error로 거부하고, server 413도 같은 category로 처리한다.
- 중단된 pending chat 복구, 실제 로컬 사진 표시, 다중 page 일기 carousel, 편집기의 사진 thumbnail, 4개 AI avatar preset, 보관·기억·다중 PNG 공유를 실제 앱 shell에 연결했다.

# C. Critical Path

- 장기 Vertex 자격 증명은 앱에 없다. Gateway production 인증/attestation은 DEC-03 미결정으로 계속 deny-all이며, 이 호스트에도 Vertex ADC/project/location/model 설정이 없어 실제 Gemini 성공을 만들거나 가장하지 않았다. 외부 beta 전에 식별·attestation·shared quota/idempotency를 결정하고 staging에서 검증해야 한다.
- automatic daily close는 앱 실행 중 timer와 다음 foreground 보정의 best-effort다. 모바일 OS가 자정 background 실행을 보장한다고 표시하지 않는다. deterministic `DiaryDayKey` generation ID와 기존 일기 재확인으로 재시작·중복 실행을 막는다.
- web은 제품 배포 대상이 아니라 transient 검토 surface다. 새로 고침하면 대화·동의·일기가 사라지며, native의 SQLite/backup 제외 파일 영속성을 가장하지 않는다.
- 현재 사진 bytes는 AI에 전송하지 않는다. 모델은 opaque photo ID와 대화 순서만 보고 배치하므로 사진 내용을 인식한다고 말하면 안 된다. 사진 분석을 추가하려면 EXIF 제거·파생본 크기 제한·별도 동의가 선행돼야 한다.
- 공유는 1080×1350 PNG 한 장 이상을 OS share sheet로 전달하고 “공유 화면을 열었음”만 안다. Instagram 설치 여부, feed composer 직접 진입, 다중 이미지·caption 동작은 Android/iOS 실기기에서 아직 검증하지 않았으므로 게시 성공을 주장할 수 없다.
- Android application ID/iOS bundle ID는 아직 placeholder이고, 이 Linux 호스트에는 Android SDK가 없으며 iOS build가 불가능하다. release signing, native channel, system picker, share sheet는 실기기 검증 전 출시 완료가 아니다.
- Flutter 전체 테스트 401개, analyzer 0 issue를 통과했다. Gateway는 테스트 28개, TypeScript typecheck, production build를 통과했다.

# D. 새로 도입한 것

- `timezone` 0.11.1과 Android/iOS `namu/time_zone` MethodChannel로 IANA rule snapshot을 제공한다.
- app dependency graph의 `registerBeforeClose` hook으로 child lifecycle resource와 DB 종료 순서를 명시한다.
- AI consent Gateway decorator, backup-excluded JSON consent adapter, UTF-8 request byte-budget helper를 도입했다.
