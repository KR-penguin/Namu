import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/presentation/gateway_failure_message.dart';
import '../../../l10n/namu_formatters.dart';
import '../../../l10n/namu_localizations.dart';
import '../../archive/application/archive_controller.dart';
import '../../archive/presentation/archive_screen.dart';
import '../../chat/application/chat_controller.dart';
import '../../chat/presentation/conversation_panel.dart';
import '../../consent/application/ai_data_consent_controller.dart';
import '../../consent/presentation/ai_data_consent_settings_sheet.dart';
import '../../diary/application/diary_controller.dart';
import '../../diary/domain/diary_entry.dart';
import '../../diary/presentation/diary_editor_sheet.dart';
import '../../diary/presentation/diary_preview_panel.dart';
import '../../memory/application/memory_management_controller.dart';
import '../../memory/presentation/memory_management_screen.dart';
import '../../media/presentation/local_photo.dart';
import '../../persona/application/persona_controller.dart';
import '../../persona/domain/ai_persona.dart';
import '../../persona/presentation/persona_settings_sheet.dart';
import '../../share/domain/diary_share_renderer.dart';
import '../../share/domain/share_sheet_launcher.dart';
import '../../settings/domain/local_data_eraser.dart';
import '../../settings/domain/local_data_export.dart';
import '../../settings/presentation/settings_screen.dart';

final class TodayScreen extends StatefulWidget {
  const TodayScreen({
    required this.chatController,
    required this.archiveController,
    required this.diaryController,
    required this.memoryController,
    required this.personaController,
    required this.aiDataConsentController,
    required this.gatewayConfigured,
    required this.localDataResetKind,
    this.onAttachPhoto,
    this.photoBytesLoader,
    this.onDiaryFinalized,
    this.onShareDiary,
    this.onResetAllLocalData,
    this.onExportLocalData,
    super.key,
  });

  final ChatController chatController;
  final ArchiveController archiveController;
  final DiaryController diaryController;
  final MemoryManagementController memoryController;
  final PersonaController personaController;
  final AiDataConsentController aiDataConsentController;
  final bool gatewayConfigured;
  final LocalDataResetKind localDataResetKind;
  final Future<void> Function()? onAttachPhoto;
  final LocalPhotoBytesLoader? photoBytesLoader;
  final Future<void> Function(DiaryEntry entry)? onDiaryFinalized;
  final Future<ShareSheetOutcome> Function(
    DiaryEntry entry,
    DiaryShareLocalizedCopy localizedCopy,
  )?
  onShareDiary;
  final Future<void> Function()? onResetAllLocalData;
  final Future<LocalDataExportOutcome> Function(String shareText)?
  onExportLocalData;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

final class _TodayScreenState extends State<TodayScreen> {
  static const _desktopBreakpoint = 900.0;

  var _mobileSection = 0;
  var _desktopArchiveVisible = false;
  var _desktopMemoryVisible = false;
  var _desktopSettingsVisible = false;
  int? _lastDiarySourceFingerprint;
  var _isSyncingDiarySources = false;
  var _diarySourceSyncPending = false;

  @override
  void initState() {
    super.initState();
    widget.chatController.addListener(_onChatChanged);
  }

  @override
  void didUpdateWidget(covariant TodayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatController == widget.chatController) {
      return;
    }
    oldWidget.chatController.removeListener(_onChatChanged);
    widget.chatController.addListener(_onChatChanged);
    _lastDiarySourceFingerprint = null;
  }

  @override
  void dispose() {
    widget.chatController.removeListener(_onChatChanged);
    super.dispose();
  }

  void _onChatChanged() {
    final chat = widget.chatController;
    if (chat.isLoading || chat.isSending) {
      return;
    }
    final fingerprint = Object.hashAll(
      chat.messages.map((message) => Object.hash(message.id, message.status)),
    );
    if (_lastDiarySourceFingerprint == fingerprint) {
      return;
    }
    _lastDiarySourceFingerprint = fingerprint;
    unawaited(_syncDiarySourcesAfterChat());
  }

