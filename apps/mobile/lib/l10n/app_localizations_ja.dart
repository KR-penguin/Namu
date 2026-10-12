// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Namu';

  @override
  String get settingsTitle => '設定';

  @override
  String get commonBack => '戻る';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonRetry => 'もう一度試す';

  @override
  String get commonRetryShort => '再試行';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonApprove => '承認';

  @override
  String get commonExport => 'エクスポート';

  @override
  String get commonAttachedPhoto => '添付写真';

  @override
  String commonDiaryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'finalized': '確定済み',
      'draft': '下書き',
      'other': '不明',
    });
    return '$_temp0';
  }

  @override
  String commonWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': '月曜日',
      'tuesday': '火曜日',
      'wednesday': '水曜日',
      'thursday': '木曜日',
      'friday': '金曜日',
      'saturday': '土曜日',
      'sunday': '日曜日',
      'other': '曜日不明',
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
    return '$year年$month月$day日 · $weekday';
  }

  @override
  String commonMonthDayWithWeekday(int month, int day, String weekday) {
    return '$month月$day日 · $weekday';
  }

  @override
  String get bootstrapResetDeleting => 'この端末のローカルデータを削除しています…';

  @override
  String get bootstrapResetFailedTitle => 'データを削除できませんでした';

  @override
  String get bootstrapResetFailedBody => '記録を再び開かず、安全に停止しました。もう一度削除をお試しください。';

  @override
  String get bootstrapResetRetry => 'もう一度削除する';

  @override
  String get bootstrapTimeZoneFailedTitle => 'タイムゾーンを取得できませんでした';

  @override
  String get bootstrapTimeZoneFailedBody => '日ごとの記録を正しく分けるには、タイムゾーンの確認が必要です。';

  @override
  String get gatewayPreservedChat => 'メッセージはこの端末に残っています。';

  @override
  String get gatewayPreservedDiary => '今日の記録はこの端末に残っています。';

  @override
  String gatewayUnknownChat(String preserved) {
    return 'AIの返信を取得できませんでした。$preserved';
  }

  @override
  String gatewayUnknownDiary(String preserved) {
    return '日記の下書きを作成できませんでした。$preserved';
  }

  @override
  String gatewayUnconfigured(String preserved) {
    return 'AI接続の設定が必要です。$preserved';
  }

  @override
  String gatewayUnauthorized(String preserved) {
    return 'AI接続の認証を確認できませんでした。しばらくしてからもう一度お試しください。$preserved';
  }

  @override
  String gatewayInvalidAttestation(String preserved) {
    return 'このアプリを使用している端末を認証できませんでした。アプリを開き直して、もう一度お試しください。$preserved';
  }

  @override
  String gatewayRateLimited(String retryGuidance, String preserved) {
    return '現在、AIへのリクエストが集中しています。$retryGuidance $preserved';
  }

  @override
  String get gatewayRequestTooLargeChat =>
      'メッセージが長すぎるため、AIに送信できません。内容を分けて新しいメッセージとして送信してください。元の内容はこの端末に残っています。';

  @override
  String gatewayRequestTooLargeDiary(String preserved) {
    return '今日の記録が長すぎるため、AIに送信できません。$preserved';
  }

  @override
  String gatewayResponseTooLarge(String preserved) {
    return 'AIの返信が長すぎるため表示しませんでした。もう一度お試しください。$preserved';
  }

  @override
  String get gatewayIdempotencyConflictChat =>
      'このリクエストを安全に再処理できません。新しいメッセージとしてお試しください。元の内容はこの端末に残っています。';

  @override
  String gatewayIdempotencyConflictDiary(String preserved) {
    return 'このリクエストを安全に再処理できません。アプリを開き直して、もう一度お試しください。$preserved';
  }

  @override
  String gatewayRejected(String preserved) {
    return 'AIはこのリクエストを処理できませんでした。内容を確認して、もう一度お試しください。$preserved';
  }

  @override
  String gatewaySafetyBlockedChat(String preserved) {
    return 'AIの安全基準により、このリクエストには返信できません。$preserved';
  }

  @override
  String gatewaySafetyBlockedDiary(String preserved) {
    return 'AIの安全基準により、このリクエストから日記の下書きを作成できません。$preserved';
  }

  @override
  String gatewayTimeout(String preserved) {
    return 'AIの返信に時間がかかっているため、待機を終了しました。もう一度お試しください。$preserved';
  }

  @override
  String gatewayTruncated(String preserved) {
    return 'AIの返信が完了していないため表示しませんでした。もう一度お試しください。$preserved';
  }

  @override
  String gatewayInvalidResponse(String preserved) {
    return 'AIの返信形式を確認できないため表示しませんでした。もう一度お試しください。$preserved';
  }

  @override
  String gatewayServerUnavailable(String preserved) {
    return 'AIサービスが一時的に不安定です。しばらくしてからもう一度お試しください。$preserved';
  }

  @override
  String gatewayNetworkUnavailable(String preserved) {
    return 'ネットワークに接続できませんでした。接続を確認して、もう一度お試しください。$preserved';
  }

  @override
  String get gatewayRetrySoon => 'しばらくしてからもう一度お試しください。';

  @override
  String gatewayRetryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '約$count秒後にもう一度お試しください。',
      one: '約1秒後にもう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '約$count分後にもう一度お試しください。',
      one: '約1分後にもう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '約$count時間後にもう一度お試しください。',
      one: '約1時間後にもう一度お試しください。',
    );
    return '$_temp0';
  }

  @override
  String get archiveSearchSemantics => '日記アーカイブを検索';

  @override
  String get archiveSearchLabel => 'アーカイブを検索';

  @override
  String get archiveSearchHint => '2026-10-04、気分、ひとこと';

  @override
  String get archiveClearSearchTooltip => '検索内容を消去';

  @override
  String get archiveTitle => '日記アーカイブ';

  @override
  String get archiveSubtitle => 'この端末に保存した日々を振り返れます';

  @override
  String get archiveReloadTooltip => '日記一覧を更新';

  @override
  String get archiveLoadingSemantics => '日記アーカイブを読み込んでいます';

  @override
  String get archiveNoResultsSemantics => '日記の検索結果はありません';

  @override
  String get archiveNoResultsTitle => '検索結果がありません';

  @override
  String get archiveNoResultsBody =>
      '2026-10-04のような日付、または気分やひとことに含まれる別の言葉で検索してみてください。';

  @override
  String get archiveEmptySemantics => '日記アーカイブは空です';

  @override
  String get archiveEmptyTitle => '保存された日記はまだありません';

  @override
  String get archiveEmptyBody => '今日の会話から日記を作ると、ここに少しずつたまっていきます。';

  @override
  String get archiveLoadErrorSemantics => '日記の読み込みエラー';

  @override
  String get archiveLoadErrorTitle => '日記を読み込めませんでした';

  @override
  String get archiveStoredDataSafeBody =>
      '端末に保存された内容はそのままです。しばらくしてからもう一度お試しください。';

  @override
  String get archiveRefreshError => '更新できませんでした。すでに読み込んだ日記は引き続き閲覧できます。';

  @override
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  ) {
    return '$date、気分 $mood、$status、$summary';
  }

  @override
  String archiveMoodLabel(String mood) {
    return '気分 · $mood';
  }

  @override
  String get archiveOpenDiarySemantics => '日記を開く';

  @override
  String get chatLoadError => '保存された会話を読み込めませんでした。';

  @override
  String get chatPhotoPickerUnavailable => 'この環境では写真を選択できません。';

  @override
  String get chatPrompt => '今日あったことを聞かせてください';

  @override
  String get chatLocalFirstBody => 'メッセージはAIに送信する前に、まずこの端末へ保存されます。';

  @override
  String chatAiFriendProfileSemantics(String name) {
    return 'AIフレンド $name のプロフィール';
  }

  @override
  String get chatGatewaySetupNeeded => 'AI接続の設定が必要です';

  @override
  String get chatAiReady => 'AIから返信を受け取る準備ができています';

  @override
  String get chatConsentNeeded => 'AIデータ送信への同意が必要です';

  @override
  String get chatPersonaSettingsTooltip => 'AIフレンドの設定';

  @override
  String get chatConnectionBadgeNeedsSetup => 'AI接続が必要';

  @override
  String get chatConnectionBadgeReady => 'AI準備完了';

  @override
  String get chatConnectionBadgeNeedsConsent => '同意が必要';

  @override
  String get chatTodayDivider => '今日';

  @override
  String chatPersonaProfileSemantics(String name) {
    return '$nameのプロフィール';
  }

  @override
  String get chatReplyFailed => 'AIの返信を取得できませんでした';

  @override
  String get chatTypingSemantics => 'AIが返信を作成しています';

  @override
  String get chatOpenDiary => '今日の日記を見る';

  @override
  String get chatAttachPhotoTooltip => '写真を添付';

  @override
  String get chatSendMessageTooltip => 'メッセージを送信';

  @override
  String get consentDisclosureSemantics => 'AIデータ送信に関する案内';

  @override
  String get consentTitle => 'AIに送信する情報';

  @override
  String get consentTransferBody =>
      'AIの返信や日記の下書きを作成する際、入力した文章、直近の限られたチャット、承認した記憶、AIプロフィール、写真の添付情報を、設定済みのAI Gatewayに送信します。';

  @override
  String get consentPhotoBoundaryBody =>
      '現在、写真の元ファイルは送信されません。写真の識別子と会話内での位置だけが送信されます。今後、写真の内容を送信して分析する機能を追加する場合は、別途同意を求めます。';

  @override
  String get consentLocalUseBody =>
      'チャット、日記、写真の元ファイルはこの端末に保存されます。同意しなくてもローカルの記録を利用でき、設定からいつでも同意または同意の撤回ができます。';

  @override
  String get consentSaveFailed => '選択内容を保存できませんでした。もう一度お試しください。';

  @override
  String get consentAcceptAndStart => 'AIデータ送信に同意して始める';

  @override
  String get consentDeclineAndUseLocal => '同意せずローカルの記録だけを使う';

  @override
  String get consentLoadError =>
      'AIデータ送信の設定を確認できませんでした。\n確認できるまでAIへのリクエストは送信されません。';

  @override
  String get consentSettingsTitle => 'AIデータ送信';

  @override
  String consentSettingsStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'allowed': 'AIデータ送信：同意済み',
      'declined': 'AIデータ送信：同意していません',
      'other': 'AIデータ送信：未選択',
    });
    return '$_temp0';
  }

  @override
  String get consentSettingsRequestBody =>
      'AIの返信や日記の下書きをリクエストする際、入力した文章、直近の限られたチャット、承認した記憶、AIプロフィール、写真の添付情報を、設定済みのAI Gatewayに送信します。';

  @override
  String get consentSettingsPhotoBody =>
      '現在、写真の元ファイルは送信されません。同意を撤回すると、それ以降のAIへのリクエストは直ちにブロックされ、ローカルの記録は引き続き利用できます。';

  @override
  String get consentSettingsSaveFailed => '設定を保存できませんでした。もう一度お試しください。';

  @override
  String get consentRevoke => '同意を撤回';

  @override
  String get consentAccept => 'AIデータ送信に同意';

  @override
  String get diaryEditorValidationError => '気分、天気、ひとこと、本文を確認してください。';

  @override
  String get diaryEditorSaveFailed => '日記を保存できませんでした。もう一度お試しください。';

  @override
  String get diaryEditorTitle => '今日の日記を編集';

  @override
  String get diaryEditorSubtitle => 'AIが作成した下書きの天気、気分、ひとこと、文章、写真の順序を自由に変更できます。';

  @override
  String get diaryEditorMoodLabel => '今日の気分';

  @override
  String get diaryEditorSummaryLabel => '今日のひとこと';

  @override
  String get diaryEditorWeatherTitle => '天気の記録';

  @override
  String get diaryEditorWeatherSubtitle => '位置情報へのアクセスを許可せず、今日の天気を自分で入力できます。';

  @override
  String get diaryEditorWeatherConditionLabel => '天気';

  @override
  String get diaryEditorWeatherConditionHint => '晴れ、曇り、雨';

  @override
  String get diaryEditorTemperatureLabel => '気温（°C）';

  @override
  String get diaryEditorOptionalHint => '任意';

  @override
  String get diaryEditorBackgroundLabel => '背景';

  @override
  String get diaryEditorLightBackground => '明るい背景';

  @override
  String get diaryEditorDarkBackground => '暗い背景';

  @override
  String get diaryEditorContentTitle => '本文と写真';

  @override
  String get diaryEditorAddParagraph => '段落を追加';

  @override
  String get diaryEditorSaveChanges => '変更を保存';

  @override
  String get diaryEditorMoveUpTooltip => '上へ移動';

  @override
  String get diaryEditorMoveDownTooltip => '下へ移動';

  @override
  String get diaryEditorRemoveBlockTooltip => 'ブロックを除外';

  @override
  String get diaryEditorParagraphLabel => '段落';

  @override
  String get diaryPreviewFinalizedHelp =>
      '共有すると端末の共有画面が開きます。日記の投稿完了を意味するものではありません。';

  @override
  String get diaryPreviewDraftHelp => 'AIが作成した下書きです。内容を確認・編集してから確定してください。';

  @override
  String get diaryPreviewTitle => '今日の記録';

  @override
  String get diaryPreviewCreateSubtitle => '会話をもとに日記の下書きを作成します';

  @override
  String get diaryPreviewStoredSubtitle => 'この端末に保存した日記 · 編集履歴も保持されています';

  @override
  String get diaryPreviewEmptyTitle => '今日の日記はまだありません';

  @override
  String get diaryPreviewEmptyCanGenerate => '今日の会話を、文章と写真を組み合わせた日記の下書きにまとめます。';

  @override
  String get diaryPreviewEmptyNeedsChat => 'まずは今日の出来事を聞かせてください。';

  @override
  String get diaryPreviewGenerating => '下書きを作成中';

  @override
  String get diaryPreviewGenerate => '今日の日記を作成';

  @override
  String diaryPreviewPageSemantics(int currentPage, int pageCount) {
    return '全$pageCountページ中$currentPageページ目';
  }

  @override
  String diaryPreviewPageIndicator(int currentPage, int pageCount) {
    return '$currentPage / $pageCount';
  }

  @override
  String get diaryPreviewPreviousPageTooltip => '前の日記ページ';

  @override
  String get diaryPreviewNextPageTooltip => '次の日記ページ';

  @override
  String get diaryPreviewOneLineLabel => '今日のひとこと';

  @override
  String get diaryPreviewBrandSemantics => 'Namuの日記';

  @override
  String get diaryPreviewBrandHeading => 'NAMU DIARY';

  @override
  String get diaryWeatherNone => '天気なし';

  @override
  String get diaryWeatherManualSource => '手動入力';

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
  String get diaryEditAction => '編集';

  @override
  String get diaryShareAction => '共有';

  @override
  String get diaryFinalizeAction => '日記を確定';

  @override
  String get memoryApproveFailed => '記憶を承認できませんでした。もう一度お試しください。';

  @override
  String get memoryEditFailed => '記憶を編集できませんでした。もう一度お試しください。';

  @override
  String get memoryDeleteFailed => '記憶を削除できませんでした。もう一度お試しください。';

  @override
  String get memoryActivateFailed => 'この記憶を再び使用できませんでした。もう一度お試しください。';

  @override
  String get memoryDeactivateFailed => 'この記憶の使用を停止できませんでした。もう一度お試しください。';

  @override
  String get memoryTitle => 'AIの記憶';

  @override
  String get memorySubtitle => '次の会話で使う情報を自分で確認・管理できます';

  @override
  String get memoryReloadTooltip => '記憶一覧を更新';

  @override
  String get memoryLoadingSemantics => '記憶一覧を読み込んでいます';

  @override
  String get memoryEmptySemantics => 'AIの記憶は空です';

  @override
  String get memoryEmptyTitle => '保存された記憶はまだありません';

  @override
  String get memoryEmptyBody => '一日の振り返りから提案された記憶を自分で承認すると、ここで管理できます。';

  @override
  String get memoryLoadErrorSemantics => '記憶の読み込みエラー';

  @override
  String get memoryLoadErrorTitle => '記憶を読み込めませんでした';

  @override
  String get memoryStoredDataSafeBody =>
      '端末に保存された内容はそのままです。しばらくしてからもう一度お試しください。';

  @override
  String get memoryRefreshError => '更新できませんでした。すでに読み込んだ記憶は引き続き閲覧できます。';

  @override
  String memoryCardSemantics(String fact, String status, String category) {
    return '記憶、$fact、状態 $status、分類 $category';
  }

  @override
  String get memorySensitiveApprovalNotice => '機微な記憶 · ご自身による承認が必要です';

  @override
  String get memoryChangingSemantics => '記憶を更新しています';

  @override
  String get memoryDeactivateAction => '使用を停止';

  @override
  String get memoryActivateAction => '再び使用';

  @override
  String get memoryEditAction => '文言を編集';

  @override
  String get memoryApproveSensitiveTitle => 'この機微な記憶を使用しますか？';

  @override
  String get memoryApproveRegularTitle => 'この記憶を使用しますか？';

  @override
  String get memoryApproveSensitiveBody =>
      '承認すると、今後のAIとの会話で使用されることがあります。内容を確認し、ご自身で判断してください。';

  @override
  String get memoryApproveRegularBody => '承認した記憶だけが、今後のAIとの会話の文脈として使用されます。';

  @override
  String get memoryEditValidationError => 'AIに記憶させる内容を入力してください。';

  @override
  String get memoryEditDialogTitle => '記憶の文言を編集';

  @override
  String get memoryEditFieldLabel => 'AIに記憶させる内容';

  @override
  String get memoryDeleteDialogTitle => 'この記憶を削除しますか？';

  @override
  String get memoryDeleteDialogBody => '削除すると、今後のAIとの会話では使用されません。この操作は元に戻せません。';

  @override
  String memoryStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'candidate': '要確認',
      'active': '使用中',
      'inactive': '使用していません',
      'other': '不明',
    });
    return '$_temp0';
  }

  @override
  String memoryCategoryLabel(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'preference': '好み',
      'routine': '習慣',
      'relationship': '人間関係',
      'place': '場所',
      'milestone': '大切な出来事',
      'other': 'その他',
    });
    return '$_temp0';
  }

  @override
  String get onboardingSemantics => 'はじめにお読みください';

  @override
  String get onboardingTitle => '始める前にご確認ください';

  @override
  String get onboardingLocalStorageTitle => '記録はこの端末に保存されます';

  @override
  String get onboardingLocalStorageBody =>
      'チャット、日記、写真はアプリ専用の保存領域に保存されます。クラウド同期、バックアップ、別の端末への復元には対応していません。アプリを削除したり端末を紛失したりすると、記録を復元できません。';

  @override
  String get onboardingAiDisclosureTitle => 'AIと会話します';

  @override
  String get onboardingAiDisclosureBody =>
      'AIフレンドは人間ではなく生成AIです。親しみやすく応答しますが、誤った内容を伝えることがあるため、重要な判断は別途確認してください。';

  @override
  String get onboardingAiTransferTitle => 'AIデータ送信への同意は任意です';

  @override
  String get onboardingAiTransferBody =>
      '同意すると、AIの返信と日記の下書きを作成するため、入力した文章、直近の限られたチャット、承認した記憶、AIプロフィール、写真の添付情報が、設定済みのAI Gatewayに送信されます。現在、写真の元ファイルは送信されません。';

  @override
  String get onboardingDecisionNote =>
      '今すぐ決めなくても、ローカルの記録を利用できます。後から設定でAIデータ送信に同意したり、同意を撤回したりできます。';

  @override
  String get onboardingSaveFailed => '選択内容を保存できませんでした。もう一度お試しください。';

  @override
  String get onboardingAcceptAi => 'AIデータ送信に同意して始める';

  @override
  String get onboardingStartLocal => '今はAIを使わずに始める';

  @override
  String get onboardingLoadError => '開始時の設定状況を確認できませんでした。';

  @override
  String get personaDefaultName => 'モア';

  @override
  String get personaDefaultTone => '温かく好奇心を持って';

  @override
  String get personaAvatarSprout => '新芽';

  @override
  String get personaAvatarLeaf => '葉っぱ';

  @override
  String get personaAvatarSunlight => '陽だまり';

  @override
  String get personaAvatarMoonlight => '月明かり';

  @override
  String get personaValidationError => '名前と会話スタイルを確認してください。';

  @override
  String get personaSaveFailed => '設定を保存できませんでした。もう一度お試しください。';

  @override
  String get personaSettingsTitle => 'AIフレンドの設定';

  @override
  String get personaSettingsSubtitle =>
      '一人のAIフレンドの名前と会話スタイルを設定できます。ユーザーの指示が安全ポリシーより優先されることはありません。';

  @override
  String get personaNameLabel => '名前';

  @override
  String get personaProfileLabel => 'プロフィール';

  @override
  String get personaToneLabel => '口調と性格';

  @override
  String get personaToneHint => '例：温かく好奇心を持って';

  @override
  String get personaReactionLengthLabel => '返信の長さ';

  @override
  String get personaReactionConcise => '簡潔';

  @override
  String get personaReactionBalanced => 'バランスよく';

  @override
  String get personaReactionExpressive => '詳しく';

  @override
  String get personaInstructionsLabel => 'その他の会話の希望（任意）';

  @override
  String get personaInstructionsHint => '例：質問は一度に一つだけにして。';

  @override
  String get personaAiConsentAction => 'AIデータ送信の設定';

  @override
  String get settingsExportDialogTitle => '記録をJSONでエクスポートしますか？';

  @override
  String get exportDialogBody =>
      'チャット、日記、記憶、AIフレンドの設定、AIデータ送信への同意状況が含まれます。元の写真と共有用の投稿画像は含まれず、このファイルからアプリを復元することはできません。外部アプリやファイルに共有したコピーをNamuから回収または削除することはできません。';

  @override
  String get settingsExportOpened => '共有・保存画面を開きました。';

  @override
  String get settingsExportCancelled => 'エクスポートをキャンセルしました。';

  @override
  String get settingsExportUnavailable => 'この端末では共有・保存画面を開けません。';

  @override
  String get settingsExportFailed => '記録をエクスポートできませんでした。もう一度お試しください。';

  @override
  String get settingsDeleteAllDialogTitle => 'すべてのローカルデータを削除しますか？';

  @override
  String get settingsResetPreviewDialogTitle => 'プレビューデータをリセットしますか？';

  @override
  String get settingsDeleteAllDialogBody =>
      'この端末から、チャット、日記、写真、AIフレンドの設定、AIの記憶、アプリ内のエクスポートファイル、AIデータ送信への同意をすべて削除します。削除後は復元できません。外部アプリやファイルにエクスポートしたコピーをNamuから削除することはできません。';

  @override
  String get settingsResetPreviewDialogBody =>
      'このブラウザプレビューの一時データだけをリセットします。端末の保存領域からの削除を検証する操作ではありません。';

  @override
  String get settingsDeleteAllAction => 'すべて削除';

  @override
  String get settingsAiSectionTitle => 'AI';

  @override
  String get settingsPersonaTitle => 'AIフレンドの設定';

  @override
  String get settingsPersonaSubtitle => '名前、口調、プロフィール、返信の長さ';

  @override
  String get settingsConsentTitle => 'AIデータ送信の設定';

  @override
  String get settingsConsentSubtitle => '同意状況の確認または同意の撤回';

  @override
  String get settingsMyDataSectionTitle => '自分のデータ';

  @override
  String get settingsTransientStorageTitle => 'ブラウザの一時保存';

  @override
  String get settingsDeviceStorageTitle => 'この端末だけに保存';

  @override
  String get settingsTransientStorageBody =>
      'ブラウザプレビューの一時データです。再起動すると消えることがあります。';

  @override
  String get settingsDeviceStorageBody =>
      'チャット、日記、写真は端末内に保存されます。アプリの削除後や端末の紛失後は復元できません。';

  @override
  String get settingsExportJsonTitle => '記録をJSONでエクスポート';

  @override
  String get settingsExportWebUnavailable => 'ブラウザプレビューではエクスポートに対応していません。';

  @override
  String get settingsExportJsonSubtitle =>
      'チャット、日記、記憶、AI設定をJSONでエクスポートします。写真ファイルは含まれません。';

  @override
  String get settingsResetPreviewTitle => 'プレビューデータをリセット';

  @override
  String get settingsDeleteAllTitle => 'すべてのローカルデータを削除';

  @override
  String get settingsResetPreviewSubtitle => '端末のデータではなく、現在の一時的な状態だけを消去します。';

  @override
  String get settingsDeleteAllSubtitle =>
      'AIデータ送信への同意を含むアプリ内データを、元に戻せない形で削除します。';

  @override
  String get settingsResetFailed => 'データを削除できませんでした。もう一度お試しください。';

  @override
  String get settingsExportShareText => 'Namu ローカル記録のJSONエクスポート';

  @override
  String get shareSheetOpenedNotPosted =>
      '共有画面を開きました。投稿されたかどうかは、選択したアプリで確認してください。';

  @override
  String get shareRendererTodayTitle => '今日の記録';

  @override
  String get shareRendererPhotoUnavailable => '写真を読み込めません';

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
  String get todayNoDiaryToEdit => '編集する日記がありません。';

  @override
  String get todayChatRefreshFailed => '今日の会話を再確認できませんでした。';

  @override
  String get todayPhotoAttachedReplyFailed =>
      '写真は添付されましたが、AIの返信を取得できませんでした。記録はこの端末に残っています。';

  @override
  String get todayPhotoMobileAndGatewayNeeded =>
      '写真の選択はモバイルアプリで利用できます。AI Gatewayへの接続も必要です。';

  @override
  String get todayConsentNeededForDiary => 'AIデータ送信に同意すると、日記の下書きを作成できます。';

  @override
  String get todayFinalizeFailed => '日記を確定して保存できませんでした。';

  @override
  String get todayMemoryCandidatesFailed => '日記は保存されましたが、記憶の候補を準備できませんでした。';

  @override
  String get todayNoDiaryToShare => '共有する日記がありません。';

  @override
  String get todayShareUnavailable => 'この環境では共有画面を開けません。';

  @override
  String get todayShareCancelled => '共有をキャンセルしました。日記はこの端末に残っています。';

  @override
  String get todayShareImageFailed => '共有用画像を作成できませんでした。もう一度お試しください。';

  @override
  String get todayDiaryAlreadyVisible => '今日の日記は右側に開いています。';

  @override
  String get todayNavChat => 'チャット';

  @override
  String get todayNavDiary => '今日の日記';

  @override
  String get todayNavArchive => 'アーカイブ';

  @override
  String get todayNavMemory => '記憶';

  @override
  String get todayNavSettings => '設定';
}
