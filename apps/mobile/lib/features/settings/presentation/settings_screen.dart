import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/namu_localizations.dart';
import '../domain/local_data_eraser.dart';
import '../domain/local_data_export.dart';

final class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.localDataResetKind,
    required this.onResetAllLocalData,
    required this.onOpenAiPersona,
    required this.onOpenAiDataConsent,
    this.onExportLocalData,
    this.onBack,
    super.key,
  });

  final LocalDataResetKind localDataResetKind;
  final Future<void> Function() onResetAllLocalData;
  final VoidCallback onOpenAiPersona;
  final VoidCallback onOpenAiDataConsent;
  final Future<LocalDataExportOutcome> Function(String shareText)?
  onExportLocalData;
  final VoidCallback? onBack;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen> {
  var _isResetting = false;
  var _resetFailed = false;
  var _isExporting = false;
  String? _exportErrorMessage;
  String? _exportStatusMessage;

  Future<void> _requestExport() async {
    final l10n = context.l10n;
    final export = widget.onExportLocalData;
    if (_isExporting || _isResetting || export == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settingsExportDialogTitle),
        content: Text(context.l10n.exportDialogBody),
        actions: [
          TextButton(
            key: const Key('settings.export.cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('settings.export.confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonExport),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isExporting = true;
      _exportErrorMessage = null;
      _exportStatusMessage = null;
    });
    try {
      final outcome = await export(l10n.settingsExportShareText);
      if (!mounted) {
        return;
      }
      switch (outcome) {
        case LocalDataExportOutcome.opened:
        case LocalDataExportOutcome.completed:
          setState(() => _exportStatusMessage = l10n.settingsExportOpened);
        case LocalDataExportOutcome.dismissed:
          setState(() => _exportStatusMessage = l10n.settingsExportCancelled);
        case LocalDataExportOutcome.unavailable:
          setState(() {
            _exportErrorMessage = l10n.settingsExportUnavailable;
          });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _exportErrorMessage = l10n.settingsExportFailed;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _requestReset() async {
    if (_isResetting) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.localDataResetKind == LocalDataResetKind.persistentNative
              ? context.l10n.settingsDeleteAllDialogTitle
              : context.l10n.settingsResetPreviewDialogTitle,
        ),
        content: Text(
          widget.localDataResetKind == LocalDataResetKind.persistentNative
              ? context.l10n.settingsDeleteAllDialogBody
              : context.l10n.settingsResetPreviewDialogBody,
        ),
        actions: [
          TextButton(
            key: const Key('settings.deleteAll.cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            key: const Key('settings.deleteAll.confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(context.l10n.settingsDeleteAllAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isResetting = true;
      _resetFailed = false;
    });
    try {
      await widget.onResetAllLocalData();
    } catch (_) {
      if (mounted) {
        setState(() => _resetFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isResetting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final transient =
        widget.localDataResetKind == LocalDataResetKind.transientPreview;

    return ColoredBox(
      key: const Key('settings.screen'),
      color: const Color(0xFFF4F1EA),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      onPressed: widget.onBack,
                      tooltip: context.l10n.commonBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      context.l10n.settingsTitle,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _SettingsCard(
                    title: context.l10n.settingsAiSectionTitle,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.face_outlined),
                        title: Text(context.l10n.settingsPersonaTitle),
                        subtitle: Text(context.l10n.settingsPersonaSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: widget.onOpenAiPersona,
                      ),
                      ListTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: Text(context.l10n.settingsConsentTitle),
                        subtitle: Text(context.l10n.settingsConsentSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: widget.onOpenAiDataConsent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    title: context.l10n.settingsMyDataSectionTitle,
                    children: [
                      ListTile(
                        leading: Icon(
                          transient
                              ? Icons.language_rounded
                              : Icons.phone_android_rounded,
                        ),
                        title: Text(
                          transient
                              ? context.l10n.settingsTransientStorageTitle
                              : context.l10n.settingsDeviceStorageTitle,
                        ),
                        subtitle: Text(
                          transient
                              ? context.l10n.settingsTransientStorageBody
                              : context.l10n.settingsDeviceStorageBody,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: const Key('settings.exportJson'),
                        enabled:
                            !transient &&
                            widget.onExportLocalData != null &&
                            !_isExporting &&
                            !_isResetting,
                        leading: const Icon(Icons.file_download_outlined),
                        title: Text(context.l10n.settingsExportJsonTitle),
                        subtitle: Text(
                          transient
                              ? context.l10n.settingsExportWebUnavailable
                              : context.l10n.settingsExportJsonSubtitle,
                        ),
                        trailing: _isExporting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right_rounded),
                        onTap: transient || widget.onExportLocalData == null
                            ? null
                            : () => unawaited(_requestExport()),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: const Key('settings.deleteAll'),
                        enabled: !_isResetting && !_isExporting,
                        leading: Icon(
                          Icons.delete_forever_outlined,
                          color: colors.error,
                        ),
                        title: Text(
                          transient
                              ? context.l10n.settingsResetPreviewTitle
                              : context.l10n.settingsDeleteAllTitle,
                          style: TextStyle(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          transient
                              ? context.l10n.settingsResetPreviewSubtitle
                              : context.l10n.settingsDeleteAllSubtitle,
                        ),
                        trailing: _isResetting
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right_rounded),
                        onTap: _isResetting || _isExporting
                            ? null
                            : () => unawaited(_requestReset()),
                      ),
                    ],
                  ),
                  if (_resetFailed) ...[
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.settingsResetFailed,
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_exportErrorMessage case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (_exportStatusMessage case final message?) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }
}