  Future<void> _syncDiarySourcesAfterChat() async {
    if (_isSyncingDiarySources) {
      _diarySourceSyncPending = true;
      return;
    }
    _isSyncingDiarySources = true;
    do {
      _diarySourceSyncPending = false;
      try {
        await widget.diaryController.refreshSources();
      } catch (_) {
        // Explicit diary navigation retains the visible retry feedback.
      }
    } while (_diarySourceSyncPending && mounted);
    _isSyncingDiarySources = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.chatController,
        widget.diaryController,
        widget.personaController,
        widget.aiDataConsentController,
      ]),
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= _desktopBreakpoint) {
            if (_desktopSettingsVisible) {
              return SettingsScreen(
                localDataResetKind: widget.localDataResetKind,
                onResetAllLocalData: _resetAllLocalData,
                onOpenAiPersona: _showPersonaSettings,
                onOpenAiDataConsent: _showAiDataConsentSettings,
                onExportLocalData: widget.onExportLocalData,
                onBack: () => setState(() => _desktopSettingsVisible = false),
              );
            }
            if (_desktopMemoryVisible) {
              return MemoryManagementScreen(
                controller: widget.memoryController,
                onBack: () => setState(() => _desktopMemoryVisible = false),
              );
            }
            if (_desktopArchiveVisible) {
              return ArchiveScreen(
                controller: widget.archiveController,
                onBack: () => setState(() => _desktopArchiveVisible = false),
                onEntrySelected: _showArchivedDiary,
              );
            }
            return _DesktopToday(
              chatController: widget.chatController,
              diaryController: widget.diaryController,
              persona: widget.personaController.persona,
              gatewayConfigured: widget.gatewayConfigured,
              aiRequestsAllowed:
                  widget.aiDataConsentController.allowsAiRequests,
              onAttachPhoto: widget.onAttachPhoto == null
                  ? null
                  : () => unawaited(_attachPhoto()),
              photoBytesLoader: widget.photoBytesLoader,
              onEditPersona: _showPersonaSettings,
              onGenerateDiary: _generateDiary,
              onFinalizeDiary: _finalizeDiary,
              onEditDiary: _showDiaryEditor,
              onShareDiary: _shareCurrentDiary,
              onShowDiary: _showDiaryAlreadyVisible,
              onShowArchive: _showDesktopArchive,
              onShowMemory: _showDesktopMemory,
              onShowSettings: _showDesktopSettings,
            );
          }

          return _MobileToday(
            selectedSection: _mobileSection,
            chatController: widget.chatController,
            diaryController: widget.diaryController,
            archiveController: widget.archiveController,
            memoryController: widget.memoryController,
            persona: widget.personaController.persona,
            gatewayConfigured: widget.gatewayConfigured,
            aiRequestsAllowed: widget.aiDataConsentController.allowsAiRequests,
            onAttachPhoto: widget.onAttachPhoto == null
                ? null
                : () => unawaited(_attachPhoto()),
            photoBytesLoader: widget.photoBytesLoader,
            onEditPersona: _showPersonaSettings,
            onGenerateDiary: _generateDiary,
            onFinalizeDiary: _finalizeDiary,
            onSectionSelected: _selectMobileSection,
            onEntrySelected: _showArchivedDiary,
            onEditDiary: _showDiaryEditor,
            onShareDiary: _shareCurrentDiary,
            localDataResetKind: widget.localDataResetKind,
            onResetAllLocalData: _resetAllLocalData,
            onOpenAiDataConsent: _showAiDataConsentSettings,
            onExportLocalData: widget.onExportLocalData,
          );
        },
      ),
    );
  }

  void _showDesktopArchive() {
    setState(() {
      _desktopMemoryVisible = false;
      _desktopSettingsVisible = false;
      _desktopArchiveVisible = true;
    });
    unawaited(_reloadArchive());
  }

  void _showDesktopMemory() {
    setState(() {
      _desktopArchiveVisible = false;
      _desktopSettingsVisible = false;
      _desktopMemoryVisible = true;
    });
    unawaited(_reloadMemories());
  }

  void _showDesktopSettings() {
    setState(() {
      _desktopArchiveVisible = false;
      _desktopMemoryVisible = false;
      _desktopSettingsVisible = true;
    });
  }

  void _selectMobileSection(int section) {
    setState(() => _mobileSection = section);
    if (section == 1) {
      unawaited(_refreshDiarySources());
    } else if (section == 2) {
      unawaited(_reloadArchive());
    } else if (section == 3) {
      unawaited(_reloadMemories());
    }
  }

  Future<void> _resetAllLocalData() async {
    final reset = widget.onResetAllLocalData;
    if (reset == null) {
      throw StateError('Local data reset is unavailable in this composition.');
    }
    await reset();
  }

  Future<void> _reloadArchive() async {
    try {
      await widget.archiveController.reload();
    } catch (_) {
      // ArchiveScreen owns the retryable, redacted error presentation.
    }
  }

  Future<void> _reloadMemories() async {
    try {
      await widget.memoryController.reload();
    } catch (_) {
      // MemoryManagementScreen owns the retryable, redacted error presentation.
    }
  }

  void _showArchivedDiary(DiaryEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.96,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: DiaryPreviewPanel(
            dayKey: entry.dayKey,
            entry: entry,
            isGenerating: false,
            canGenerate: false,
            onBack: () => Navigator.of(sheetContext).pop(),
            onShare:
                entry.status == DiaryEntryStatus.finalized &&
                    widget.onShareDiary != null
                ? () => unawaited(_shareDiary(entry))
                : null,
            photoBytesLoader: widget.photoBytesLoader,
          ),
        ),
      ),
    );
  }

  void _showPersonaSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => PersonaSettingsSheet(
        controller: widget.personaController,
        onOpenAiDataConsent: () {
          Navigator.of(sheetContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showAiDataConsentSettings();
            }
          });
        },
      ),
    );
  }

  void _showAiDataConsentSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AiDataConsentSettingsSheet(
        controller: widget.aiDataConsentController,
      ),
    );
  }

  void _showDiaryEditor() {
    if (widget.diaryController.entry == null) {
      _showOperationFailure(context.l10n.todayNoDiaryToEdit);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DiaryEditorSheet(
        controller: widget.diaryController,
        photoBytesLoader: widget.photoBytesLoader,
      ),
    );
  }

  Future<void> _refreshDiarySources() async {
    try {
      await widget.diaryController.refreshSources();
    } catch (_) {
      if (mounted) {
        _showOperationFailure(context.l10n.todayChatRefreshFailed);
      }
    }
  }

  Future<void> _attachPhoto() async {
    try {
      await widget.onAttachPhoto?.call();
    } catch (_) {
      if (mounted) {
        _showOperationFailure(
          widget.gatewayConfigured
              ? context.l10n.todayPhotoAttachedReplyFailed
              : context.l10n.todayPhotoMobileAndGatewayNeeded,
        );
      }
    }
  }

  Future<void> _generateDiary() async {
    if (!widget.aiDataConsentController.allowsAiRequests) {
      _showOperationFailure(context.l10n.todayConsentNeededForDiary);
      return;
    }
    try {
      await widget.diaryController.generate();
    } catch (error) {
      if (mounted) {
        _showOperationFailure(
          gatewayFailureMessage(
            error,
            operation: AiGatewayOperation.diaryDraft,
            l10n: context.l10n,
          ),
        );
      }
    }
  }

  Future<void> _finalizeDiary() async {
    try {
      await widget.diaryController.finalize();
      await _reloadArchive();
    } catch (_) {
      if (mounted) {
        _showOperationFailure(context.l10n.todayFinalizeFailed);
      }
      return;
    }

    final entry = widget.diaryController.entry;
    if (entry == null || widget.onDiaryFinalized == null) {
      return;
    }
    try {
      await widget.onDiaryFinalized!(entry);
    } catch (_) {
      if (mounted) {
        _showOperationFailure(context.l10n.todayMemoryCandidatesFailed);
      }
    }
  }

  void _shareCurrentDiary() {
    final entry = widget.diaryController.entry;
    if (entry == null) {
      _showOperationFailure(context.l10n.todayNoDiaryToShare);
      return;
    }
    unawaited(_shareDiary(entry));
  }

  Future<void> _shareDiary(DiaryEntry entry) async {
    final shareDiary = widget.onShareDiary;
    if (shareDiary == null) {
      _showOperationFailure(context.l10n.todayShareUnavailable);
      return;
    }
    try {
      final outcome = await shareDiary(entry, _localizedShareCopy(entry));
      if (!mounted) {
        return;
      }
      switch (outcome) {
        case ShareSheetOutcome.opened || ShareSheetOutcome.completed:
          _showOperationFailure(context.l10n.shareSheetOpenedNotPosted);
        case ShareSheetOutcome.dismissed:
          _showOperationFailure(context.l10n.todayShareCancelled);
        case ShareSheetOutcome.unavailable:
          _showOperationFailure(context.l10n.todayShareUnavailable);
      }
    } catch (_) {
      if (mounted) {
        _showOperationFailure(context.l10n.todayShareImageFailed);
      }
    }
  }

  DiaryShareLocalizedCopy _localizedShareCopy(DiaryEntry entry) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;
    final condition = entry.weather.condition?.trim();
    final temperature = entry.weather.temperatureCelsius;
    final displayDate = NamuFormatters.fullDate(entry.dayKey.labelDate, locale);
    final displayWeather = condition == null || condition.isEmpty
        ? l10n.diaryWeatherNone
        : temperature == null
        ? condition
        : l10n.shareRendererWeatherWithTemperature(
            condition,
            NamuFormatters.decimal(temperature, locale),
          );

    return DiaryShareLocalizedCopy(
      title: l10n.shareRendererTodayTitle,
      displayDate: displayDate,
      displayWeather: displayWeather,
      captionMetadata: l10n.shareCaptionMetadata(
        displayDate,
        displayWeather,
        entry.mood,
      ),
      formatPageNumber: l10n.shareRendererPageNumber,
      photoUnavailableMessage: l10n.shareRendererPhotoUnavailable,
    );
  }

  void _showOperationFailure(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _showDiaryAlreadyVisible() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.todayDiaryAlreadyVisible),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

