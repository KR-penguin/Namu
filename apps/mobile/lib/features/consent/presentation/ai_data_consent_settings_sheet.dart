import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/namu_localizations.dart';
import '../application/ai_data_consent_controller.dart';

final class AiDataConsentSettingsSheet extends StatelessWidget {
  const AiDataConsentSettingsSheet({required this.controller, super.key});

  final AiDataConsentController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final allowed = controller.allowsAiRequests;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              20,
              24,
              24 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.consentSettingsTitle,
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.commonClose,
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.l10n.consentSettingsStatus(
                    allowed ? 'allowed' : 'declined',
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(context.l10n.consentSettingsRequestBody),
                const SizedBox(height: 8),
                Text(context.l10n.consentSettingsPhotoBody),
                if (controller.error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.consentSettingsSaveFailed,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (allowed)
                  OutlinedButton(
                    key: const Key('ai-consent.revoke'),
                    onPressed: controller.isSaving
                        ? null
                        : () => unawaited(_revoke()),
                    child: Text(context.l10n.consentRevoke),
                  )
                else
                  FilledButton(
                    key: const Key('ai-consent.accept-in-settings'),
                    onPressed: controller.isSaving
                        ? null
                        : () => unawaited(_accept()),
                    child: Text(context.l10n.consentAccept),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _accept() async {
    try {
      await controller.accept();
    } catch (_) {
      // Controller state renders a redacted retry message.
    }
  }

  Future<void> _revoke() async {
    try {
      await controller.revoke();
    } catch (_) {
      // Controller state renders a redacted retry message.
    }
  }
}
