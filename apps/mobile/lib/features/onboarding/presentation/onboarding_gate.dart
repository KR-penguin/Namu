import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/namu_localizations.dart';
import '../../consent/application/ai_data_consent_controller.dart';
import '../application/onboarding_controller.dart';

final class OnboardingGate extends StatefulWidget {
  const OnboardingGate({
    required this.controller,
    required this.aiDataConsentController,
    required this.child,
    super.key,
  });

  final OnboardingController controller;
  final AiDataConsentController aiDataConsentController;
  final Widget child;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

final class _OnboardingGateState extends State<OnboardingGate> {
  @override
  void initState() {
    super.initState();
    _listen(widget);
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant OnboardingGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
    if (oldWidget.aiDataConsentController != widget.aiDataConsentController) {
      oldWidget.aiDataConsentController.removeListener(_onChanged);
      widget.aiDataConsentController.addListener(_onChanged);
    }
    unawaited(_load());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    widget.aiDataConsentController.removeListener(_onChanged);
    super.dispose();
  }

  void _listen(OnboardingGate source) {
    source.controller.addListener(_onChanged);
    source.aiDataConsentController.addListener(_onChanged);
  }

  Future<void> _load() async {
    if (!widget.controller.hasLoaded) {
      try {
        await widget.controller.load();
      } catch (_) {
        return;
      }
    }
    if (!widget.aiDataConsentController.hasLoaded) {
      try {
        await widget.aiDataConsentController.load();
      } catch (_) {
        // Consent storage failure must not block local-only product use.
      }
    }
  }

  Future<void> _acceptAiAndComplete() async {
    try {
      if (!widget.aiDataConsentController.allowsAiRequests) {
        await widget.aiDataConsentController.accept();
      }
      await widget.controller.complete();
    } catch (_) {
      // Both controllers expose redacted retry state below.
    }
  }

  Future<void> _completeLocalOnly() async {
    try {
      await widget.controller.complete();
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
    if (!controller.hasLoaded) {
      return _OnboardingLoadError(onRetry: () => unawaited(_load()));
    }
    if (controller.isComplete) {
      return widget.child;
    }
    return _OnboardingScreen(
      isSaving: controller.isSaving || widget.aiDataConsentController.isSaving,
      hasError:
          controller.error != null ||
          widget.aiDataConsentController.error != null,
      onAcceptAi: () => unawaited(_acceptAiAndComplete()),
      onStartLocal: () => unawaited(_completeLocalOnly()),
    );
  }
}

final class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({
    required this.isSaving,
    required this.hasError,
    required this.onAcceptAi,
    required this.onStartLocal,
  });

  final bool isSaving;
  final bool hasError;
  final VoidCallback onAcceptAi;
  final VoidCallback onStartLocal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.eco_outlined,
                    size: 52,
                    color: colors.primary,
                    semanticLabel: context.l10n.onboardingSemantics,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.onboardingTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _DisclosureCard(
                    icon: Icons.phone_android_rounded,
                    title: context.l10n.onboardingLocalStorageTitle,
                    body: context.l10n.onboardingLocalStorageBody,
                  ),
                  const SizedBox(height: 12),
                  _DisclosureCard(
                    icon: Icons.auto_awesome_outlined,
                    title: context.l10n.onboardingAiDisclosureTitle,
                    body: context.l10n.onboardingAiDisclosureBody,
                  ),
                  const SizedBox(height: 12),
                  _DisclosureCard(
                    icon: Icons.shield_outlined,
                    title: context.l10n.onboardingAiTransferTitle,
                    body: context.l10n.onboardingAiTransferBody,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.onboardingDecisionNote,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.onboardingSaveFailed,
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('onboarding.acceptAi'),
                    onPressed: isSaving ? null : onAcceptAi,
                    child: Text(context.l10n.onboardingAcceptAi),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('onboarding.startLocal'),
                    onPressed: isSaving ? null : onStartLocal,
                    child: Text(context.l10n.onboardingStartLocal),
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

final class _DisclosureCard extends StatelessWidget {
  const _DisclosureCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _OnboardingLoadError extends StatelessWidget {
  const _OnboardingLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.onboardingLoadError,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  key: const Key('onboarding.retry'),
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