final class _DesktopToday extends StatelessWidget {
  const _DesktopToday({
    required this.chatController,
    required this.diaryController,
    required this.persona,
    required this.gatewayConfigured,
    required this.aiRequestsAllowed,
    required this.onAttachPhoto,
    required this.photoBytesLoader,
    required this.onEditPersona,
    required this.onGenerateDiary,
    required this.onFinalizeDiary,
    required this.onEditDiary,
    required this.onShareDiary,
    required this.onShowDiary,
    required this.onShowArchive,
    required this.onShowMemory,
    required this.onShowSettings,
  });

  final ChatController chatController;
  final DiaryController diaryController;
  final AiPersona persona;
  final bool gatewayConfigured;
  final bool aiRequestsAllowed;
  final VoidCallback? onAttachPhoto;
  final LocalPhotoBytesLoader? photoBytesLoader;
  final VoidCallback onEditPersona;
  final VoidCallback onGenerateDiary;
  final VoidCallback onFinalizeDiary;
  final VoidCallback onEditDiary;
  final VoidCallback onShareDiary;
  final VoidCallback onShowDiary;
  final VoidCallback onShowArchive;
  final VoidCallback onShowMemory;
  final VoidCallback onShowSettings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('today.desktop'),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            key: const Key('today.openSettings'),
            heroTag: 'today.openSettings',
            onPressed: onShowSettings,
            icon: const Icon(Icons.settings_outlined),
            label: Text(context.l10n.todayNavSettings),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const Key('today.openMemory'),
            heroTag: 'today.openMemory',
            onPressed: onShowMemory,
            icon: const Icon(Icons.psychology_alt_outlined),
            label: Text(context.l10n.todayNavMemory),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const Key('today.openArchive'),
            heroTag: 'today.openArchive',
            onPressed: onShowArchive,
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: Text(context.l10n.todayNavArchive),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 430,
                    child: _PanelFrame(
                      child: ConversationPanel(
                        controller: chatController,
                        persona: persona,
                        gatewayConfigured: gatewayConfigured,
                        aiRequestsAllowed: aiRequestsAllowed,
                        onAttachPhoto: onAttachPhoto,
                        photoBytesLoader: photoBytesLoader,
                        onEditPersona: onEditPersona,
                        onShowDiary: onShowDiary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _PanelFrame(
                      child: DiaryPreviewPanel(
                        dayKey: chatController.dayKey,
                        entry: diaryController.entry,
                        isGenerating: diaryController.isGenerating,
                        canGenerate: diaryController.canGenerate,
                        onGenerate: onGenerateDiary,
                        onFinalize: onFinalizeDiary,
                        onEdit: onEditDiary,
                        onShare: onShareDiary,
                        photoBytesLoader: photoBytesLoader,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _MobileToday extends StatelessWidget {
  const _MobileToday({
    required this.selectedSection,
    required this.chatController,
    required this.diaryController,
    required this.archiveController,
    required this.memoryController,
    required this.persona,
    required this.gatewayConfigured,
    required this.aiRequestsAllowed,
    required this.onAttachPhoto,
    required this.photoBytesLoader,
    required this.onEditPersona,
    required this.onGenerateDiary,
    required this.onFinalizeDiary,
    required this.onEditDiary,
    required this.onSectionSelected,
    required this.onEntrySelected,
    required this.onShareDiary,
    required this.localDataResetKind,
    required this.onResetAllLocalData,
    required this.onOpenAiDataConsent,
    required this.onExportLocalData,
  });

  final int selectedSection;
  final ChatController chatController;
  final DiaryController diaryController;
  final ArchiveController archiveController;
  final MemoryManagementController memoryController;
  final AiPersona persona;
  final bool gatewayConfigured;
  final bool aiRequestsAllowed;
  final VoidCallback? onAttachPhoto;
  final LocalPhotoBytesLoader? photoBytesLoader;
  final VoidCallback onEditPersona;
  final VoidCallback onGenerateDiary;
  final VoidCallback onFinalizeDiary;
  final VoidCallback onEditDiary;
  final ValueChanged<int> onSectionSelected;
  final ValueChanged<DiaryEntry> onEntrySelected;
  final VoidCallback onShareDiary;
  final LocalDataResetKind localDataResetKind;
  final Future<void> Function() onResetAllLocalData;
  final VoidCallback onOpenAiDataConsent;
  final Future<LocalDataExportOutcome> Function(String shareText)?
  onExportLocalData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('today.mobile'),
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (selectedSection) {
            0 => ConversationPanel(
              key: const ValueKey('conversation'),
              controller: chatController,
              persona: persona,
              gatewayConfigured: gatewayConfigured,
              aiRequestsAllowed: aiRequestsAllowed,
              onAttachPhoto: onAttachPhoto,
              photoBytesLoader: photoBytesLoader,
              onEditPersona: onEditPersona,
              onShowDiary: () => onSectionSelected(1),
            ),
            1 => DiaryPreviewPanel(
              key: const ValueKey('diary'),
              dayKey: chatController.dayKey,
              entry: diaryController.entry,
              isGenerating: diaryController.isGenerating,
              canGenerate: diaryController.canGenerate,
              onBack: () => onSectionSelected(0),
              onGenerate: onGenerateDiary,
              onFinalize: onFinalizeDiary,
              onEdit: onEditDiary,
              onShare: onShareDiary,
              photoBytesLoader: photoBytesLoader,
            ),
            2 => ArchiveScreen(
              key: const ValueKey('archive'),
              controller: archiveController,
              onEntrySelected: onEntrySelected,
            ),
            3 => MemoryManagementScreen(
              key: const ValueKey('memory'),
              controller: memoryController,
            ),
            _ => SettingsScreen(
              key: const ValueKey('settings'),
              localDataResetKind: localDataResetKind,
              onResetAllLocalData: onResetAllLocalData,
              onOpenAiPersona: onEditPersona,
              onOpenAiDataConsent: onOpenAiDataConsent,
              onExportLocalData: onExportLocalData,
            ),
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedSection,
        onDestinationSelected: onSectionSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: context.l10n.todayNavChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_stories_outlined),
            selectedIcon: const Icon(Icons.auto_stories_rounded),
            label: context.l10n.todayNavDiary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.collections_bookmark_outlined),
            selectedIcon: const Icon(Icons.collections_bookmark_rounded),
            label: context.l10n.todayNavArchive,
          ),
          NavigationDestination(
            icon: const Icon(Icons.psychology_alt_outlined),
            selectedIcon: const Icon(Icons.psychology_alt_rounded),
            label: context.l10n.todayNavMemory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: context.l10n.todayNavSettings,
          ),
        ],
      ),
    );
  }
}

final class _PanelFrame extends StatelessWidget {
  const _PanelFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2318),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(28), child: child),
    );
  }
}
