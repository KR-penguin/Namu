// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Namu';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonRetryShort => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonApprove => 'Approve';

  @override
  String get commonExport => 'Export';

  @override
  String get commonAttachedPhoto => 'Attached photo';

  @override
  String commonDiaryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'finalized': 'Final',
      'draft': 'Draft',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String commonWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'other': 'Unknown day',
    });
    return '$_temp0';
  }

  @override
  String commonFullDate(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String commonFullDateWithWeekday(
    int year,
    int month,
    int day,
    String weekday,
  ) {
    return '$weekday, $month/$day/$year';
  }

  @override
  String commonMonthDayWithWeekday(int month, int day, String weekday) {
    return '$weekday, $month/$day';
  }

  @override
  String get bootstrapResetDeleting => 'Deleting local data from this device…';

  @override
  String get bootstrapResetFailedTitle => 'Couldn’t finish deleting your data';

  @override
  String get bootstrapResetFailedBody =>
      'Namu stopped safely without reopening your records. Try deleting them again.';

  @override
  String get bootstrapResetRetry => 'Try deleting again';

  @override
  String get bootstrapTimeZoneFailedTitle => 'Couldn’t load your time zone';

  @override
  String get bootstrapTimeZoneFailedBody =>
      'Namu needs your time zone to keep each day’s records separate.';

  @override
  String get gatewayPreservedChat => 'Your message is still on this device.';

  @override
  String get gatewayPreservedDiary => 'Today’s record is still on this device.';

  @override
  String gatewayUnknownChat(String preserved) {
    return 'Couldn’t get an AI reply. $preserved';
  }

  @override
  String gatewayUnknownDiary(String preserved) {
    return 'Couldn’t create a diary draft. $preserved';
  }

  @override
  String gatewayUnconfigured(String preserved) {
    return 'AI connection settings are required. $preserved';
  }

  @override
  String gatewayUnauthorized(String preserved) {
    return 'Couldn’t verify the AI connection. Try again in a moment. $preserved';
  }

  @override
  String gatewayInvalidAttestation(String preserved) {
    return 'Couldn’t verify this device for AI access. Reopen the app and try again. $preserved';
  }

  @override
  String gatewayRateLimited(String retryGuidance, String preserved) {
    return 'AI is receiving too many requests right now. $retryGuidance $preserved';
  }

  @override
  String get gatewayRequestTooLargeChat =>
      'This message is too long to send to AI. Split it into a new message and try again. The original is still on this device.';

  @override
  String gatewayRequestTooLargeDiary(String preserved) {
    return 'Today’s record is too long to send to AI. $preserved';
  }

  @override
  String gatewayResponseTooLarge(String preserved) {
    return 'The AI reply was too long, so it wasn’t displayed. Try again. $preserved';
  }

  @override
  String get gatewayIdempotencyConflictChat =>
      'This request can’t be safely retried. Start a new message instead. The original is still on this device.';

  @override
  String gatewayIdempotencyConflictDiary(String preserved) {
    return 'This request can’t be safely retried. Reopen the app and try again. $preserved';
  }

  @override
  String gatewayRejected(String preserved) {
    return 'AI couldn’t process this request. Review it and try again. $preserved';
  }

  @override
  String gatewaySafetyBlockedChat(String preserved) {
    return 'AI safety rules prevent a reply to this request. $preserved';
  }

  @override
  String gatewaySafetyBlockedDiary(String preserved) {
    return 'AI safety rules prevent creating a diary draft from this request. $preserved';
  }

  @override
  String gatewayTimeout(String preserved) {
    return 'The AI reply was taking too long, so Namu stopped waiting. Try again. $preserved';
  }

  @override
  String gatewayTruncated(String preserved) {
    return 'The AI reply was incomplete, so it wasn’t displayed. Try again. $preserved';
  }

  @override
  String gatewayInvalidResponse(String preserved) {
    return 'The AI reply format couldn’t be verified, so it wasn’t displayed. Try again. $preserved';
  }

  @override
  String gatewayServerUnavailable(String preserved) {
    return 'The AI service is temporarily unstable. Try again in a moment. $preserved';
  }

  @override
  String gatewayNetworkUnavailable(String preserved) {
    return 'Couldn’t connect to the network. Check your connection and try again. $preserved';
  }

  @override
  String get gatewayRetrySoon => 'Try again in a moment.';

  @override
  String gatewayRetryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Try again in about $count seconds.',
      one: 'Try again in about 1 second.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Try again in about $count minutes.',
      one: 'Try again in about 1 minute.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Try again in about $count hours.',
      one: 'Try again in about 1 hour.',
    );
    return '$_temp0';
  }

  @override
  String get archiveSearchSemantics => 'Search the diary archive';

  @override
  String get archiveSearchLabel => 'Search archive';

  @override
  String get archiveSearchHint => '2026-10-04, mood, or one-line summary';

  @override
  String get archiveClearSearchTooltip => 'Clear search';

  @override
  String get archiveTitle => 'Diary archive';

  @override
  String get archiveSubtitle => 'Revisit days saved on this device';

  @override
  String get archiveReloadTooltip => 'Refresh diary list';

  @override
  String get archiveLoadingSemantics => 'Loading diary archive';

  @override
  String get archiveNoResultsSemantics => 'No diary search results';

  @override
  String get archiveNoResultsTitle => 'No results found';

  @override
  String get archiveNoResultsBody =>
      'Search for a date like 2026-10-04, or try different words from the mood or one-line summary.';

  @override
  String get archiveEmptySemantics => 'Empty diary archive';

  @override
  String get archiveEmptyTitle => 'No saved diaries yet';

  @override
  String get archiveEmptyBody =>
      'Create a diary from today’s conversation and it will collect here over time.';

  @override
  String get archiveLoadErrorSemantics => 'Diary loading error';

  @override
  String get archiveLoadErrorTitle => 'Couldn’t load your diaries';

  @override
  String get archiveStoredDataSafeBody =>
      'Your saved data is unchanged. Try again in a moment.';

  @override
  String get archiveRefreshError =>
      'Couldn’t refresh. You can still view the diaries already loaded.';

  @override
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  ) {
    return '$date, mood $mood, $status, $summary';
  }

  @override
  String archiveMoodLabel(String mood) {
    return 'Mood · $mood';
  }

  @override
  String get archiveOpenDiarySemantics => 'Open diary';

  @override
  String get chatLoadError => 'Couldn’t load your saved conversation.';

  @override
  String get chatPhotoPickerUnavailable =>
      'Photo selection isn’t available in this environment.';

  @override
  String get chatPrompt => 'Tell me about your day';

  @override
  String get chatLocalFirstBody =>
      'Messages are saved on this device before they are sent to AI.';

  @override
  String chatAiFriendProfileSemantics(String name) {
    return 'Profile for AI companion $name';
  }

  @override
  String get chatGatewaySetupNeeded => 'AI connection settings are required';

  @override
  String get chatAiReady => 'Ready for AI replies';

  @override
  String get chatConsentNeeded => 'AI data-sharing consent is required';

  @override
  String get chatPersonaSettingsTooltip => 'AI companion settings';

  @override
  String get chatConnectionBadgeNeedsSetup => 'AI setup needed';

  @override
  String get chatConnectionBadgeReady => 'AI ready';

  @override
  String get chatConnectionBadgeNeedsConsent => 'Consent needed';

  @override
  String get chatTodayDivider => 'Today';

  @override
  String chatPersonaProfileSemantics(String name) {
    return '$name’s profile';
  }

  @override
  String get chatReplyFailed => 'Couldn’t get an AI reply';

  @override
  String get chatTypingSemantics => 'AI is writing a reply';

  @override
  String get chatOpenDiary => 'View today’s diary';

  @override
  String get chatAttachPhotoTooltip => 'Attach photo';

  @override
  String get chatSendMessageTooltip => 'Send message';

  @override
  String get consentDisclosureSemantics => 'AI data-sharing notice';

  @override
  String get consentTitle => 'Information sent to AI';

  @override
  String get consentTransferBody =>
      'To create AI replies and diary drafts, Namu sends the text you enter, limited recent conversations, approved memories, your AI profile, and photo attachment information to the configured AI Gateway.';

  @override
  String get consentPhotoBoundaryBody =>
      'Original photo files are not currently sent. Only photo identifiers and their positions in the conversation are sent. Separate consent is required before any future photo analysis feature can send photo content.';

  @override
  String get consentLocalUseBody =>
      'Chats, diaries, and original photos are stored on this device. You can use local records without consenting, and you can consent or withdraw consent at any time in Settings.';

  @override
  String get consentSaveFailed => 'Couldn’t save your choice. Try again.';

  @override
  String get consentAcceptAndStart => 'Agree to AI data sharing and start';

  @override
  String get consentDeclineAndUseLocal => 'Use local records without agreeing';

  @override
  String get consentLoadError =>
      'Couldn’t check your AI data-sharing setting.\nNo AI request will be sent until it is checked.';

  @override
  String get consentSettingsTitle => 'AI data sharing';

  @override
  String consentSettingsStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'allowed': 'AI data sharing: Allowed',
      'declined': 'AI data sharing: Not allowed',
      'other': 'AI data sharing: Not decided',
    });
    return '$_temp0';
  }

  @override
  String get consentSettingsRequestBody =>
      'When you request an AI reply or diary draft, Namu sends your text, limited recent conversations, approved memories, AI profile, and photo attachment information to the configured AI Gateway.';

  @override
  String get consentSettingsPhotoBody =>
      'Original photo files are not currently sent. If you withdraw consent, future AI requests are blocked immediately and your local records remain available.';

  @override
  String get consentSettingsSaveFailed =>
      'Couldn’t save this setting. Try again.';

  @override
  String get consentRevoke => 'Withdraw consent';

  @override
  String get consentAccept => 'Agree to AI data sharing';

  @override
  String get diaryEditorValidationError =>
      'Check the mood, weather, one-line summary, and diary content.';

  @override
  String get diaryEditorSaveFailed => 'Couldn’t save the diary. Try again.';

  @override
  String get diaryEditorTitle => 'Edit today’s diary';

  @override
  String get diaryEditorSubtitle =>
      'You can change the AI draft’s weather, mood, one-line summary, writing, and photo order.';

  @override
  String get diaryEditorMoodLabel => 'Today’s mood';

  @override
  String get diaryEditorSummaryLabel => 'Today in one line';

  @override
  String get diaryEditorWeatherTitle => 'Weather';

  @override
  String get diaryEditorWeatherSubtitle =>
      'Enter today’s weather yourself without location access.';

  @override
  String get diaryEditorWeatherConditionLabel => 'Conditions';

  @override
  String get diaryEditorWeatherConditionHint => 'Sunny, cloudy, rain';

  @override
  String get diaryEditorTemperatureLabel => 'Temperature (°C)';

  @override
  String get diaryEditorOptionalHint => 'Optional';

  @override
  String get diaryEditorBackgroundLabel => 'Background';

  @override
  String get diaryEditorLightBackground => 'Light background';

  @override
  String get diaryEditorDarkBackground => 'Dark background';

  @override
  String get diaryEditorContentTitle => 'Writing and photos';

  @override
  String get diaryEditorAddParagraph => 'Add paragraph';

  @override
  String get diaryEditorSaveChanges => 'Save changes';

  @override
  String get diaryEditorMoveUpTooltip => 'Move up';

  @override
  String get diaryEditorMoveDownTooltip => 'Move down';

  @override
  String get diaryEditorRemoveBlockTooltip => 'Remove block';

  @override
  String get diaryEditorParagraphLabel => 'Paragraph';

  @override
  String get diaryPreviewFinalizedHelp =>
      'Sharing opens this device’s share screen; it does not mean the diary was posted.';

  @override
  String get diaryPreviewDraftHelp =>
      'This is an AI-generated draft. Review and edit it before making it final.';

  @override
  String get diaryPreviewTitle => 'Today’s record';

  @override
  String get diaryPreviewCreateSubtitle =>
      'Create a diary draft from your conversation';

  @override
  String get diaryPreviewStoredSubtitle =>
      'Saved on this device · edit history preserved';

  @override
  String get diaryPreviewEmptyTitle => 'No diary for today yet';

  @override
  String get diaryPreviewEmptyCanGenerate =>
      'Turn today’s conversation into a diary draft with writing and photos.';

  @override
  String get diaryPreviewEmptyNeedsChat =>
      'Start by sharing something about your day.';

  @override
  String get diaryPreviewGenerating => 'Creating draft';

  @override
  String get diaryPreviewGenerate => 'Create today’s diary';

  @override
  String diaryPreviewPageSemantics(int currentPage, int pageCount) {
    return 'Diary page $currentPage of $pageCount';
  }

  @override
  String diaryPreviewPageIndicator(int currentPage, int pageCount) {
    return '$currentPage / $pageCount';
  }

  @override
  String get diaryPreviewPreviousPageTooltip => 'Previous diary page';

  @override
  String get diaryPreviewNextPageTooltip => 'Next diary page';

  @override
  String get diaryPreviewOneLineLabel => 'Today in one line';

  @override
  String get diaryPreviewBrandSemantics => 'Namu diary';

  @override
  String get diaryPreviewBrandHeading => 'NAMU DIARY';

  @override
  String get diaryWeatherNone => 'No weather';

  @override
  String get diaryWeatherManualSource => 'Entered manually';

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
  String get diaryEditAction => 'Edit';

  @override
  String get diaryShareAction => 'Share';

  @override
  String get diaryFinalizeAction => 'Make final';

  @override
  String get memoryApproveFailed => 'Couldn’t approve this memory. Try again.';

  @override
  String get memoryEditFailed => 'Couldn’t edit this memory. Try again.';

  @override
  String get memoryDeleteFailed => 'Couldn’t delete this memory. Try again.';

  @override
  String get memoryActivateFailed =>
      'Couldn’t start using this memory again. Try again.';

  @override
  String get memoryDeactivateFailed =>
      'Couldn’t stop using this memory. Try again.';

  @override
  String get memoryTitle => 'AI memory';

  @override
  String get memorySubtitle =>
      'Review and manage the facts used in future conversations';

  @override
  String get memoryReloadTooltip => 'Refresh memory list';

  @override
  String get memoryLoadingSemantics => 'Loading memory list';

  @override
  String get memoryEmptySemantics => 'Empty AI memory';

  @override
  String get memoryEmptyTitle => 'No saved memories yet';

  @override
  String get memoryEmptyBody =>
      'When you approve a memory candidate from a daily recap, you can manage it here.';

  @override
  String get memoryLoadErrorSemantics => 'Memory loading error';

  @override
  String get memoryLoadErrorTitle => 'Couldn’t load your memories';

  @override
  String get memoryStoredDataSafeBody =>
      'Your saved data is unchanged. Try again in a moment.';

  @override
  String get memoryRefreshError =>
      'Couldn’t refresh. You can still view the memories already loaded.';

  @override
  String memoryCardSemantics(String fact, String status, String category) {
    return 'Memory, $fact, status $status, category $category';
  }

  @override
  String get memorySensitiveApprovalNotice =>
      'Sensitive memory · approval required';

  @override
  String get memoryChangingSemantics => 'Updating memory';

  @override
  String get memoryDeactivateAction => 'Stop using';

  @override
  String get memoryActivateAction => 'Use again';

  @override
  String get memoryEditAction => 'Edit wording';

  @override
  String get memoryApproveSensitiveTitle => 'Use this sensitive memory?';

  @override
  String get memoryApproveRegularTitle => 'Use this memory?';

  @override
  String get memoryApproveSensitiveBody =>
      'If approved, it may be used in future AI conversations. Review the content and decide for yourself.';

  @override
  String get memoryApproveRegularBody =>
      'Only approved memories can be used as context in future AI conversations.';

  @override
  String get memoryEditValidationError =>
      'Enter something for the AI to remember.';

  @override
  String get memoryEditDialogTitle => 'Edit memory wording';

  @override
  String get memoryEditFieldLabel => 'Fact for AI to remember';

  @override
  String get memoryDeleteDialogTitle => 'Delete this memory?';

  @override
  String get memoryDeleteDialogBody =>
      'It will no longer be used in AI conversations. This can’t be undone.';

  @override
  String memoryStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'candidate': 'Needs review',
      'active': 'In use',
      'inactive': 'Not in use',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String memoryCategoryLabel(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'preference': 'Preference',
      'routine': 'Routine',
      'relationship': 'Relationship',
      'place': 'Place',
      'milestone': 'Milestone',
      'other': 'Other',
    });
    return '$_temp0';
  }

  @override
  String get onboardingSemantics => 'Getting-started information';

  @override
  String get onboardingTitle => 'Before you start';

  @override
  String get onboardingLocalStorageTitle => 'Your records stay on this device';

  @override
  String get onboardingLocalStorageBody =>
      'Chats, diaries, and photos stay in the app’s private storage. Cloud sync, backup, and restore on another device are not provided. If you delete the app or lose the device, your records cannot be recovered.';

  @override
  String get onboardingAiDisclosureTitle => 'Chat with AI';

  @override
  String get onboardingAiDisclosureBody =>
      'Your AI companion is a generative AI, not a person. It responds warmly but may be wrong, so verify important decisions separately.';

  @override
  String get onboardingAiTransferTitle => 'AI data sharing is optional';

  @override
  String get onboardingAiTransferBody =>
      'If you agree, your text, limited recent chats, approved memories, AI profile, and photo attachment information are sent to the configured AI Gateway to create replies and diary drafts. Original photo files are not currently sent.';

  @override
  String get onboardingDecisionNote =>
      'You can use local records without deciding now. You can agree to AI data sharing or withdraw consent later in Settings.';

  @override
  String get onboardingSaveFailed => 'Couldn’t save your choice. Try again.';

  @override
  String get onboardingAcceptAi => 'Agree to AI data sharing and start';

  @override
  String get onboardingStartLocal => 'Start without AI for now';

  @override
  String get onboardingLoadError =>
      'Couldn’t check your getting-started status.';

  @override
  String get personaDefaultName => 'Moa';

  @override
  String get personaDefaultTone => 'Warm and curious';

  @override
  String get personaAvatarSprout => 'Sprout';

  @override
  String get personaAvatarLeaf => 'Leaf';

  @override
  String get personaAvatarSunlight => 'Sunlight';

  @override
  String get personaAvatarMoonlight => 'Moonlight';

  @override
  String get personaValidationError => 'Check the name and conversation style.';

  @override
  String get personaSaveFailed => 'Couldn’t save these settings. Try again.';

  @override
  String get personaSettingsTitle => 'AI companion settings';

  @override
  String get personaSettingsSubtitle =>
      'Choose one AI companion’s name and conversation style. Your instructions never override safety rules.';

  @override
  String get personaNameLabel => 'Name';

  @override
  String get personaProfileLabel => 'Profile';

  @override
  String get personaToneLabel => 'Tone and personality';

  @override
  String get personaToneHint => 'For example: warm and curious';

  @override
  String get personaReactionLengthLabel => 'Reply length';

  @override
  String get personaReactionConcise => 'Concise';

  @override
  String get personaReactionBalanced => 'Balanced';

  @override
  String get personaReactionExpressive => 'Expressive';

  @override
  String get personaInstructionsLabel =>
      'Additional conversation preferences (optional)';

  @override
  String get personaInstructionsHint =>
      'For example: Ask only one question at a time.';

  @override
  String get personaAiConsentAction => 'AI data-sharing settings';

  @override
  String get settingsExportDialogTitle => 'Export your records as JSON?';

  @override
  String get exportDialogBody =>
      'This includes chats, diaries, memories, AI companion settings, and your AI data-sharing consent status. Original photos and shareable post images are not included, and this file cannot restore the app. Copies shared to other apps or files cannot be recalled or deleted by Namu.';

  @override
  String get settingsExportOpened => 'Opened the share and save screen.';

  @override
  String get settingsExportCancelled => 'Export cancelled.';

  @override
  String get settingsExportUnavailable =>
      'This device can’t open the share and save screen.';

  @override
  String get settingsExportFailed => 'Couldn’t export your records. Try again.';

  @override
  String get settingsDeleteAllDialogTitle => 'Delete all local data?';

  @override
  String get settingsResetPreviewDialogTitle => 'Reset preview data?';

  @override
  String get settingsDeleteAllDialogBody =>
      'This deletes chats, diaries, photos, AI companion settings, AI memories, in-app export files, and AI data-sharing consent from this device. It can’t be undone. Copies exported to other apps or files can’t be deleted by Namu.';

  @override
  String get settingsResetPreviewDialogBody =>
      'This resets only the temporary data in this browser preview. It does not verify deletion from device storage.';

  @override
  String get settingsDeleteAllAction => 'Delete all';

  @override
  String get settingsAiSectionTitle => 'AI';

  @override
  String get settingsPersonaTitle => 'AI companion settings';

  @override
  String get settingsPersonaSubtitle => 'Name, tone, profile, and reply length';

  @override
  String get settingsConsentTitle => 'AI data-sharing settings';

  @override
  String get settingsConsentSubtitle => 'Review or withdraw your consent';

  @override
  String get settingsMyDataSectionTitle => 'My data';

  @override
  String get settingsTransientStorageTitle => 'Temporary browser storage';

  @override
  String get settingsDeviceStorageTitle => 'Stored only on this device';

  @override
  String get settingsTransientStorageBody =>
      'This browser preview uses temporary data that may disappear when it restarts.';

  @override
  String get settingsDeviceStorageBody =>
      'Chats, diaries, and photos are stored on this device and can’t be recovered after the app is deleted or the device is lost.';

  @override
  String get settingsExportJsonTitle => 'Export records as JSON';

  @override
  String get settingsExportWebUnavailable =>
      'Export isn’t supported in the browser preview.';

  @override
  String get settingsExportJsonSubtitle =>
      'Export chats, diaries, memories, and AI settings as JSON. Photo files are not included.';

  @override
  String get settingsResetPreviewTitle => 'Reset preview data';

  @override
  String get settingsDeleteAllTitle => 'Delete all local data';

  @override
  String get settingsResetPreviewSubtitle =>
      'Clear only the current temporary state, not device data.';

  @override
  String get settingsDeleteAllSubtitle =>
      'Permanently delete in-app data, including AI data-sharing consent.';

  @override
  String get settingsResetFailed =>
      'Couldn’t finish deleting your data. Try again.';

  @override
  String get settingsExportShareText => 'Namu local records JSON export';

  @override
  String get shareSheetOpenedNotPosted =>
      'The share screen is open. Check the selected app to see whether anything was posted.';

  @override
  String get shareRendererTodayTitle => 'Today’s record';

  @override
  String get shareRendererPhotoUnavailable => 'Photo unavailable';

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
  String get todayNoDiaryToEdit => 'There’s no diary to edit.';

  @override
  String get todayChatRefreshFailed => 'Couldn’t refresh today’s conversation.';

  @override
  String get todayPhotoAttachedReplyFailed =>
      'The photo was attached, but no AI reply arrived. Your record is still on this device.';

  @override
  String get todayPhotoMobileAndGatewayNeeded =>
      'Photo selection is available in the mobile app. An AI Gateway connection is also required.';

  @override
  String get todayConsentNeededForDiary =>
      'Agree to AI data sharing to create a diary draft.';

  @override
  String get todayFinalizeFailed => 'Couldn’t save the diary as final.';

  @override
  String get todayMemoryCandidatesFailed =>
      'The diary was saved, but Namu couldn’t prepare memory suggestions.';

  @override
  String get todayNoDiaryToShare => 'There’s no diary to share.';

  @override
  String get todayShareUnavailable =>
      'The share screen isn’t available in this environment.';

  @override
  String get todayShareCancelled =>
      'Sharing was cancelled. Your diary is still on this device.';

  @override
  String get todayShareImageFailed =>
      'Couldn’t create the share images. Try again.';

  @override
  String get todayDiaryAlreadyVisible => 'Today’s diary is open on the right.';

  @override
  String get todayNavChat => 'Chat';

  @override
  String get todayNavDiary => 'Today’s diary';

  @override
  String get todayNavArchive => 'Archive';

  @override
  String get todayNavMemory => 'Memory';

  @override
  String get todayNavSettings => 'Settings';
}
