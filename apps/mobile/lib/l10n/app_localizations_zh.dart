// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Namu';

  @override
  String get settingsTitle => '设置';

  @override
  String get commonBack => '返回';

  @override
  String get commonClose => '关闭';

  @override
  String get commonRetry => '重试';

  @override
  String get commonRetryShort => '重试';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonApprove => '批准';

  @override
  String get commonExport => '导出';

  @override
  String get commonAttachedPhoto => '已附加照片';

  @override
  String commonDiaryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'finalized': '正式版',
      'draft': '草稿',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String commonWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': '星期一',
      'tuesday': '星期二',
      'wednesday': '星期三',
      'thursday': '星期四',
      'friday': '星期五',
      'saturday': '星期六',
      'sunday': '星期日',
      'other': '未知星期',
    });
    return '$_temp0';
  }

  @override
  String commonFullDate(int year, int month, int day) {
    return '$year年$month月$day日';
  }

  @override
  String commonFullDateWithWeekday(
    int year,
    int month,
    int day,
    String weekday,
  ) {
    return '$year年$month月$day日 $weekday';
  }

  @override
  String commonMonthDayWithWeekday(int month, int day, String weekday) {
    return '$month月$day日 $weekday';
  }

  @override
  String get bootstrapResetDeleting => '正在从此设备删除本地数据…';

  @override
  String get bootstrapResetFailedTitle => '未能完成数据删除';

  @override
  String get bootstrapResetFailedBody => 'Namu 已安全停止，没有重新打开你的记录。请再次尝试删除。';

  @override
  String get bootstrapResetRetry => '重新删除';

  @override
  String get bootstrapTimeZoneFailedTitle => '无法加载你的时区';

  @override
  String get bootstrapTimeZoneFailedBody => 'Namu 需要使用你的时区来区分每天的记录。';

  @override
  String get gatewayPreservedChat => '你的消息仍保存在此设备上。';

  @override
  String get gatewayPreservedDiary => '今天的记录仍保存在此设备上。';

  @override
  String gatewayUnknownChat(String preserved) {
    return '无法获取 AI 回复。$preserved';
  }

  @override
  String gatewayUnknownDiary(String preserved) {
    return '无法创建日记草稿。$preserved';
  }

  @override
  String gatewayUnconfigured(String preserved) {
    return '需要配置 AI 连接。$preserved';
  }

  @override
  String gatewayUnauthorized(String preserved) {
    return '无法验证 AI 连接。请稍后重试。$preserved';
  }

  @override
  String gatewayInvalidAttestation(String preserved) {
    return '无法验证此设备的 AI 访问权限。请重新打开应用后重试。$preserved';
  }

  @override
  String gatewayRateLimited(String retryGuidance, String preserved) {
    return 'AI 当前收到的请求过多。$retryGuidance $preserved';
  }

  @override
  String get gatewayRequestTooLargeChat =>
      '这条消息太长，无法发送给 AI。请拆分成一条新消息后重试。原消息仍保存在此设备上。';

  @override
  String gatewayRequestTooLargeDiary(String preserved) {
    return '今天的记录太长，无法发送给 AI。$preserved';
  }

  @override
  String gatewayResponseTooLarge(String preserved) {
    return 'AI 回复过长，因此未显示。请重试。$preserved';
  }

  @override
  String get gatewayIdempotencyConflictChat =>
      '无法安全地重试此请求。请改为发送一条新消息。原消息仍保存在此设备上。';

  @override
  String gatewayIdempotencyConflictDiary(String preserved) {
    return '无法安全地重试此请求。请重新打开应用后再试。$preserved';
  }

  @override
  String gatewayRejected(String preserved) {
    return 'AI 无法处理此请求。请检查后重试。$preserved';
  }

  @override
  String gatewaySafetyBlockedChat(String preserved) {
    return '根据 AI 安全规则，无法回复此请求。$preserved';
  }

  @override
  String gatewaySafetyBlockedDiary(String preserved) {
    return '根据 AI 安全规则，无法用此请求创建日记草稿。$preserved';
  }

  @override
  String gatewayTimeout(String preserved) {
    return 'AI 回复耗时过长，Namu 已停止等待。请重试。$preserved';
  }

  @override
  String gatewayTruncated(String preserved) {
    return 'AI 回复不完整，因此未显示。请重试。$preserved';
  }

  @override
  String gatewayInvalidResponse(String preserved) {
    return '无法验证 AI 回复的格式，因此未显示。请重试。$preserved';
  }

  @override
  String gatewayServerUnavailable(String preserved) {
    return 'AI 服务暂时不稳定。请稍后重试。$preserved';
  }

  @override
  String gatewayNetworkUnavailable(String preserved) {
    return '无法连接网络。请检查网络连接后重试。$preserved';
  }

  @override
  String get gatewayRetrySoon => '请稍后重试。';

  @override
  String gatewayRetryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请约 $count 秒后重试。',
      one: '请约 1 秒后重试。',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请约 $count 分钟后重试。',
      one: '请约 1 分钟后重试。',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '请约 $count 小时后重试。',
      one: '请约 1 小时后重试。',
    );
    return '$_temp0';
  }

  @override
  String get archiveSearchSemantics => '搜索日记归档';

  @override
  String get archiveSearchLabel => '搜索归档';

  @override
  String get archiveSearchHint => '2026-10-04、心情或一句话摘要';

  @override
  String get archiveClearSearchTooltip => '清除搜索内容';

  @override
  String get archiveTitle => '日记归档';

  @override
  String get archiveSubtitle => '回顾保存在此设备上的每一天';

  @override
  String get archiveReloadTooltip => '刷新日记列表';

  @override
  String get archiveLoadingSemantics => '正在加载日记归档';

  @override
  String get archiveNoResultsSemantics => '没有日记搜索结果';

  @override
  String get archiveNoResultsTitle => '未找到结果';

  @override
  String get archiveNoResultsBody => '可搜索 2026-10-04 这样的日期，或改用心情或一句话摘要中的其他词。';

  @override
  String get archiveEmptySemantics => '日记归档为空';

  @override
  String get archiveEmptyTitle => '还没有保存的日记';

  @override
  String get archiveEmptyBody => '根据今天的对话创建日记后，记录会逐渐汇集在这里。';

  @override
  String get archiveLoadErrorSemantics => '日记加载错误';

  @override
  String get archiveLoadErrorTitle => '无法加载你的日记';

  @override
  String get archiveStoredDataSafeBody => '已保存的数据没有改变。请稍后重试。';

  @override
  String get archiveRefreshError => '无法刷新。你仍可查看已加载的日记。';

  @override
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  ) {
    return '$date，心情 $mood，$status，$summary';
  }

  @override
  String archiveMoodLabel(String mood) {
    return '心情 · $mood';
  }

  @override
  String get archiveOpenDiarySemantics => '打开日记';

  @override
  String get chatLoadError => '无法加载已保存的对话。';

  @override
  String get chatPhotoPickerUnavailable => '当前环境无法选择照片。';

  @override
  String get chatPrompt => '说说你今天过得怎么样';

  @override
  String get chatLocalFirstBody => '消息会先保存在此设备上，再发送给 AI。';

  @override
  String chatAiFriendProfileSemantics(String name) {
    return 'AI 伙伴 $name 的资料';
  }

  @override
  String get chatGatewaySetupNeeded => '需要配置 AI 连接';

  @override
  String get chatAiReady => '可以接收 AI 回复';

  @override
  String get chatConsentNeeded => '需要同意共享 AI 数据';

  @override
  String get chatPersonaSettingsTooltip => 'AI 伙伴设置';

  @override
  String get chatConnectionBadgeNeedsSetup => '需要设置 AI';

  @override
  String get chatConnectionBadgeReady => 'AI 已就绪';

  @override
  String get chatConnectionBadgeNeedsConsent => '需要同意';

  @override
  String get chatTodayDivider => '今天';

  @override
  String chatPersonaProfileSemantics(String name) {
    return '$name 的资料';
  }

  @override
  String get chatReplyFailed => '无法获取 AI 回复';

  @override
  String get chatTypingSemantics => 'AI 正在撰写回复';

  @override
  String get chatOpenDiary => '查看今天的日记';

  @override
  String get chatAttachPhotoTooltip => '附加照片';

  @override
  String get chatSendMessageTooltip => '发送消息';

  @override
  String get consentDisclosureSemantics => 'AI 数据共享说明';

  @override
  String get consentTitle => '发送给 AI 的信息';

  @override
  String get consentTransferBody =>
      '为生成 AI 回复和日记草稿，Namu 会将你输入的文字、有限的近期对话、已批准的记忆、你的 AI 资料以及照片附件信息发送到已配置的 AI Gateway。';

  @override
  String get consentPhotoBoundaryBody =>
      '目前不会发送原始照片文件，只会发送照片标识及其在对话中的位置。未来如增加照片分析功能，必须另行征得同意后才能发送照片内容。';

  @override
  String get consentLocalUseBody =>
      '聊天、日记和原始照片都保存在此设备上。不同意也可以使用本地记录，并且可随时在“设置”中同意或撤回同意。';

  @override
  String get consentSaveFailed => '无法保存你的选择。请重试。';

  @override
  String get consentAcceptAndStart => '同意共享 AI 数据并开始';

  @override
  String get consentDeclineAndUseLocal => '不同意，仅使用本地记录';

  @override
  String get consentLoadError => '无法检查你的 AI 数据共享设置。\n确认设置前不会发送任何 AI 请求。';

  @override
  String get consentSettingsTitle => 'AI 数据共享';

  @override
  String consentSettingsStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'allowed': 'AI 数据共享：已允许',
      'declined': 'AI 数据共享：不允许',
      'other': 'AI 数据共享：未决定',
    });
    return '$_temp0';
  }

  @override
  String get consentSettingsRequestBody =>
      '当你请求 AI 回复或日记草稿时，Namu 会将你的文字、有限的近期对话、已批准的记忆、AI 资料以及照片附件信息发送到已配置的 AI Gateway。';

  @override
  String get consentSettingsPhotoBody =>
      '目前不会发送原始照片文件。撤回同意后，今后的 AI 请求会立即被阻止，而你的本地记录仍可继续使用。';

  @override
  String get consentSettingsSaveFailed => '无法保存此设置。请重试。';

  @override
  String get consentRevoke => '撤回同意';

  @override
  String get consentAccept => '同意共享 AI 数据';

  @override
  String get diaryEditorValidationError => '请检查心情、天气、一句话摘要和日记内容。';

  @override
  String get diaryEditorSaveFailed => '无法保存日记。请重试。';

  @override
  String get diaryEditorTitle => '编辑今天的日记';

  @override
  String get diaryEditorSubtitle => '你可以修改 AI 草稿中的天气、心情、一句话摘要、正文和照片顺序。';

  @override
  String get diaryEditorMoodLabel => '今天的心情';

  @override
  String get diaryEditorSummaryLabel => '一句话说今天';

  @override
  String get diaryEditorWeatherTitle => '天气';

  @override
  String get diaryEditorWeatherSubtitle => '无需位置权限，手动输入今天的天气。';

  @override
  String get diaryEditorWeatherConditionLabel => '天气状况';

  @override
  String get diaryEditorWeatherConditionHint => '晴、多云、雨';

  @override
  String get diaryEditorTemperatureLabel => '温度（°C）';

  @override
  String get diaryEditorOptionalHint => '选填';

  @override
  String get diaryEditorBackgroundLabel => '背景';

  @override
  String get diaryEditorLightBackground => '浅色背景';

  @override
  String get diaryEditorDarkBackground => '深色背景';

  @override
  String get diaryEditorContentTitle => '文字和照片';

  @override
  String get diaryEditorAddParagraph => '添加段落';

  @override
  String get diaryEditorSaveChanges => '保存更改';

  @override
  String get diaryEditorMoveUpTooltip => '上移';

  @override
  String get diaryEditorMoveDownTooltip => '下移';

  @override
  String get diaryEditorRemoveBlockTooltip => '移除此内容块';

  @override
  String get diaryEditorParagraphLabel => '段落';

  @override
  String get diaryPreviewFinalizedHelp => '分享只会打开此设备的分享界面，并不表示日记已经发布。';

  @override
  String get diaryPreviewDraftHelp => '这是 AI 生成的草稿。请先检查并编辑，再将其设为正式版。';

  @override
  String get diaryPreviewTitle => '今天的记录';

  @override
  String get diaryPreviewCreateSubtitle => '根据对话创建日记草稿';

  @override
  String get diaryPreviewStoredSubtitle => '已保存在此设备上 · 保留编辑历史';

  @override
  String get diaryPreviewEmptyTitle => '今天还没有日记';

  @override
  String get diaryPreviewEmptyCanGenerate => '把今天的对话整理成包含文字和照片的日记草稿。';

  @override
  String get diaryPreviewEmptyNeedsChat => '先说说你今天发生的事吧。';

  @override
  String get diaryPreviewGenerating => '正在创建草稿';

  @override
  String get diaryPreviewGenerate => '创建今天的日记';

  @override
  String diaryPreviewPageSemantics(int currentPage, int pageCount) {
    return '日记第 $currentPage 页，共 $pageCount 页';
  }

  @override
  String diaryPreviewPageIndicator(int currentPage, int pageCount) {
    return '$currentPage / $pageCount';
  }

  @override
  String get diaryPreviewPreviousPageTooltip => '上一页日记';

  @override
  String get diaryPreviewNextPageTooltip => '下一页日记';

  @override
  String get diaryPreviewOneLineLabel => '一句话说今天';

  @override
  String get diaryPreviewBrandSemantics => 'Namu 日记';

  @override
  String get diaryPreviewBrandHeading => 'NAMU 日记';

  @override
  String get diaryWeatherNone => '无天气信息';

  @override
  String get diaryWeatherManualSource => '手动输入';

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
  String get diaryEditAction => '编辑';

  @override
  String get diaryShareAction => '分享';

  @override
  String get diaryFinalizeAction => '设为正式版';

  @override
  String get memoryApproveFailed => '无法批准这条记忆。请重试。';

  @override
  String get memoryEditFailed => '无法编辑这条记忆。请重试。';

  @override
  String get memoryDeleteFailed => '无法删除这条记忆。请重试。';

  @override
  String get memoryActivateFailed => '无法重新使用这条记忆。请重试。';

  @override
  String get memoryDeactivateFailed => '无法停止使用这条记忆。请重试。';

  @override
  String get memoryTitle => 'AI 记忆';

  @override
  String get memorySubtitle => '查看并管理未来对话中使用的信息';

  @override
  String get memoryReloadTooltip => '刷新记忆列表';

  @override
  String get memoryLoadingSemantics => '正在加载记忆列表';

  @override
  String get memoryEmptySemantics => 'AI 记忆为空';

  @override
  String get memoryEmptyTitle => '还没有保存的记忆';

  @override
  String get memoryEmptyBody => '从每日回顾中批准记忆建议后，就可以在这里管理。';

  @override
  String get memoryLoadErrorSemantics => '记忆加载错误';

  @override
  String get memoryLoadErrorTitle => '无法加载你的记忆';

  @override
  String get memoryStoredDataSafeBody => '已保存的数据没有改变。请稍后重试。';

  @override
  String get memoryRefreshError => '无法刷新。你仍可查看已加载的记忆。';

  @override
  String memoryCardSemantics(String fact, String status, String category) {
    return '记忆，$fact，状态 $status，类别 $category';
  }

  @override
  String get memorySensitiveApprovalNotice => '敏感记忆 · 需要批准';

  @override
  String get memoryChangingSemantics => '正在更新记忆';

  @override
  String get memoryDeactivateAction => '停止使用';

  @override
  String get memoryActivateAction => '重新使用';

  @override
  String get memoryEditAction => '编辑文字';

  @override
  String get memoryApproveSensitiveTitle => '使用这条敏感记忆？';

  @override
  String get memoryApproveRegularTitle => '使用这条记忆？';

  @override
  String get memoryApproveSensitiveBody => '批准后，它可能会用于今后的 AI 对话。请自行检查内容并作出决定。';

  @override
  String get memoryApproveRegularBody => '只有已批准的记忆才能作为今后 AI 对话的上下文。';

  @override
  String get memoryEditValidationError => '请输入希望 AI 记住的内容。';

  @override
  String get memoryEditDialogTitle => '编辑记忆文字';

  @override
  String get memoryEditFieldLabel => '希望 AI 记住的信息';

  @override
  String get memoryDeleteDialogTitle => '删除这条记忆？';

  @override
  String get memoryDeleteDialogBody => '它将不再用于 AI 对话。此操作无法撤销。';

  @override
  String memoryStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'candidate': '待审核',
      'active': '使用中',
      'inactive': '未使用',
      'other': '未知',
    });
    return '$_temp0';
  }

  @override
  String memoryCategoryLabel(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'preference': '偏好',
      'routine': '日常习惯',
      'relationship': '关系',
      'place': '地点',
      'milestone': '重要事件',
      'other': '其他',
    });
    return '$_temp0';
  }

  @override
  String get onboardingSemantics => '入门说明';

  @override
  String get onboardingTitle => '开始之前';

  @override
  String get onboardingLocalStorageTitle => '你的记录只保存在此设备上';

  @override
  String get onboardingLocalStorageBody =>
      '聊天、日记和照片会保存在应用的专用存储空间中。我们不提供云同步、云备份或跨设备恢复。删除应用或丢失设备后，记录将无法恢复。';

  @override
  String get onboardingAiDisclosureTitle => '与 AI 聊天';

  @override
  String get onboardingAiDisclosureBody =>
      'AI 伙伴不是人类，而是生成式 AI。它会友好地回应，但也可能出错，请另行核实重要决定。';

  @override
  String get onboardingAiTransferTitle => '是否共享 AI 数据由你决定';

  @override
  String get onboardingAiTransferBody =>
      '如果你同意，为生成 AI 回复和日记草稿，你输入的文字、有限的近期聊天、已批准的记忆、AI 资料和照片附件信息会发送到已配置的 AI Gateway。目前不会发送原始照片文件。';

  @override
  String get onboardingDecisionNote =>
      '现在不做决定也可以使用本地记录。之后可随时在“设置”中同意共享 AI 数据或撤回同意。';

  @override
  String get onboardingSaveFailed => '无法保存你的选择。请重试。';

  @override
  String get onboardingAcceptAi => '同意共享 AI 数据并开始';

  @override
  String get onboardingStartLocal => '暂时不使用 AI，直接开始';

  @override
  String get onboardingLoadError => '无法检查你的入门状态。';

  @override
  String get personaDefaultName => 'Moa';

  @override
  String get personaDefaultTone => '温暖且富有好奇心';

  @override
  String get personaAvatarSprout => '嫩芽';

  @override
  String get personaAvatarLeaf => '叶子';

  @override
  String get personaAvatarSunlight => '阳光';

  @override
  String get personaAvatarMoonlight => '月光';

  @override
  String get personaValidationError => '请检查名称和对话风格。';

  @override
  String get personaSaveFailed => '无法保存这些设置。请重试。';

  @override
  String get personaSettingsTitle => 'AI 伙伴设置';

  @override
  String get personaSettingsSubtitle => '选择一位 AI 伙伴的名称和对话风格。你的指令无法覆盖安全规则。';

  @override
  String get personaNameLabel => '名称';

  @override
  String get personaProfileLabel => '资料形象';

  @override
  String get personaToneLabel => '语气和个性';

  @override
  String get personaToneHint => '例如：温暖且富有好奇心';

  @override
  String get personaReactionLengthLabel => '回复长度';

  @override
  String get personaReactionConcise => '简短';

  @override
  String get personaReactionBalanced => '适中';

  @override
  String get personaReactionExpressive => '丰富';

  @override
  String get personaInstructionsLabel => '其他对话偏好（选填）';

  @override
  String get personaInstructionsHint => '例如：每次只问一个问题。';

  @override
  String get personaAiConsentAction => 'AI 数据共享设置';

  @override
  String get settingsExportDialogTitle => '将你的记录导出为 JSON？';

  @override
  String get exportDialogBody =>
      '导出内容包括聊天、日记、记忆、AI 伙伴设置以及你的 AI 数据共享同意状态。不包括原始照片和可分享的帖子图片，并且无法用此文件恢复应用。分享到其他应用或文件中的副本无法由 Namu 撤回或删除。';

  @override
  String get settingsExportOpened => '已打开分享和保存界面。';

  @override
  String get settingsExportCancelled => '已取消导出。';

  @override
  String get settingsExportUnavailable => '此设备无法打开分享和保存界面。';

  @override
  String get settingsExportFailed => '无法导出你的记录。请重试。';

  @override
  String get settingsDeleteAllDialogTitle => '删除所有本地数据？';

  @override
  String get settingsResetPreviewDialogTitle => '重置预览数据？';

  @override
  String get settingsDeleteAllDialogBody =>
      '这会从此设备删除聊天、日记、照片、AI 伙伴设置、AI 记忆、应用内导出文件以及 AI 数据共享同意记录。此操作无法撤销。已导出到其他应用或文件中的副本无法由 Namu 删除。';

  @override
  String get settingsResetPreviewDialogBody =>
      '这只会重置当前浏览器预览中的临时数据，无法验证设备存储中的数据是否已删除。';

  @override
  String get settingsDeleteAllAction => '全部删除';

  @override
  String get settingsAiSectionTitle => 'AI';

  @override
  String get settingsPersonaTitle => 'AI 伙伴设置';

  @override
  String get settingsPersonaSubtitle => '名称、语气、资料形象和回复长度';

  @override
  String get settingsConsentTitle => 'AI 数据共享设置';

  @override
  String get settingsConsentSubtitle => '查看或撤回你的同意';

  @override
  String get settingsMyDataSectionTitle => '我的数据';

  @override
  String get settingsTransientStorageTitle => '临时浏览器存储';

  @override
  String get settingsDeviceStorageTitle => '仅保存在此设备上';

  @override
  String get settingsTransientStorageBody => '此浏览器预览使用临时数据，重新启动后数据可能消失。';

  @override
  String get settingsDeviceStorageBody =>
      '聊天、日记和照片保存在此设备上。删除应用或丢失设备后，这些数据无法恢复。';

  @override
  String get settingsExportJsonTitle => '将记录导出为 JSON';

  @override
  String get settingsExportWebUnavailable => '浏览器预览不支持导出。';

  @override
  String get settingsExportJsonSubtitle => '将聊天、日记、记忆和 AI 设置导出为 JSON。不包括照片文件。';

  @override
  String get settingsResetPreviewTitle => '重置预览数据';

  @override
  String get settingsDeleteAllTitle => '删除所有本地数据';

  @override
  String get settingsResetPreviewSubtitle => '仅清除当前临时状态，不会删除设备数据。';

  @override
  String get settingsDeleteAllSubtitle => '永久删除应用内数据，包括 AI 数据共享同意记录。';

  @override
  String get settingsResetFailed => '未能完成数据删除。请重试。';

  @override
  String get settingsExportShareText => 'Namu 本地记录 JSON 导出文件';

  @override
  String get shareSheetOpenedNotPosted => '分享界面已打开。是否已发布，请在所选应用中确认。';

  @override
  String get shareRendererTodayTitle => '今天的记录';

  @override
  String get shareRendererPhotoUnavailable => '照片不可用';

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
  String get todayNoDiaryToEdit => '没有可编辑的日记。';

  @override
  String get todayChatRefreshFailed => '无法刷新今天的对话。';

  @override
  String get todayPhotoAttachedReplyFailed => '照片已附加，但未收到 AI 回复。你的记录仍保存在此设备上。';

  @override
  String get todayPhotoMobileAndGatewayNeeded =>
      '请在移动应用中选择照片，同时还需要连接 AI Gateway。';

  @override
  String get todayConsentNeededForDiary => '请同意共享 AI 数据以创建日记草稿。';

  @override
  String get todayFinalizeFailed => '无法将日记保存为正式版。';

  @override
  String get todayMemoryCandidatesFailed => '日记已保存，但 Namu 无法准备记忆建议。';

  @override
  String get todayNoDiaryToShare => '没有可分享的日记。';

  @override
  String get todayShareUnavailable => '当前环境无法打开分享界面。';

  @override
  String get todayShareCancelled => '已取消分享。你的日记仍保存在此设备上。';

  @override
  String get todayShareImageFailed => '无法创建分享图片。请重试。';

  @override
  String get todayDiaryAlreadyVisible => '今天的日记已在右侧打开。';

  @override
  String get todayNavChat => '聊天';

  @override
  String get todayNavDiary => '今日日记';

  @override
  String get todayNavArchive => '归档';

  @override
  String get todayNavMemory => '记忆';

  @override
  String get todayNavSettings => '设置';
}
