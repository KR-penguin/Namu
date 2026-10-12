# Phase 3 — 수동 기록 JSON 내보내기

## A. 무엇을·왜

설정의 `내 데이터`에 사용자가 직접 확인한 뒤 실행하는 `기록 JSON 내보내기`를 연결했다. 대화, 일기 snapshot, 참조된 사진의 비파일 metadata, AI 친구 설정, 기억, AI 전송 동의를 schema version 1 JSON으로 만들고 native OS 공유·저장 화면을 연다. browser review에서는 영속 제품 저장소처럼 보이지 않도록 기능을 비활성화한다.

이 단계의 목적은 cloud sync나 다기기 복원을 추가하지 않고도 사용자가 자신의 텍스트 기록을 앱 밖으로 꺼낼 수 있게 하는 것이다. 화면과 JSON 모두 현재 파일이 앱 복원용이 아니며 사진 원본·게시용 렌더가 포함되지 않는다고 명시한다.

## C. Critical Path

- 내보내기는 자동 실행되지 않는다. 설정 tile → 민감 내용과 한계 고지 → 사용자 확인 이후에만 repository를 읽고 OS 공유·저장 화면을 연다.
- JSON에는 `schemaVersion=1`, `restoreSupported=false`, `snapshotConsistency=bestEffort`, 사진·렌더 포함 여부를 기록한다. 여러 repository를 하나의 DB transaction으로 고정하는 계약이 아직 없어 실행 중 새 기록이 생기면 이번 snapshot에 포함되지 않을 수 있다.
- 사진 파일은 넣지 않았다. 원본을 그대로 묶으면 GPS 등 EXIF가 남을 수 있고, 재인코딩하면 충실도·HEIC 지원·용량 정책이 달라진다. 이 정책을 결정하기 전에는 opaque photo ID와 MIME·크기·lifecycle만 기록하며 내부 `storageKey`는 노출하지 않는다.
- native staging은 backup 제외 앱 root의 `exports/data` 아래에서 임시 파일을 flush한 뒤 rename한다. root 범위를 검증하고 export 경로의 symlink를 따라가지 않는다. 전체 로컬 삭제는 이 staging 파일도 root와 함께 제거하지만, 외부 앱이나 파일 영역으로 나간 사본은 회수할 수 없다.
- OS 공유 결과는 실제 저장·업로드 완료 증명이 아니다. 앱은 공유·저장 화면을 열었다는 사실만 표시하며 destination 성공을 주장하지 않는다.
- 완전한 사진·렌더 bundle 내보내기 전 결정이 필요하다: 원본 사진의 EXIF를 보존할지, privacy-scrubbed 파생본만 포함할지. 권장안은 기본적으로 방향을 정규화한 metadata 제거 파생본을 포함하고, 원본 포함은 별도 고지와 명시적 선택으로 두는 것이다.

## D. 새로 도입한 것

- `ExportLocalData` application use case와 `LocalDataExportStore` / `LocalDataExportLauncher` port
- `namu-local-data-export` JSON schema version 1
- 앱 전용 atomic JSON staging adapter와 `share_plus` 기반 사용자 주도 share/save adapter
