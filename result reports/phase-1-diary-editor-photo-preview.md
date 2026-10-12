# A. 무엇을·왜

- `DiaryEditorSheet`가 선택적 `LocalPhotoBytesLoader`를 받아 사진 블록에 실제 로컬 썸네일을 표시하게 했다.
- `TodayScreen`의 기존 사진 로더를 편집 바텀시트에 연결해 미리보기와 편집기가 같은 로컬 사진 경계를 사용하게 했다.
- 정렬·제거 동작은 기존 블록 순서와 자산 ID를 그대로 보존한다. 정상 로드, 로드 실패 fallback, 자산 ID 미노출, `TodayScreen` 연결을 widget test로 보호했다.

# C. Critical Path

- 앱 내부 저장 키인 `photoAssetId`를 화면 텍스트나 accessibility label에 노출하지 않는다. 사진은 기존 `LocalPhoto`를 통해서만 bytes로 해석하며, 로더 미설정·삭제·손상·decode 실패 시에는 비민감 placeholder를 보여준다.
- 이미지 semantics는 `첨부 사진`만 제공하고 내부 ID를 포함하지 않는다. 이동·삭제 `IconButton`의 기존 tooltip과 활성/비활성 규칙은 변경하지 않았다.
