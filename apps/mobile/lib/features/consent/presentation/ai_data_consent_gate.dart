import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/namu_localizations.dart';
import '../application/ai_data_consent_controller.dart';

final class AiDataConsentGate extends StatefulWidget {
  const AiDataConsentGate({
    required this.controller,
    required this.child,
    super.key,
  });

  final AiDataConsentController controller;
  final Widget child;

  @override
  State<AiDataConsentGate> createState() => _AiDataConsentGateState();
}

final class _AiDataConsentGateState extends State<AiDataConsentGate> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    if (!widget.controller.hasLoaded) {
      unawaited(_load());
    }
  }

  @override
  void didUpdateWidget(covariant AiDataConsentGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_onChanged);
    widget.controller.addListener(_onChanged);
    if (!widget.controller.hasLoaded) {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await widget.controller.load();
    } catch (_) {
      // The controller exposes a redacted retry state below.
    }
  }

  Future<void> _accept() async {
    try {
      await widget.controller.accept();
    } catch (_) {
      // The controller exposes a redacted retry state below.
    }
  }

  Future<void> _decline() async {
    try {
      await widget.controller.decline();
    } catch (_) {
      // The controller exposes a redacted retry state below.
    }
  }

  void _onChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (!controller.hasLoaded && controller.error == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (!controller.hasLoaded && controller.error != null) {
      return _ConsentLoadError(onRetry: () => unawaited(_load()));
    }
    if (controller.hasCompletedFirstRun) {
      return widget.child;
    }
    return _ConsentOnboarding(
      isSaving: controller.isSaving,
      hasError: controller.error != null,
      onAccept: () => unawaited(_accept()),
      onDecline: () => unawaited(_decline()),
    );
  }
}

final class _ConsentOnboarding extends StatelessWidget {
  const _ConsentOnboarding({
    required this.isSaving,
    required this.hasError,
    required this.onAccept,
    required this.onDecline,
  });

  final bool isSaving;
  final bool hasError;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 52,
                    color: colors.primary,
                    semanticLabel: context.l10n.consentDisclosureSemantics,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.consentTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(context.l10n.consentTransferBody),
                  const SizedBox(height: 12),
                  Text(context.l10n.consentPhotoBoundaryBody),
                  const SizedBox(height: 12),
                  Text(context.l10n.consentLocalUseBody),
                  if (hasError) ...[
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.consentSaveFailed,
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    key: const Key('ai-consent.accept'),
                    onPressed: isSaving ? null : onAccept,
                    child: Text(context.l10n.consentAcceptAndStart),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('ai-consent.decline'),
                    onPressed: isSaving ? null : onDecline,
                    child: Text(context.l10n.consentDeclineAndUseLocal),
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

final class _ConsentLoadError extends StatelessWidget {
  const _ConsentLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.consentLoadError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
