import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Namu'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// No description provided for @commonRetryShort.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetryShort;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get commonApprove;

  /// No description provided for @commonExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get commonExport;

  /// No description provided for @commonAttachedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Attached photo'**
  String get commonAttachedPhoto;

  /// Human-readable diary status.
  ///
  /// In en, this message translates to:
  /// **'{status, select, finalized {Final} draft {Draft} other {Unknown}}'**
  String commonDiaryStatus(String status);

  /// Full weekday name selected from a stable English token.
  ///
  /// In en, this message translates to:
  /// **'{weekday, select, monday {Monday} tuesday {Tuesday} wednesday {Wednesday} thursday {Thursday} friday {Friday} saturday {Saturday} sunday {Sunday} other {Unknown day}}'**
  String commonWeekday(String weekday);

  /// No description provided for @commonFullDate.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year}'**
  String commonFullDate(int year, int month, int day);

  /// A full local calendar date. Weekday is already localized.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {month}/{day}/{year}'**
  String commonFullDateWithWeekday(
    int year,
    int month,
    int day,
    String weekday,
  );

  /// A short local calendar date. Weekday is already localized.
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {month}/{day}'**
  String commonMonthDayWithWeekday(int month, int day, String weekday);

  /// No description provided for @bootstrapResetDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting local data from this device…'**
  String get bootstrapResetDeleting;

  /// No description provided for @bootstrapResetFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t finish deleting your data'**
  String get bootstrapResetFailedTitle;

  /// No description provided for @bootstrapResetFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Namu stopped safely without reopening your records. Try deleting them again.'**
  String get bootstrapResetFailedBody;

  /// No description provided for @bootstrapResetRetry.
  ///
  /// In en, this message translates to:
  /// **'Try deleting again'**
  String get bootstrapResetRetry;

  /// No description provided for @bootstrapTimeZoneFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your time zone'**
  String get bootstrapTimeZoneFailedTitle;

  /// No description provided for @bootstrapTimeZoneFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Namu needs your time zone to keep each day’s records separate.'**
  String get bootstrapTimeZoneFailedBody;

  /// No description provided for @gatewayPreservedChat.
  ///
  /// In en, this message translates to:
  /// **'Your message is still on this device.'**
  String get gatewayPreservedChat;

  /// No description provided for @gatewayPreservedDiary.
  ///
  /// In en, this message translates to:
  /// **'Today’s record is still on this device.'**
  String get gatewayPreservedDiary;

  /// No description provided for @gatewayUnknownChat.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t get an AI reply. {preserved}'**
  String gatewayUnknownChat(String preserved);

  /// No description provided for @gatewayUnknownDiary.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t create a diary draft. {preserved}'**
  String gatewayUnknownDiary(String preserved);

  /// No description provided for @gatewayUnconfigured.
  ///
  /// In en, this message translates to:
  /// **'AI connection settings are required. {preserved}'**
  String gatewayUnconfigured(String preserved);

  /// No description provided for @gatewayUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t verify the AI connection. Try again in a moment. {preserved}'**
  String gatewayUnauthorized(String preserved);

  /// No description provided for @gatewayInvalidAttestation.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t verify this device for AI access. Reopen the app and try again. {preserved}'**
  String gatewayInvalidAttestation(String preserved);

  /// No description provided for @gatewayRateLimited.
  ///
  /// In en, this message translates to:
  /// **'AI is receiving too many requests right now. {retryGuidance} {preserved}'**
  String gatewayRateLimited(String retryGuidance, String preserved);

  /// No description provided for @gatewayRequestTooLargeChat.
  ///
  /// In en, this message translates to:
  /// **'This message is too long to send to AI. Split it into a new message and try again. The original is still on this device.'**
  String get gatewayRequestTooLargeChat;

  /// No description provided for @gatewayRequestTooLargeDiary.
  ///
  /// In en, this message translates to:
  /// **'Today’s record is too long to send to AI. {preserved}'**
  String gatewayRequestTooLargeDiary(String preserved);

  /// No description provided for @gatewayResponseTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The AI reply was too long, so it wasn’t displayed. Try again. {preserved}'**
  String gatewayResponseTooLarge(String preserved);

  /// No description provided for @gatewayIdempotencyConflictChat.
  ///
  /// In en, this message translates to:
  /// **'This request can’t be safely retried. Start a new message instead. The original is still on this device.'**
  String get gatewayIdempotencyConflictChat;

  /// No description provided for @gatewayIdempotencyConflictDiary.
  ///
  /// In en, this message translates to:
  /// **'This request can’t be safely retried. Reopen the app and try again. {preserved}'**
  String gatewayIdempotencyConflictDiary(String preserved);

  /// No description provided for @gatewayRejected.
  ///
  /// In en, this message translates to:
  /// **'AI couldn’t process this request. Review it and try again. {preserved}'**
  String gatewayRejected(String preserved);

  /// No description provided for @gatewaySafetyBlockedChat.
  ///
  /// In en, this message translates to:
  /// **'AI safety rules prevent a reply to this request. {preserved}'**
  String gatewaySafetyBlockedChat(String preserved);

  /// No description provided for @gatewaySafetyBlockedDiary.
  ///
  /// In en, this message translates to:
  /// **'AI safety rules prevent creating a diary draft from this request. {preserved}'**
  String gatewaySafetyBlockedDiary(String preserved);

  /// No description provided for @gatewayTimeout.
  ///
  /// In en, this message translates to:
  /// **'The AI reply was taking too long, so Namu stopped waiting. Try again. {preserved}'**
  String gatewayTimeout(String preserved);

  /// No description provided for @gatewayTruncated.
  ///
  /// In en, this message translates to:
  /// **'The AI reply was incomplete, so it wasn’t displayed. Try again. {preserved}'**
  String gatewayTruncated(String preserved);

  /// No description provided for @gatewayInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The AI reply format couldn’t be verified, so it wasn’t displayed. Try again. {preserved}'**
  String gatewayInvalidResponse(String preserved);

  /// No description provided for @gatewayServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The AI service is temporarily unstable. Try again in a moment. {preserved}'**
  String gatewayServerUnavailable(String preserved);

  /// No description provided for @gatewayNetworkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t connect to the network. Check your connection and try again. {preserved}'**
  String gatewayNetworkUnavailable(String preserved);

  /// No description provided for @gatewayRetrySoon.
  ///
  /// In en, this message translates to:
  /// **'Try again in a moment.'**
  String get gatewayRetrySoon;

  /// No description provided for @gatewayRetryAfterSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Try again in about 1 second.} other {Try again in about {count} seconds.}}'**
  String gatewayRetryAfterSeconds(int count);

  /// No description provided for @gatewayRetryAfterMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Try again in about 1 minute.} other {Try again in about {count} minutes.}}'**
  String gatewayRetryAfterMinutes(int count);

  /// No description provided for @gatewayRetryAfterHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Try again in about 1 hour.} other {Try again in about {count} hours.}}'**
  String gatewayRetryAfterHours(int count);

  /// No description provided for @archiveSearchSemantics.
  ///
  /// In en, this message translates to:
  /// **'Search the diary archive'**
  String get archiveSearchSemantics;

  /// No description provided for @archiveSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search archive'**
  String get archiveSearchLabel;

  /// No description provided for @archiveSearchHint.
  ///
  /// In en, this message translates to:
  /// **'2026-10-04, mood, or one-line summary'**
  String get archiveSearchHint;

  /// No description provided for @archiveClearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get archiveClearSearchTooltip;

  /// No description provided for @archiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Diary archive'**
  String get archiveTitle;

  /// No description provided for @archiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Revisit days saved on this device'**
  String get archiveSubtitle;

  /// No description provided for @archiveReloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh diary list'**
  String get archiveReloadTooltip;

  /// No description provided for @archiveLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading diary archive'**
  String get archiveLoadingSemantics;

  /// No description provided for @archiveNoResultsSemantics.
  ///
  /// In en, this message translates to:
  /// **'No diary search results'**
  String get archiveNoResultsSemantics;

  /// No description provided for @archiveNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get archiveNoResultsTitle;

  /// No description provided for @archiveNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Search for a date like 2026-10-04, or try different words from the mood or one-line summary.'**
  String get archiveNoResultsBody;

  /// No description provided for @archiveEmptySemantics.
  ///
  /// In en, this message translates to:
  /// **'Empty diary archive'**
  String get archiveEmptySemantics;

  /// No description provided for @archiveEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved diaries yet'**
  String get archiveEmptyTitle;

  /// No description provided for @archiveEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a diary from today’s conversation and it will collect here over time.'**
  String get archiveEmptyBody;

  /// No description provided for @archiveLoadErrorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Diary loading error'**
  String get archiveLoadErrorSemantics;

  /// No description provided for @archiveLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your diaries'**
  String get archiveLoadErrorTitle;

  /// No description provided for @archiveStoredDataSafeBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved data is unchanged. Try again in a moment.'**
  String get archiveStoredDataSafeBody;

  /// No description provided for @archiveRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t refresh. You can still view the diaries already loaded.'**
  String get archiveRefreshError;

  /// Accessibility summary for one diary archive card. Mood and summary are user-authored content.
  ///
  /// In en, this message translates to:
  /// **'{date}, mood {mood}, {status}, {summary}'**
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  );

  /// No description provided for @archiveMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood · {mood}'**
  String archiveMoodLabel(String mood);

  /// No description provided for @archiveOpenDiarySemantics.
  ///
  /// In en, this message translates to:
  /// **'Open diary'**
  String get archiveOpenDiarySemantics;

  /// No description provided for @chatLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your saved conversation.'**
  String get chatLoadError;

  /// No description provided for @chatPhotoPickerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo selection isn’t available in this environment.'**
  String get chatPhotoPickerUnavailable;

  /// No description provided for @chatPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tell me about your day'**
  String get chatPrompt;

  /// No description provided for @chatLocalFirstBody.
  ///
  /// In en, this message translates to:
  /// **'Messages are saved on this device before they are sent to AI.'**
  String get chatLocalFirstBody;

  /// No description provided for @chatAiFriendProfileSemantics.
  ///
  /// In en, this message translates to:
  /// **'Profile for AI companion {name}'**
  String chatAiFriendProfileSemantics(String name);

  /// No description provided for @chatGatewaySetupNeeded.
  ///
  /// In en, this message translates to:
  /// **'AI connection settings are required'**
  String get chatGatewaySetupNeeded;

  /// No description provided for @chatAiReady.
  ///
  /// In en, this message translates to:
  /// **'Ready for AI replies'**
  String get chatAiReady;

  /// No description provided for @chatConsentNeeded.
  ///
  /// In en, this message translates to:
  /// **'AI data-sharing consent is required'**
  String get chatConsentNeeded;

  /// No description provided for @chatPersonaSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI companion settings'**
  String get chatPersonaSettingsTooltip;

  /// No description provided for @chatConnectionBadgeNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'AI setup needed'**
  String get chatConnectionBadgeNeedsSetup;

  /// No description provided for @chatConnectionBadgeReady.
  ///
  /// In en, this message translates to:
  /// **'AI ready'**
  String get chatConnectionBadgeReady;

  /// No description provided for @chatConnectionBadgeNeedsConsent.
  ///
  /// In en, this message translates to:
  /// **'Consent needed'**
  String get chatConnectionBadgeNeedsConsent;

  /// No description provided for @chatTodayDivider.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatTodayDivider;

  /// No description provided for @chatPersonaProfileSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}’s profile'**
  String chatPersonaProfileSemantics(String name);

  /// No description provided for @chatReplyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t get an AI reply'**
  String get chatReplyFailed;

  /// No description provided for @chatTypingSemantics.
  ///
  /// In en, this message translates to:
  /// **'AI is writing a reply'**
  String get chatTypingSemantics;

  /// No description provided for @chatOpenDiary.
  ///
  /// In en, this message translates to:
  /// **'View today’s diary'**
  String get chatOpenDiary;

  /// No description provided for @chatAttachPhotoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Attach photo'**
  String get chatAttachPhotoTooltip;

  /// No description provided for @chatSendMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendMessageTooltip;

  /// No description provided for @consentDisclosureSemantics.
  ///
  /// In en, this message translates to:
  /// **'AI data-sharing notice'**
  String get consentDisclosureSemantics;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Information sent to AI'**
  String get consentTitle;

  /// No description provided for @consentTransferBody.
  ///
  /// In en, this message translates to:
  /// **'To create AI replies and diary drafts, Namu sends the text you enter, limited recent conversations, approved memories, your AI profile, and photo attachment information to the configured AI Gateway.'**
  String get consentTransferBody;

  /// No description provided for @consentPhotoBoundaryBody.
  ///
  /// In en, this message translates to:
  /// **'Original photo files are not currently sent. Only photo identifiers and their positions in the conversation are sent. Separate consent is required before any future photo analysis feature can send photo content.'**
  String get consentPhotoBoundaryBody;

  /// No description provided for @consentLocalUseBody.
  ///
  /// In en, this message translates to:
  /// **'Chats, diaries, and original photos are stored on this device. You can use local records without consenting, and you can consent or withdraw consent at any time in Settings.'**
  String get consentLocalUseBody;

  /// No description provided for @consentSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your choice. Try again.'**
  String get consentSaveFailed;

  /// No description provided for @consentAcceptAndStart.
  ///
  /// In en, this message translates to:
  /// **'Agree to AI data sharing and start'**
  String get consentAcceptAndStart;

  /// No description provided for @consentDeclineAndUseLocal.
  ///
  /// In en, this message translates to:
  /// **'Use local records without agreeing'**
  String get consentDeclineAndUseLocal;

  /// No description provided for @consentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t check your AI data-sharing setting.\nNo AI request will be sent until it is checked.'**
  String get consentLoadError;

  /// No description provided for @consentSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI data sharing'**
  String get consentSettingsTitle;

  /// No description provided for @consentSettingsStatus.
  ///
  /// In en, this message translates to:
  /// **'{status, select, allowed {AI data sharing: Allowed} declined {AI data sharing: Not allowed} other {AI data sharing: Not decided}}'**
  String consentSettingsStatus(String status);

  /// No description provided for @consentSettingsRequestBody.
  ///
  /// In en, this message translates to:
  /// **'When you request an AI reply or diary draft, Namu sends your text, limited recent conversations, approved memories, AI profile, and photo attachment information to the configured AI Gateway.'**
  String get consentSettingsRequestBody;

  /// No description provided for @consentSettingsPhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Original photo files are not currently sent. If you withdraw consent, future AI requests are blocked immediately and your local records remain available.'**
  String get consentSettingsPhotoBody;

  /// No description provided for @consentSettingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save this setting. Try again.'**
  String get consentSettingsSaveFailed;

  /// No description provided for @consentRevoke.
  ///
  /// In en, this message translates to:
  /// **'Withdraw consent'**
  String get consentRevoke;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'Agree to AI data sharing'**
  String get consentAccept;

  /// No description provided for @diaryEditorValidationError.
  ///
  /// In en, this message translates to:
  /// **'Check the mood, weather, one-line summary, and diary content.'**
  String get diaryEditorValidationError;

  /// No description provided for @diaryEditorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the diary. Try again.'**
  String get diaryEditorSaveFailed;

  /// No description provided for @diaryEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit today’s diary'**
  String get diaryEditorTitle;

  /// No description provided for @diaryEditorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change the AI draft’s weather, mood, one-line summary, writing, and photo order.'**
  String get diaryEditorSubtitle;

  /// No description provided for @diaryEditorMoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Today’s mood'**
  String get diaryEditorMoodLabel;

  /// No description provided for @diaryEditorSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Today in one line'**
  String get diaryEditorSummaryLabel;

  /// No description provided for @diaryEditorWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get diaryEditorWeatherTitle;

  /// No description provided for @diaryEditorWeatherSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter today’s weather yourself without location access.'**
  String get diaryEditorWeatherSubtitle;

  /// No description provided for @diaryEditorWeatherConditionLabel.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get diaryEditorWeatherConditionLabel;

  /// No description provided for @diaryEditorWeatherConditionHint.
  ///
  /// In en, this message translates to:
  /// **'Sunny, cloudy, rain'**
  String get diaryEditorWeatherConditionHint;

  /// No description provided for @diaryEditorTemperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get diaryEditorTemperatureLabel;

  /// No description provided for @diaryEditorOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get diaryEditorOptionalHint;

  /// No description provided for @diaryEditorBackgroundLabel.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get diaryEditorBackgroundLabel;

  /// No description provided for @diaryEditorLightBackground.
  ///
  /// In en, this message translates to:
  /// **'Light background'**
  String get diaryEditorLightBackground;

  /// No description provided for @diaryEditorDarkBackground.
  ///
  /// In en, this message translates to:
  /// **'Dark background'**
  String get diaryEditorDarkBackground;

  /// No description provided for @diaryEditorContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Writing and photos'**
  String get diaryEditorContentTitle;

  /// No description provided for @diaryEditorAddParagraph.
  ///
  /// In en, this message translates to:
  /// **'Add paragraph'**
  String get diaryEditorAddParagraph;

  /// No description provided for @diaryEditorSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get diaryEditorSaveChanges;

  /// No description provided for @diaryEditorMoveUpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get diaryEditorMoveUpTooltip;

  /// No description provided for @diaryEditorMoveDownTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get diaryEditorMoveDownTooltip;

  /// No description provided for @diaryEditorRemoveBlockTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove block'**
  String get diaryEditorRemoveBlockTooltip;

  /// No description provided for @diaryEditorParagraphLabel.
  ///
  /// In en, this message translates to:
  /// **'Paragraph'**
  String get diaryEditorParagraphLabel;

  /// No description provided for @diaryPreviewFinalizedHelp.
  ///
  /// In en, this message translates to:
  /// **'Sharing opens this device’s share screen; it does not mean the diary was posted.'**
  String get diaryPreviewFinalizedHelp;

  /// No description provided for @diaryPreviewDraftHelp.
  ///
  /// In en, this message translates to:
  /// **'This is an AI-generated draft. Review and edit it before making it final.'**
  String get diaryPreviewDraftHelp;

  /// No description provided for @diaryPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s record'**
  String get diaryPreviewTitle;

  /// No description provided for @diaryPreviewCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a diary draft from your conversation'**
  String get diaryPreviewCreateSubtitle;

  /// No description provided for @diaryPreviewStoredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device · edit history preserved'**
  String get diaryPreviewStoredSubtitle;

  /// No description provided for @diaryPreviewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No diary for today yet'**
  String get diaryPreviewEmptyTitle;

  /// No description provided for @diaryPreviewEmptyCanGenerate.
  ///
  /// In en, this message translates to:
  /// **'Turn today’s conversation into a diary draft with writing and photos.'**
  String get diaryPreviewEmptyCanGenerate;

  /// No description provided for @diaryPreviewEmptyNeedsChat.
  ///
  /// In en, this message translates to:
  /// **'Start by sharing something about your day.'**
  String get diaryPreviewEmptyNeedsChat;

  /// No description provided for @diaryPreviewGenerating.
  ///
  /// In en, this message translates to:
  /// **'Creating draft'**
  String get diaryPreviewGenerating;

  /// No description provided for @diaryPreviewGenerate.
  ///
  /// In en, this message translates to:
  /// **'Create today’s diary'**
  String get diaryPreviewGenerate;

  /// No description provided for @diaryPreviewPageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Diary page {currentPage} of {pageCount}'**
  String diaryPreviewPageSemantics(int currentPage, int pageCount);

  /// No description provided for @diaryPreviewPageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{currentPage} / {pageCount}'**
  String diaryPreviewPageIndicator(int currentPage, int pageCount);

  /// No description provided for @diaryPreviewPreviousPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous diary page'**
  String get diaryPreviewPreviousPageTooltip;

  /// No description provided for @diaryPreviewNextPageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next diary page'**
  String get diaryPreviewNextPageTooltip;

  /// No description provided for @diaryPreviewOneLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Today in one line'**
  String get diaryPreviewOneLineLabel;

  /// No description provided for @diaryPreviewBrandSemantics.
  ///
  /// In en, this message translates to:
  /// **'Namu diary'**
  String get diaryPreviewBrandSemantics;

  /// No description provided for @diaryPreviewBrandHeading.
  ///
  /// In en, this message translates to:
  /// **'NAMU DIARY'**
  String get diaryPreviewBrandHeading;

  /// No description provided for @diaryWeatherNone.
  ///
  /// In en, this message translates to:
  /// **'No weather'**
  String get diaryWeatherNone;

  /// No description provided for @diaryWeatherManualSource.
  ///
  /// In en, this message translates to:
  /// **'Entered manually'**
  String get diaryWeatherManualSource;

  /// No description provided for @diaryWeatherSourceAndCondition.
  ///
  /// In en, this message translates to:
  /// **'{source} · {condition}'**
  String diaryWeatherSourceAndCondition(String source, String condition);

  /// No description provided for @diaryWeatherSourceConditionTemperature.
  ///
  /// In en, this message translates to:
  /// **'{source} · {condition} {temperature}°'**
  String diaryWeatherSourceConditionTemperature(
    String source,
    String condition,
    String temperature,
  );

  /// No description provided for @diaryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get diaryEditAction;

  /// No description provided for @diaryShareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get diaryShareAction;

  /// No description provided for @diaryFinalizeAction.
  ///
  /// In en, this message translates to:
  /// **'Make final'**
  String get diaryFinalizeAction;

  /// No description provided for @memoryApproveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t approve this memory. Try again.'**
  String get memoryApproveFailed;

  /// No description provided for @memoryEditFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t edit this memory. Try again.'**
  String get memoryEditFailed;

  /// No description provided for @memoryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t delete this memory. Try again.'**
  String get memoryDeleteFailed;

  /// No description provided for @memoryActivateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t start using this memory again. Try again.'**
  String get memoryActivateFailed;

  /// No description provided for @memoryDeactivateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t stop using this memory. Try again.'**
  String get memoryDeactivateFailed;

  /// No description provided for @memoryTitle.
  ///
  /// In en, this message translates to:
  /// **'AI memory'**
  String get memoryTitle;

  /// No description provided for @memorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and manage the facts used in future conversations'**
  String get memorySubtitle;

  /// No description provided for @memoryReloadTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh memory list'**
  String get memoryReloadTooltip;

  /// No description provided for @memoryLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading memory list'**
  String get memoryLoadingSemantics;

  /// No description provided for @memoryEmptySemantics.
  ///
  /// In en, this message translates to:
  /// **'Empty AI memory'**
  String get memoryEmptySemantics;

  /// No description provided for @memoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved memories yet'**
  String get memoryEmptyTitle;

  /// No description provided for @memoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you approve a memory candidate from a daily recap, you can manage it here.'**
  String get memoryEmptyBody;

  /// No description provided for @memoryLoadErrorSemantics.
  ///
  /// In en, this message translates to:
  /// **'Memory loading error'**
  String get memoryLoadErrorSemantics;

  /// No description provided for @memoryLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load your memories'**
  String get memoryLoadErrorTitle;

  /// No description provided for @memoryStoredDataSafeBody.
  ///
  /// In en, this message translates to:
  /// **'Your saved data is unchanged. Try again in a moment.'**
  String get memoryStoredDataSafeBody;

  /// No description provided for @memoryRefreshError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t refresh. You can still view the memories already loaded.'**
  String get memoryRefreshError;

  /// Accessibility summary for one memory card. Fact is user data.
  ///
  /// In en, this message translates to:
  /// **'Memory, {fact}, status {status}, category {category}'**
  String memoryCardSemantics(String fact, String status, String category);

  /// No description provided for @memorySensitiveApprovalNotice.
  ///
  /// In en, this message translates to:
  /// **'Sensitive memory · approval required'**
  String get memorySensitiveApprovalNotice;

  /// No description provided for @memoryChangingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Updating memory'**
  String get memoryChangingSemantics;

  /// No description provided for @memoryDeactivateAction.
  ///
  /// In en, this message translates to:
  /// **'Stop using'**
  String get memoryDeactivateAction;

  /// No description provided for @memoryActivateAction.
  ///
  /// In en, this message translates to:
  /// **'Use again'**
  String get memoryActivateAction;

  /// No description provided for @memoryEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit wording'**
  String get memoryEditAction;

  /// No description provided for @memoryApproveSensitiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Use this sensitive memory?'**
  String get memoryApproveSensitiveTitle;

  /// No description provided for @memoryApproveRegularTitle.
  ///
  /// In en, this message translates to:
  /// **'Use this memory?'**
  String get memoryApproveRegularTitle;

  /// No description provided for @memoryApproveSensitiveBody.
  ///
  /// In en, this message translates to:
  /// **'If approved, it may be used in future AI conversations. Review the content and decide for yourself.'**
  String get memoryApproveSensitiveBody;

  /// No description provided for @memoryApproveRegularBody.
  ///
  /// In en, this message translates to:
  /// **'Only approved memories can be used as context in future AI conversations.'**
  String get memoryApproveRegularBody;

  /// No description provided for @memoryEditValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter something for the AI to remember.'**
  String get memoryEditValidationError;

  /// No description provided for @memoryEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit memory wording'**
  String get memoryEditDialogTitle;

  /// No description provided for @memoryEditFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Fact for AI to remember'**
  String get memoryEditFieldLabel;

  /// No description provided for @memoryDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this memory?'**
  String get memoryDeleteDialogTitle;

  /// No description provided for @memoryDeleteDialogBody.
  ///
  /// In en, this message translates to:
  /// **'It will no longer be used in AI conversations. This can’t be undone.'**
  String get memoryDeleteDialogBody;

  /// No description provided for @memoryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'{status, select, candidate {Needs review} active {In use} inactive {Not in use} other {Unknown}}'**
  String memoryStatusLabel(String status);

  /// No description provided for @memoryCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'{category, select, preference {Preference} routine {Routine} relationship {Relationship} place {Place} milestone {Milestone} other {Other}}'**
  String memoryCategoryLabel(String category);

  /// No description provided for @onboardingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Getting-started information'**
  String get onboardingSemantics;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get onboardingTitle;

  /// No description provided for @onboardingLocalStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your records stay on this device'**
  String get onboardingLocalStorageTitle;

  /// No description provided for @onboardingLocalStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Chats, diaries, and photos stay in the app’s private storage. Cloud sync, backup, and restore on another device are not provided. If you delete the app or lose the device, your records cannot be recovered.'**
  String get onboardingLocalStorageBody;

  /// No description provided for @onboardingAiDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get onboardingAiDisclosureTitle;

  /// No description provided for @onboardingAiDisclosureBody.
  ///
  /// In en, this message translates to:
  /// **'Your AI companion is a generative AI, not a person. It responds warmly but may be wrong, so verify important decisions separately.'**
  String get onboardingAiDisclosureBody;

  /// No description provided for @onboardingAiTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'AI data sharing is optional'**
  String get onboardingAiTransferTitle;

  /// No description provided for @onboardingAiTransferBody.
  ///
  /// In en, this message translates to:
  /// **'If you agree, your text, limited recent chats, approved memories, AI profile, and photo attachment information are sent to the configured AI Gateway to create replies and diary drafts. Original photo files are not currently sent.'**
  String get onboardingAiTransferBody;

  /// No description provided for @onboardingDecisionNote.
  ///
  /// In en, this message translates to:
  /// **'You can use local records without deciding now. You can agree to AI data sharing or withdraw consent later in Settings.'**
  String get onboardingDecisionNote;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save your choice. Try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingAcceptAi.
  ///
  /// In en, this message translates to:
  /// **'Agree to AI data sharing and start'**
  String get onboardingAcceptAi;

  /// No description provided for @onboardingStartLocal.
  ///
  /// In en, this message translates to:
  /// **'Start without AI for now'**
  String get onboardingStartLocal;

  /// No description provided for @onboardingLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t check your getting-started status.'**
  String get onboardingLoadError;

  /// No description provided for @personaDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Moa'**
  String get personaDefaultName;

  /// No description provided for @personaDefaultTone.
  ///
  /// In en, this message translates to:
  /// **'Warm and curious'**
  String get personaDefaultTone;

  /// No description provided for @personaAvatarSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get personaAvatarSprout;

  /// No description provided for @personaAvatarLeaf.
  ///
  /// In en, this message translates to:
  /// **'Leaf'**
  String get personaAvatarLeaf;

  /// No description provided for @personaAvatarSunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get personaAvatarSunlight;

  /// No description provided for @personaAvatarMoonlight.
  ///
  /// In en, this message translates to:
  /// **'Moonlight'**
  String get personaAvatarMoonlight;

  /// No description provided for @personaValidationError.
  ///
  /// In en, this message translates to:
  /// **'Check the name and conversation style.'**
  String get personaValidationError;

  /// No description provided for @personaSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save these settings. Try again.'**
  String get personaSaveFailed;

  /// No description provided for @personaSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI companion settings'**
  String get personaSettingsTitle;

  /// No description provided for @personaSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose one AI companion’s name and conversation style. Your instructions never override safety rules.'**
  String get personaSettingsSubtitle;

  /// No description provided for @personaNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get personaNameLabel;

  /// No description provided for @personaProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get personaProfileLabel;

  /// No description provided for @personaToneLabel.
  ///
  /// In en, this message translates to:
  /// **'Tone and personality'**
  String get personaToneLabel;

  /// No description provided for @personaToneHint.
  ///
  /// In en, this message translates to:
  /// **'For example: warm and curious'**
  String get personaToneHint;

  /// No description provided for @personaReactionLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply length'**
  String get personaReactionLengthLabel;

  /// No description provided for @personaReactionConcise.
  ///
  /// In en, this message translates to:
  /// **'Concise'**
  String get personaReactionConcise;

  /// No description provided for @personaReactionBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get personaReactionBalanced;

  /// No description provided for @personaReactionExpressive.
  ///
  /// In en, this message translates to:
  /// **'Expressive'**
  String get personaReactionExpressive;

  /// No description provided for @personaInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Additional conversation preferences (optional)'**
  String get personaInstructionsLabel;

  /// No description provided for @personaInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Ask only one question at a time.'**
  String get personaInstructionsHint;

  /// No description provided for @personaAiConsentAction.
  ///
  /// In en, this message translates to:
  /// **'AI data-sharing settings'**
  String get personaAiConsentAction;

  /// No description provided for @settingsExportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Export your records as JSON?'**
  String get settingsExportDialogTitle;

  /// No description provided for @exportDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This includes chats, diaries, memories, AI companion settings, and your AI data-sharing consent status. Original photos and shareable post images are not included, and this file cannot restore the app. Copies shared to other apps or files cannot be recalled or deleted by Namu.'**
  String get exportDialogBody;

  /// No description provided for @settingsExportOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened the share and save screen.'**
  String get settingsExportOpened;

  /// No description provided for @settingsExportCancelled.
  ///
  /// In en, this message translates to:
  /// **'Export cancelled.'**
  String get settingsExportCancelled;

  /// No description provided for @settingsExportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device can’t open the share and save screen.'**
  String get settingsExportUnavailable;

  /// No description provided for @settingsExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t export your records. Try again.'**
  String get settingsExportFailed;

  /// No description provided for @settingsDeleteAllDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data?'**
  String get settingsDeleteAllDialogTitle;

  /// No description provided for @settingsResetPreviewDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset preview data?'**
  String get settingsResetPreviewDialogTitle;

  /// No description provided for @settingsDeleteAllDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes chats, diaries, photos, AI companion settings, AI memories, in-app export files, and AI data-sharing consent from this device. It can’t be undone. Copies exported to other apps or files can’t be deleted by Namu.'**
  String get settingsDeleteAllDialogBody;

  /// No description provided for @settingsResetPreviewDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This resets only the temporary data in this browser preview. It does not verify deletion from device storage.'**
  String get settingsResetPreviewDialogBody;

  /// No description provided for @settingsDeleteAllAction.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get settingsDeleteAllAction;

  /// No description provided for @settingsAiSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get settingsAiSectionTitle;

  /// No description provided for @settingsPersonaTitle.
  ///
  /// In en, this message translates to:
  /// **'AI companion settings'**
  String get settingsPersonaTitle;

  /// No description provided for @settingsPersonaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, tone, profile, and reply length'**
  String get settingsPersonaSubtitle;

  /// No description provided for @settingsConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'AI data-sharing settings'**
  String get settingsConsentTitle;

  /// No description provided for @settingsConsentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review or withdraw your consent'**
  String get settingsConsentSubtitle;

  /// No description provided for @settingsMyDataSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'My data'**
  String get settingsMyDataSectionTitle;

  /// No description provided for @settingsTransientStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary browser storage'**
  String get settingsTransientStorageTitle;

  /// No description provided for @settingsDeviceStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this device'**
  String get settingsDeviceStorageTitle;

  /// No description provided for @settingsTransientStorageBody.
  ///
  /// In en, this message translates to:
  /// **'This browser preview uses temporary data that may disappear when it restarts.'**
  String get settingsTransientStorageBody;

  /// No description provided for @settingsDeviceStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Chats, diaries, and photos are stored on this device and can’t be recovered after the app is deleted or the device is lost.'**
  String get settingsDeviceStorageBody;

  /// No description provided for @settingsExportJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Export records as JSON'**
  String get settingsExportJsonTitle;

  /// No description provided for @settingsExportWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Export isn’t supported in the browser preview.'**
  String get settingsExportWebUnavailable;

  /// No description provided for @settingsExportJsonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export chats, diaries, memories, and AI settings as JSON. Photo files are not included.'**
  String get settingsExportJsonSubtitle;

  /// No description provided for @settingsResetPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset preview data'**
  String get settingsResetPreviewTitle;

  /// No description provided for @settingsDeleteAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get settingsDeleteAllTitle;

  /// No description provided for @settingsResetPreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear only the current temporary state, not device data.'**
  String get settingsResetPreviewSubtitle;

  /// No description provided for @settingsDeleteAllSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete in-app data, including AI data-sharing consent.'**
  String get settingsDeleteAllSubtitle;

  /// No description provided for @settingsResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t finish deleting your data. Try again.'**
  String get settingsResetFailed;

  /// No description provided for @settingsExportShareText.
  ///
  /// In en, this message translates to:
  /// **'Namu local records JSON export'**
  String get settingsExportShareText;

  /// No description provided for @shareSheetOpenedNotPosted.
  ///
  /// In en, this message translates to:
  /// **'The share screen is open. Check the selected app to see whether anything was posted.'**
  String get shareSheetOpenedNotPosted;

  /// No description provided for @shareRendererTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s record'**
  String get shareRendererTodayTitle;

  /// No description provided for @shareRendererPhotoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Photo unavailable'**
  String get shareRendererPhotoUnavailable;

  /// No description provided for @shareRendererPageNumber.
  ///
  /// In en, this message translates to:
  /// **'{pageNumber} / {pageCount}'**
  String shareRendererPageNumber(int pageNumber, int pageCount);

  /// No description provided for @shareRendererWeatherWithTemperature.
  ///
  /// In en, this message translates to:
  /// **'{condition} {temperature}°C'**
  String shareRendererWeatherWithTemperature(
    String condition,
    String temperature,
  );

  /// Metadata line in the user-initiated share caption. Mood is user-authored content.
  ///
  /// In en, this message translates to:
  /// **'{date} · {weather} · {mood}'**
  String shareCaptionMetadata(String date, String weather, String mood);

  /// No description provided for @todayNoDiaryToEdit.
  ///
  /// In en, this message translates to:
  /// **'There’s no diary to edit.'**
  String get todayNoDiaryToEdit;

  /// No description provided for @todayChatRefreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t refresh today’s conversation.'**
  String get todayChatRefreshFailed;

  /// No description provided for @todayPhotoAttachedReplyFailed.
  ///
  /// In en, this message translates to:
  /// **'The photo was attached, but no AI reply arrived. Your record is still on this device.'**
  String get todayPhotoAttachedReplyFailed;

  /// No description provided for @todayPhotoMobileAndGatewayNeeded.
  ///
  /// In en, this message translates to:
  /// **'Photo selection is available in the mobile app. An AI Gateway connection is also required.'**
  String get todayPhotoMobileAndGatewayNeeded;

  /// No description provided for @todayConsentNeededForDiary.
  ///
  /// In en, this message translates to:
  /// **'Agree to AI data sharing to create a diary draft.'**
  String get todayConsentNeededForDiary;

  /// No description provided for @todayFinalizeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save the diary as final.'**
  String get todayFinalizeFailed;

  /// No description provided for @todayMemoryCandidatesFailed.
  ///
  /// In en, this message translates to:
  /// **'The diary was saved, but Namu couldn’t prepare memory suggestions.'**
  String get todayMemoryCandidatesFailed;

  /// No description provided for @todayNoDiaryToShare.
  ///
  /// In en, this message translates to:
  /// **'There’s no diary to share.'**
  String get todayNoDiaryToShare;

  /// No description provided for @todayShareUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The share screen isn’t available in this environment.'**
  String get todayShareUnavailable;

  /// No description provided for @todayShareCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sharing was cancelled. Your diary is still on this device.'**
  String get todayShareCancelled;

  /// No description provided for @todayShareImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t create the share images. Try again.'**
  String get todayShareImageFailed;

  /// No description provided for @todayDiaryAlreadyVisible.
  ///
  /// In en, this message translates to:
  /// **'Today’s diary is open on the right.'**
  String get todayDiaryAlreadyVisible;

  /// No description provided for @todayNavChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get todayNavChat;

  /// No description provided for @todayNavDiary.
  ///
  /// In en, this message translates to:
  /// **'Today’s diary'**
  String get todayNavDiary;

  /// No description provided for @todayNavArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get todayNavArchive;

  /// No description provided for @todayNavMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get todayNavMemory;

  /// No description provided for @todayNavSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get todayNavSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
