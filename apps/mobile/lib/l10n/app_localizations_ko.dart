// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Namu';

  @override
  String get settingsTitle => '설정';

  @override
  String get commonBack => '돌아가기';

  @override
  String get commonClose => '닫기';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonRetryShort => '재시도';

  @override
  String get commonCancel => '취소';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonApprove => '승인';

  @override
  String get commonExport => '내보내기';

  @override
  String get commonAttachedPhoto => '첨부 사진';

  @override
  String commonDiaryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'finalized': '확정',
      'draft': '초안',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String commonWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': '월요일',
      'tuesday': '화요일',
      'wednesday': '수요일',
      'thursday': '목요일',
      'friday': '금요일',
      'saturday': '토요일',
      'sunday': '일요일',
      'other': '요일 미상',
    });
    return '$_temp0';
  }

  @override
  String commonFullDate(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String commonFullDateWithWeekday(
    int year,
    int month,
    int day,
    String weekday,
  ) {
    return '$year년 $month월 $day일 · $weekday';
  }

  @override
  String commonMonthDayWithWeekday(int month, int day, String weekday) {
    return '$month월 $day일 · $weekday';
  }

  @override
  String get bootstrapResetDeleting => '기기의 로컬 데이터를 삭제하고 있어요…';

  @override
  String get bootstrapResetFailedTitle => '데이터 삭제를 완료하지 못했어요';

  @override
  String get bootstrapResetFailedBody =>
      '기록을 다시 열지 않고 안전하게 멈췄어요. 삭제를 다시 시도해 주세요.';

  @override
  String get bootstrapResetRetry => '삭제 다시 시도';

  @override
  String get bootstrapTimeZoneFailedTitle => '시간대를 불러오지 못했어요';

  @override
  String get bootstrapTimeZoneFailedBody => '날짜별 기록을 안전하게 나누려면 시간대 확인이 필요해요.';

  @override
  String get gatewayPreservedChat => '메시지는 기기에 남아 있어요.';

  @override
  String get gatewayPreservedDiary => '오늘 기록은 기기에 남아 있어요.';

  @override
  String gatewayUnknownChat(String preserved) {
    return 'AI 답변을 받지 못했어요. $preserved';
  }

  @override
  String gatewayUnknownDiary(String preserved) {
    return '일기 초안을 만들지 못했어요. $preserved';
  }

  @override
  String gatewayUnconfigured(String preserved) {
    return 'AI 연결 설정이 필요해요. $preserved';
  }

  @override
  String gatewayUnauthorized(String preserved) {
    return 'AI 연결 인증을 확인하지 못했어요. 잠시 후 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewayInvalidAttestation(String preserved) {
    return '이 앱의 기기 인증을 확인하지 못했어요. 앱을 다시 연 뒤 시도해 주세요. $preserved';
  }

  @override
  String gatewayRateLimited(String retryGuidance, String preserved) {
    return 'AI 요청이 잠시 많아요. $retryGuidance $preserved';
  }

  @override
  String get gatewayRequestTooLargeChat =>
      '메시지가 너무 길어 AI에 보낼 수 없어요. 내용을 나눠 새 메시지로 보내 주세요. 원문은 기기에 남아 있어요.';

  @override
  String gatewayRequestTooLargeDiary(String preserved) {
    return '오늘 기록이 너무 길어 AI에 보낼 수 없어요. $preserved';
  }

  @override
  String gatewayResponseTooLarge(String preserved) {
    return 'AI 답변이 너무 길어 표시하지 않았어요. 다시 시도해 주세요. $preserved';
  }

  @override
  String get gatewayIdempotencyConflictChat =>
      '이 요청을 안전하게 다시 처리할 수 없어요. 새 메시지로 시도해 주세요. 원문은 기기에 남아 있어요.';

  @override
  String gatewayIdempotencyConflictDiary(String preserved) {
    return '이 요청을 안전하게 다시 처리할 수 없어요. 앱을 다시 연 뒤 시도해 주세요. $preserved';
  }

  @override
  String gatewayRejected(String preserved) {
    return 'AI가 이 요청을 처리할 수 없어요. 내용을 확인한 뒤 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewaySafetyBlockedChat(String preserved) {
    return 'AI 안전 기준에 따라 이 요청에는 답변할 수 없어요. $preserved';
  }

  @override
  String gatewaySafetyBlockedDiary(String preserved) {
    return 'AI 안전 기준에 따라 일기 초안을 만들 수 없어요. $preserved';
  }

  @override
  String gatewayTimeout(String preserved) {
    return 'AI 답변이 늦어져 기다리기를 멈췄어요. 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewayTruncated(String preserved) {
    return 'AI 답변이 완성되지 않아 표시하지 않았어요. 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewayInvalidResponse(String preserved) {
    return 'AI 답변 형식을 확인할 수 없어 표시하지 않았어요. 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewayServerUnavailable(String preserved) {
    return 'AI 서비스가 잠시 불안정해요. 잠시 후 다시 시도해 주세요. $preserved';
  }

  @override
  String gatewayNetworkUnavailable(String preserved) {
    return '네트워크에 연결하지 못했어요. 연결을 확인한 뒤 다시 시도해 주세요. $preserved';
  }

  @override
  String get gatewayRetrySoon => '잠시 후 다시 시도해 주세요.';

  @override
  String gatewayRetryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '약 $count초 후 다시 시도해 주세요.',
      one: '약 1초 후 다시 시도해 주세요.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '약 $count분 후 다시 시도해 주세요.',
      one: '약 1분 후 다시 시도해 주세요.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '약 $count시간 후 다시 시도해 주세요.',
      one: '약 1시간 후 다시 시도해 주세요.',
    );
    return '$_temp0';
  }

  @override
  String get archiveSearchSemantics => '일기 보관함 검색';

  @override
  String get archiveSearchLabel => '보관함 검색';

  @override
  String get archiveSearchHint => '2026-10-04, 기분, 한 줄 요약';

  @override
  String get archiveClearSearchTooltip => '검색어 지우기';

  @override
  String get archiveTitle => '일기 보관함';

  @override
  String get archiveSubtitle => '기기에 저장된 하루를 다시 열어보세요';

  @override
  String get archiveReloadTooltip => '일기 목록 새로고침';

  @override
  String get archiveLoadingSemantics => '일기 보관함 불러오는 중';

  @override
  String get archiveNoResultsSemantics => '일기 검색 결과 없음';

  @override
  String get archiveNoResultsTitle => '검색 결과가 없어요';

  @override
  String get archiveNoResultsBody =>
      '날짜는 2026-10-04 형식으로 찾거나, 기분과 한 줄 요약의 다른 단어를 입력해 보세요.';

  @override
  String get archiveEmptySemantics => '비어 있는 일기 보관함';

  @override
  String get archiveEmptyTitle => '아직 보관된 일기가 없어요';

  @override
  String get archiveEmptyBody => '오늘 나눈 이야기로 일기를 만들면 이곳에 차곡차곡 모여요.';

  @override
  String get archiveLoadErrorSemantics => '일기 불러오기 오류';

  @override
  String get archiveLoadErrorTitle => '일기를 불러오지 못했어요';

  @override
  String get archiveStoredDataSafeBody => '기기에 저장된 내용은 그대로예요. 잠시 후 다시 시도해 주세요.';

  @override
  String get archiveRefreshError => '새로고침하지 못했어요. 기존 일기는 그대로 볼 수 있어요.';

  @override
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  ) {
    return '$date, 기분 $mood, $status, $summary';
  }

  @override
  String archiveMoodLabel(String mood) {
    return '기분 · $mood';
  }

  @override
  String get archiveOpenDiarySemantics => '일기 열기';

  @override
  String get chatLoadError => '저장된 대화를 불러오지 못했어요.';

  @override
  String get chatPhotoPickerUnavailable => '사진 선택기를 사용할 수 없는 환경이에요.';

  @override
  String get chatPrompt => '오늘 있었던 일을 들려주세요';

  @override
  String get chatLocalFirstBody => '메시지는 AI 요청 전에 이 기기에 먼저 저장돼요.';

  @override
  String chatAiFriendProfileSemantics(String name) {
    return 'AI 친구 $name의 프로필';
  }

  @override
  String get chatGatewaySetupNeeded => 'AI 연결 설정이 필요해요';

  @override
  String get chatAiReady => 'AI 답변을 받을 준비가 됐어요';

  @override
  String get chatConsentNeeded => 'AI 전송 동의가 필요해요';

  @override
  String get chatPersonaSettingsTooltip => 'AI 친구 설정';

  @override
  String get chatConnectionBadgeNeedsSetup => 'AI 연결 필요';

  @override
  String get chatConnectionBadgeReady => 'AI 준비됨';

  @override
  String get chatConnectionBadgeNeedsConsent => '동의 필요';

  @override
  String get chatTodayDivider => '오늘';

  @override
  String chatPersonaProfileSemantics(String name) {
    return '$name의 프로필';
  }

  @override
  String get chatReplyFailed => 'AI 답변을 받지 못했어요';

  @override
  String get chatTypingSemantics => 'AI가 답변을 작성하고 있어요';

  @override
  String get chatOpenDiary => '오늘의 일기 보기';

  @override
  String get chatAttachPhotoTooltip => '사진 첨부';

  @override
  String get chatSendMessageTooltip => '메시지 보내기';

  @override
  String get consentDisclosureSemantics => 'AI 데이터 전송 안내';

  @override
  String get consentTitle => 'AI에게 보내는 정보';

  @override
  String get consentTransferBody =>
      'AI 답변과 일기 초안을 만들 때 입력한 글, 제한된 최근 대화, 승인한 기억, AI 프로필과 사진 첨부 정보를 설정된 AI Gateway로 보내요.';

  @override
  String get consentPhotoBoundaryBody =>
      '현재 사진 원본은 보내지 않아요. 사진의 식별자와 대화 속 위치만 전송하며, 앞으로 사진 분석 기능이 사진 내용을 보내려면 별도 동의를 받아야 해요.';

  @override
  String get consentLocalUseBody =>
      '대화, 일기와 사진 원본은 이 기기에 저장돼요. 동의하지 않아도 로컬 기록을 사용할 수 있고, 설정에서 언제든 동의하거나 철회할 수 있어요.';

  @override
  String get consentSaveFailed => '선택을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get consentAcceptAndStart => 'AI 전송에 동의하고 시작';

  @override
  String get consentDeclineAndUseLocal => '동의 없이 로컬 기록만 사용';

  @override
  String get consentLoadError =>
      'AI 데이터 전송 설정을 확인하지 못했어요.\n확인 전에는 AI 요청을 보내지 않아요.';

  @override
  String get consentSettingsTitle => 'AI 데이터 전송';

  @override
  String consentSettingsStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'allowed': 'AI 데이터 전송: 동의함',
      'declined': 'AI 데이터 전송: 동의하지 않음',
      'other': 'AI 데이터 전송: 미결정',
    });
    return '$_temp0';
  }

  @override
  String get consentSettingsRequestBody =>
      'AI 답변과 일기 초안을 요청할 때 글, 제한된 최근 대화, 승인한 기억, AI 프로필과 사진 첨부 정보를 설정된 AI Gateway로 보내요.';

  @override
  String get consentSettingsPhotoBody =>
      '현재 사진 원본은 전송하지 않아요. 동의를 철회하면 이후 AI 요청은 즉시 차단되고 로컬 기록은 그대로 사용할 수 있어요.';

  @override
  String get consentSettingsSaveFailed => '설정을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get consentRevoke => '동의 철회';

  @override
  String get consentAccept => 'AI 전송에 동의';

  @override
  String get diaryEditorValidationError => '기분, 날씨, 한 줄 요약, 본문을 확인해 주세요.';

  @override
  String get diaryEditorSaveFailed => '일기를 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get diaryEditorTitle => '오늘의 일기 수정';

  @override
  String get diaryEditorSubtitle =>
      'AI 초안의 날씨, 기분, 한 줄 요약, 문장과 사진 순서를 직접 정할 수 있어요.';

  @override
  String get diaryEditorMoodLabel => '오늘의 기분';

  @override
  String get diaryEditorSummaryLabel => '오늘의 한 줄';

  @override
  String get diaryEditorWeatherTitle => '날씨 기록';

  @override
  String get diaryEditorWeatherSubtitle => '위치 권한 없이 오늘 날씨를 직접 적어요.';

  @override
  String get diaryEditorWeatherConditionLabel => '날씨';

  @override
  String get diaryEditorWeatherConditionHint => '맑음, 흐림, 비';

  @override
  String get diaryEditorTemperatureLabel => '기온 (°C)';

  @override
  String get diaryEditorOptionalHint => '선택';

  @override
  String get diaryEditorBackgroundLabel => '배경';

  @override
  String get diaryEditorLightBackground => '밝은 배경';

  @override
  String get diaryEditorDarkBackground => '어두운 배경';

  @override
  String get diaryEditorContentTitle => '본문과 사진';

  @override
  String get diaryEditorAddParagraph => '문단 추가';

  @override
  String get diaryEditorSaveChanges => '변경 내용 저장';

  @override
  String get diaryEditorMoveUpTooltip => '위로 이동';

  @override
  String get diaryEditorMoveDownTooltip => '아래로 이동';

  @override
  String get diaryEditorRemoveBlockTooltip => '블록 제외';

  @override
  String get diaryEditorParagraphLabel => '문단';

  @override
  String get diaryPreviewFinalizedHelp => '공유하기는 게시 완료가 아니라 기기의 공유 화면을 열어요.';

  @override
  String get diaryPreviewDraftHelp => 'AI가 만든 초안이에요. 확인하고 수정한 뒤 확정해 주세요.';

  @override
  String get diaryPreviewTitle => '오늘의 기록';

  @override
  String get diaryPreviewCreateSubtitle => '대화를 바탕으로 일기 초안을 만들어요';

  @override
  String get diaryPreviewStoredSubtitle => '기기에 저장된 일기 · 수정 기록을 함께 보관해요';

  @override
  String get diaryPreviewEmptyTitle => '아직 오늘의 일기가 없어요';

  @override
  String get diaryPreviewEmptyCanGenerate =>
      '오늘 나눈 이야기를 글과 사진이 섞인 일기 초안으로 정리해요.';

  @override
  String get diaryPreviewEmptyNeedsChat => '먼저 오늘의 이야기를 남겨주세요.';

  @override
  String get diaryPreviewGenerating => '초안 만드는 중';

  @override
  String get diaryPreviewGenerate => '오늘 일기 만들기';

  @override
  String diaryPreviewPageSemantics(int currentPage, int pageCount) {
    return '전체 $pageCount쪽 중 $currentPage쪽';
  }

  @override
  String diaryPreviewPageIndicator(int currentPage, int pageCount) {
    return '$currentPage / $pageCount';
  }

  @override
  String get diaryPreviewPreviousPageTooltip => '이전 일기 페이지';

  @override
  String get diaryPreviewNextPageTooltip => '다음 일기 페이지';

  @override
  String get diaryPreviewOneLineLabel => '오늘의 한 줄';

  @override
  String get diaryPreviewBrandSemantics => 'Namu 일기';

  @override
  String get diaryPreviewBrandHeading => 'NAMU DIARY';

  @override
  String get diaryWeatherNone => '날씨 없음';

  @override
  String get diaryWeatherManualSource => '직접 입력';

  @override
  String diaryWeatherSourceAndCondition(String source, String condition) {
    return '$source · $condition';
  }

  @override
  String diaryWeatherSourceConditionTemperature(
    String source,
    String condition,
    String temperature,
  ) {
    return '$source · $condition $temperature°';
  }

  @override
  String get diaryEditAction => '수정하기';

  @override
  String get diaryShareAction => '공유하기';

  @override
  String get diaryFinalizeAction => '일기 확정';

  @override
  String get memoryApproveFailed => '기억을 승인하지 못했어요. 다시 시도해 주세요.';

  @override
  String get memoryEditFailed => '기억을 수정하지 못했어요. 다시 시도해 주세요.';

  @override
  String get memoryDeleteFailed => '기억을 삭제하지 못했어요. 다시 시도해 주세요.';

  @override
  String get memoryActivateFailed => '기억을 다시 사용하지 못했어요. 다시 시도해 주세요.';

  @override
  String get memoryDeactivateFailed => '기억 사용을 중지하지 못했어요. 다시 시도해 주세요.';

  @override
  String get memoryTitle => 'AI 기억';

  @override
  String get memorySubtitle => '다음 대화에 쓸 사실을 직접 확인하고 관리해요';

  @override
  String get memoryReloadTooltip => '기억 목록 새로고침';

  @override
  String get memoryLoadingSemantics => '기억 목록 불러오는 중';

  @override
  String get memoryEmptySemantics => '비어 있는 AI 기억';

  @override
  String get memoryEmptyTitle => '아직 저장된 기억이 없어요';

  @override
  String get memoryEmptyBody => '하루를 정리하며 나온 후보를 직접 승인하면 이곳에서 관리할 수 있어요.';

  @override
  String get memoryLoadErrorSemantics => '기억 불러오기 오류';

  @override
  String get memoryLoadErrorTitle => '기억을 불러오지 못했어요';

  @override
  String get memoryStoredDataSafeBody => '기기에 저장된 내용은 그대로예요. 잠시 후 다시 시도해 주세요.';

  @override
  String get memoryRefreshError => '새로고침하지 못했어요. 기존 기억은 그대로 볼 수 있어요.';

  @override
  String memoryCardSemantics(String fact, String status, String category) {
    return '기억, $fact, 상태 $status, 분류 $category';
  }

  @override
  String get memorySensitiveApprovalNotice => '민감한 기억 · 직접 승인 필요';

  @override
  String get memoryChangingSemantics => '기억 변경 중';

  @override
  String get memoryDeactivateAction => '사용 중지';

  @override
  String get memoryActivateAction => '다시 사용';

  @override
  String get memoryEditAction => '문구 수정';

  @override
  String get memoryApproveSensitiveTitle => '민감한 기억을 사용할까요?';

  @override
  String get memoryApproveRegularTitle => '이 기억을 사용할까요?';

  @override
  String get memoryApproveSensitiveBody =>
      '승인하면 다음 AI 대화에 사용될 수 있어요. 내용을 확인한 뒤 직접 결정해 주세요.';

  @override
  String get memoryApproveRegularBody => '승인한 기억만 다음 AI 대화의 맥락으로 사용할 수 있어요.';

  @override
  String get memoryEditValidationError => '기억할 문장을 입력해 주세요.';

  @override
  String get memoryEditDialogTitle => '기억 문구 수정';

  @override
  String get memoryEditFieldLabel => 'AI가 기억할 사실';

  @override
  String get memoryDeleteDialogTitle => '이 기억을 삭제할까요?';

  @override
  String get memoryDeleteDialogBody =>
      '삭제하면 이후 AI 대화에 사용되지 않아요. 이 작업은 되돌릴 수 없어요.';

  @override
  String memoryStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'candidate': '검토 필요',
      'active': '사용 중',
      'inactive': '사용 안 함',
      'other': '알 수 없음',
    });
    return '$_temp0';
  }

  @override
  String memoryCategoryLabel(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'preference': '취향',
      'routine': '습관',
      'relationship': '관계',
      'place': '장소',
      'milestone': '중요한 일',
      'other': '기타',
    });
    return '$_temp0';
  }

  @override
  String get onboardingSemantics => '온보딩 안내';

  @override
  String get onboardingTitle => '시작하기 전에 알아두세요';

  @override
  String get onboardingLocalStorageTitle => '기록은 이 기기에 저장해요';

  @override
  String get onboardingLocalStorageBody =>
      '대화, 일기와 사진은 앱 전용 저장 공간에 남아요. 클라우드 동기화·백업·다른 기기 복원은 제공하지 않아요. 앱을 삭제하거나 기기를 잃으면 기록을 복구할 수 없어요.';

  @override
  String get onboardingAiDisclosureTitle => 'AI와 대화해요';

  @override
  String get onboardingAiDisclosureBody =>
      'AI 친구는 사람이 아닌 생성형 AI예요. 친근하게 반응하지만 사실과 다른 말을 할 수 있으므로 중요한 판단은 따로 확인해 주세요.';

  @override
  String get onboardingAiTransferTitle => 'AI 전송은 선택이에요';

  @override
  String get onboardingAiTransferBody =>
      '동의하면 AI 답변과 일기 초안을 위해 글, 제한된 최근 대화, 승인한 기억, AI 프로필과 사진 첨부 정보를 설정된 AI Gateway로 보내요. 현재 사진 원본은 전송하지 않아요.';

  @override
  String get onboardingDecisionNote =>
      '지금 결정하지 않아도 로컬 기록을 쓸 수 있어요. 나중에 설정에서 AI 전송에 동의하거나 철회할 수 있어요.';

  @override
  String get onboardingSaveFailed => '선택을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get onboardingAcceptAi => 'AI 전송에 동의하고 시작';

  @override
  String get onboardingStartLocal => '지금은 AI 없이 시작';

  @override
  String get onboardingLoadError => '온보딩 상태를 확인하지 못했어요.';

  @override
  String get personaDefaultName => '모아';

  @override
  String get personaDefaultTone => '따뜻하고 호기심 있게';

  @override
  String get personaAvatarSprout => '새싹';

  @override
  String get personaAvatarLeaf => '나뭇잎';

  @override
  String get personaAvatarSunlight => '햇살';

  @override
  String get personaAvatarMoonlight => '달빛';

  @override
  String get personaValidationError => '이름과 말투를 확인해 주세요.';

  @override
  String get personaSaveFailed => '설정을 저장하지 못했어요. 다시 시도해 주세요.';

  @override
  String get personaSettingsTitle => 'AI 친구 설정';

  @override
  String get personaSettingsSubtitle =>
      '한 명의 AI 친구 이름과 대화 스타일을 정할 수 있어요. 사용자 지침은 안전 정책보다 우선하지 않아요.';

  @override
  String get personaNameLabel => '이름';

  @override
  String get personaProfileLabel => '프로필';

  @override
  String get personaToneLabel => '말투와 성격';

  @override
  String get personaToneHint => '예: 따뜻하고 호기심 있게';

  @override
  String get personaReactionLengthLabel => '반응 길이';

  @override
  String get personaReactionConcise => '간결하게';

  @override
  String get personaReactionBalanced => '균형 있게';

  @override
  String get personaReactionExpressive => '풍부하게';

  @override
  String get personaInstructionsLabel => '추가로 바라는 대화 방식 (선택)';

  @override
  String get personaInstructionsHint => '예: 질문은 한 번에 하나만 해줘.';

  @override
  String get personaAiConsentAction => 'AI 데이터 전송 설정';

  @override
  String get settingsExportDialogTitle => '기록 JSON을 내보낼까요?';

  @override
  String get exportDialogBody =>
      '대화, 일기, 기억, AI 친구 설정과 AI 전송 동의 상태가 포함돼요. 사진 원본과 게시용 이미지는 포함되지 않으며, 이 파일로 앱을 복원할 수 없어요. 외부 앱이나 파일로 공유한 사본은 앱에서 회수하거나 삭제할 수 없어요.';

  @override
  String get settingsExportOpened => '공유·저장 화면을 열었어요.';

  @override
  String get settingsExportCancelled => '내보내기를 취소했어요.';

  @override
  String get settingsExportUnavailable => '이 기기에서 공유·저장 화면을 열 수 없어요.';

  @override
  String get settingsExportFailed => '기록을 내보내지 못했어요. 다시 시도해 주세요.';

  @override
  String get settingsDeleteAllDialogTitle => '모든 로컬 데이터를 삭제할까요?';

  @override
  String get settingsResetPreviewDialogTitle => '미리보기 데이터를 초기화할까요?';

  @override
  String get settingsDeleteAllDialogBody =>
      '대화, 일기, 사진, AI 친구 설정, AI 기억, 앱 안의 내보내기 파일과 AI 전송 동의를 이 기기에서 모두 삭제해요. 삭제 후에는 복구할 수 없고, 외부 앱이나 파일로 내보낸 사본은 삭제할 수 없어요.';

  @override
  String get settingsResetPreviewDialogBody =>
      '이 브라우저 미리보기의 임시 데이터만 초기화해요. 기기 저장소 삭제를 검증하는 동작이 아니에요.';

  @override
  String get settingsDeleteAllAction => '모두 삭제';

  @override
  String get settingsAiSectionTitle => 'AI';

  @override
  String get settingsPersonaTitle => 'AI 친구 설정';

  @override
  String get settingsPersonaSubtitle => '이름, 말투, 프로필과 반응 길이';

  @override
  String get settingsConsentTitle => 'AI 데이터 전송 설정';

  @override
  String get settingsConsentSubtitle => '전송 동의를 확인하거나 철회해요';

  @override
  String get settingsMyDataSectionTitle => '내 데이터';

  @override
  String get settingsTransientStorageTitle => '브라우저 임시 저장';

  @override
  String get settingsDeviceStorageTitle => '이 기기에만 저장';

  @override
  String get settingsTransientStorageBody =>
      '브라우저 미리보기의 임시 데이터이며 다시 실행하면 사라질 수 있어요.';

  @override
  String get settingsDeviceStorageBody =>
      '대화, 일기와 사진은 기기 안에 저장되며 앱 삭제나 기기 분실 뒤 복구할 수 없어요.';

  @override
  String get settingsExportJsonTitle => '기록 JSON 내보내기';

  @override
  String get settingsExportWebUnavailable => '브라우저 미리보기에서는 내보내기를 지원하지 않아요.';

  @override
  String get settingsExportJsonSubtitle =>
      '대화·일기·기억·AI 설정을 JSON으로 내보내요. 사진 파일은 포함하지 않아요.';

  @override
  String get settingsResetPreviewTitle => '미리보기 데이터 초기화';

  @override
  String get settingsDeleteAllTitle => '모든 로컬 데이터 삭제';

  @override
  String get settingsResetPreviewSubtitle => '기기 삭제가 아니라 현재 임시 상태만 비워요.';

  @override
  String get settingsDeleteAllSubtitle =>
      'AI 전송 동의를 포함한 앱 내부 데이터를 되돌릴 수 없게 삭제해요.';

  @override
  String get settingsResetFailed => '데이터 삭제를 완료하지 못했어요. 다시 시도해 주세요.';

  @override
  String get settingsExportShareText => 'Namu 로컬 기록 JSON 내보내기';

  @override
  String get shareSheetOpenedNotPosted =>
      '공유 화면을 열었어요. 게시 여부는 선택한 앱에서 확인해 주세요.';

  @override
  String get shareRendererTodayTitle => '오늘의 기록';

  @override
  String get shareRendererPhotoUnavailable => '사진을 불러올 수 없어요';

  @override
  String shareRendererPageNumber(int pageNumber, int pageCount) {
    return '$pageNumber / $pageCount';
  }

  @override
  String shareRendererWeatherWithTemperature(
    String condition,
    String temperature,
  ) {
    return '$condition $temperature°C';
  }

  @override
  String shareCaptionMetadata(String date, String weather, String mood) {
    return '$date · $weather · $mood';
  }

  @override
  String get todayNoDiaryToEdit => '수정할 일기가 없어요.';

  @override
  String get todayChatRefreshFailed => '오늘의 대화를 다시 확인하지 못했어요.';

  @override
  String get todayPhotoAttachedReplyFailed =>
      '사진을 첨부했지만 AI 답변을 받지 못했어요. 기록은 기기에 남아 있어요.';

  @override
  String get todayPhotoMobileAndGatewayNeeded =>
      '사진 선택은 모바일 앱에서 사용할 수 있어요. AI Gateway 연결도 필요해요.';

  @override
  String get todayConsentNeededForDiary => 'AI 전송에 동의하면 일기 초안을 만들 수 있어요.';

  @override
  String get todayFinalizeFailed => '일기를 확정해 저장하지 못했어요.';

  @override
  String get todayMemoryCandidatesFailed => '일기는 저장했지만 기억 후보를 준비하지 못했어요.';

  @override
  String get todayNoDiaryToShare => '공유할 일기가 없어요.';

  @override
  String get todayShareUnavailable => '이 환경에서는 공유 화면을 열 수 없어요.';

  @override
  String get todayShareCancelled => '공유를 취소했어요. 일기는 기기에 그대로 있어요.';

  @override
  String get todayShareImageFailed => '공유 이미지를 만들지 못했어요. 다시 시도해 주세요.';

  @override
  String get todayDiaryAlreadyVisible => '오늘의 일기가 오른쪽에 열려 있어요.';

  @override
  String get todayNavChat => '대화';

  @override
  String get todayNavDiary => '오늘의 일기';

  @override
  String get todayNavArchive => '보관함';

  @override
  String get todayNavMemory => '기억';

  @override
  String get todayNavSettings => '설정';
}
