import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../l10n/namu_localizations.dart';
import '../application/memory_management_controller.dart';
import '../domain/memory_fact.dart';

final class MemoryManagementScreen extends StatefulWidget {
  const MemoryManagementScreen({
    required this.controller,
    this.onBack,
    super.key,
  });

  final MemoryManagementController controller;
  final VoidCallback? onBack;

  @override
  State<MemoryManagementScreen> createState() => _MemoryManagementScreenState();
}

final class _MemoryManagementScreenState extends State<MemoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    _scheduleInitialLoad();
  }

  @override
  void didUpdateWidget(covariant MemoryManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _scheduleInitialLoad();
    }
  }

  void _scheduleInitialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.controller.hasLoaded ||
          widget.controller.isLoading) {
        return;
      }
      unawaited(_reloadSafely());
    });
  }

  Future<void> _reloadSafely() async {
    try {
      await widget.controller.reload();
    } catch (_) {
      // The screen renders a fixed, retryable message without exposing data.
    }
  }

  Future<void> _approve(MemoryFact fact) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => _ApproveMemoryDialog(fact: fact),
    );
    if (approved != true || !mounted) {
      return;
    }
    try {
      await widget.controller.approve(fact.id);
    } catch (_) {
      if (mounted) {
        _showPrivateFeedback(context.l10n.memoryApproveFailed);
      }
    }
  }

  Future<void> _edit(MemoryFact fact) async {
    final editedFact = await showDialog<String>(
      context: context,
      builder: (context) => _EditMemoryDialog(initialFact: fact.fact),
    );
    if (editedFact == null || !mounted) {
      return;
    }
    try {
      await widget.controller.edit(id: fact.id, fact: editedFact);
    } catch (_) {
      if (mounted) {
        _showPrivateFeedback(context.l10n.memoryEditFailed);
      }
    }
  }

  Future<void> _delete(MemoryFact fact) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => const _DeleteMemoryDialog(),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }
    try {
      await widget.controller.delete(fact.id);
    } catch (_) {
      if (mounted) {
        _showPrivateFeedback(context.l10n.memoryDeleteFailed);
      }
    }
  }

  Future<void> _setActive(MemoryFact fact, bool active) async {
    try {
      await widget.controller.setActive(fact.id, active: active);
    } catch (_) {
      if (mounted) {
        _showPrivateFeedback(
          active
              ? context.l10n.memoryActivateFailed
              : context.l10n.memoryDeactivateFailed,
        );
      }
    }
  }

  void _showPrivateFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('memory.screen'),
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final controller = widget.controller;
            return Column(
              children: [
                _MemoryHeader(
                  isBusy: controller.isLoading || controller.isMutatingAny,
                  onBack: widget.onBack,
                  onReload: () => unawaited(_reloadSafely()),
                ),
                Expanded(
                  child: _MemoryBody(
                    controller: controller,
                    onReload: _reloadSafely,
                    onApprove: (fact) => unawaited(_approve(fact)),
                    onSetActive: (fact, active) =>
                        unawaited(_setActive(fact, active)),
                    onEdit: (fact) => unawaited(_edit(fact)),
                    onDelete: (fact) => unawaited(_delete(fact)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

final class _MemoryHeader extends StatelessWidget {
  const _MemoryHeader({
    required this.isBusy,
    required this.onReload,
    required this.onBack,
  });

  final bool isBusy;
  final VoidCallback onReload;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 10),
      child: Row(
        children: [
          if (onBack != null) ...[
            IconButton.outlined(
              onPressed: onBack,
              tooltip: context.l10n.commonBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.memoryTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.memorySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF6F716C)),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('memory.reload'),
            onPressed: isBusy ? null : onReload,
            tooltip: context.l10n.memoryReloadTooltip,
            icon: isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

final class _MemoryBody extends StatelessWidget {
  const _MemoryBody({
    required this.controller,
    required this.onReload,
    required this.onApprove,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final MemoryManagementController controller;
  final Future<void> Function() onReload;
  final ValueChanged<MemoryFact> onApprove;
  final void Function(MemoryFact fact, bool active) onSetActive;
  final ValueChanged<MemoryFact> onEdit;
  final ValueChanged<MemoryFact> onDelete;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && !controller.hasLoaded) {
      return Center(
        child: Semantics(
          label: context.l10n.memoryLoadingSemantics,
          child: const CircularProgressIndicator(key: Key('memory.loading')),
        ),
      );
    }
    if (controller.error != null && controller.facts.isEmpty) {
      return _MemoryError(onRetry: onReload);
    }
    if (controller.facts.isEmpty) {
      return const _MemoryEmpty();
    }

    final hasInlineError = controller.error != null;
    return RefreshIndicator(
      onRefresh: onReload,
      child: ListView.separated(
        key: const Key('memory.list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: controller.facts.length + (hasInlineError ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (hasInlineError && index == 0) {
            return _InlineMemoryError(onRetry: onReload);
          }
          final factIndex = index - (hasInlineError ? 1 : 0);
          final fact = controller.facts[factIndex];
          return _MemoryCard(
            fact: fact,
            isBusy: controller.isMutating(fact.id),
            actionsEnabled: !controller.isLoading,
            onApprove: () => onApprove(fact),
            onSetActive: (active) => onSetActive(fact, active),
            onEdit: () => onEdit(fact),
            onDelete: () => onDelete(fact),
          );
        },
      ),
    );
  }
}

final class _MemoryEmpty extends StatelessWidget {
  const _MemoryEmpty();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const Key('memory.empty'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5ECE6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_alt_outlined,
                    semanticLabel: context.l10n.memoryEmptySemantics,
                    size: 34,
                    color: Color(0xFF355F4B),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.memoryEmptyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.memoryEmptyBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: const Color(0xFF6F716C), height: 1.45),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _MemoryError extends StatelessWidget {
  const _MemoryError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        key: const Key('memory.error'),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_clock_outlined,
              semanticLabel: context.l10n.memoryLoadErrorSemantics,
              size: 42,
              color: Color(0xFF795439),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.memoryLoadErrorTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              context.l10n.memoryStoredDataSafeBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              key: const Key('memory.retry'),
              onPressed: () => unawaited(onRetry()),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

final class _InlineMemoryError extends StatelessWidget {
  const _InlineMemoryError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4E9DA),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.memoryRefreshError,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => unawaited(onRetry()),
              child: Text(context.l10n.commonRetryShort),
            ),
          ],
        ),
      ),
    );
  }
}

final class _MemoryCard extends StatelessWidget {
  const _MemoryCard({
    required this.fact,
    required this.isBusy,
    required this.actionsEnabled,
    required this.onApprove,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final MemoryFact fact;
  final bool isBusy;
  final bool actionsEnabled;
  final VoidCallback onApprove;
  final ValueChanged<bool> onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLabel = _statusLabel(fact.status, l10n);
    final categoryLabel = _categoryLabel(fact.category, l10n);
    final canUseActions = actionsEnabled && !isBusy;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l10n.memoryCardSemantics(fact.fact, statusLabel, categoryLabel),
      child: Material(
        key: Key('memory.item.${fact.id}'),
        color: const Color(0xFFFFFEFB),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2DED4)),
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MemoryStatusBadge(status: fact.status),
                  Text(
                    categoryLabel,
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: const Color(0xFF6F716C)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                fact.fact,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF292D28),
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
              if (fact.status == MemoryStatus.candidate &&
                  fact.sensitivity == MemorySensitivity.sensitive) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: Color(0xFF795439),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.memorySensitiveApprovalNotice,
                        style: const TextStyle(
                          color: Color(0xFF795439),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              if (isBusy)
                Semantics(
                  label: l10n.memoryChangingSemantics,
                  child: const LinearProgressIndicator(),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (fact.status == MemoryStatus.candidate)
                      FilledButton.icon(
                        key: Key('memory.approve.${fact.id}'),
                        onPressed: canUseActions ? onApprove : null,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(l10n.commonApprove),
                      ),
                    if (fact.status == MemoryStatus.active)
                      OutlinedButton.icon(
                        key: Key('memory.deactivate.${fact.id}'),
                        onPressed: canUseActions
                            ? () => onSetActive(false)
                            : null,
                        icon: const Icon(Icons.pause_circle_outline_rounded),
                        label: Text(l10n.memoryDeactivateAction),
                      ),
                    if (fact.status == MemoryStatus.inactive)
                      OutlinedButton.icon(
                        key: Key('memory.activate.${fact.id}'),
                        onPressed: canUseActions
                            ? () => onSetActive(true)
                            : null,
                        icon: const Icon(Icons.play_circle_outline_rounded),
                        label: Text(l10n.memoryActivateAction),
                      ),
                    OutlinedButton.icon(
                      key: Key('memory.edit.${fact.id}'),
                      onPressed: canUseActions ? onEdit : null,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.memoryEditAction),
                    ),
                    TextButton.icon(
                      key: Key('memory.delete.${fact.id}'),
                      onPressed: canUseActions ? onDelete : null,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(l10n.commonDelete),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _MemoryStatusBadge extends StatelessWidget {
  const _MemoryStatusBadge({required this.status});

  final MemoryStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (status) {
      MemoryStatus.candidate => (
        const Color(0xFFF4E9DA),
        const Color(0xFF795439),
        Icons.pending_actions_outlined,
      ),
      MemoryStatus.active => (
        const Color(0xFFE5ECE6),
        const Color(0xFF355F4B),
        Icons.check_circle_outline_rounded,
      ),
      MemoryStatus.inactive => (
        const Color(0xFFE9E7E1),
        const Color(0xFF5F625D),
        Icons.pause_circle_outline_rounded,
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: foreground),
            const SizedBox(width: 5),
            Text(
              _statusLabel(status, context.l10n),
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _ApproveMemoryDialog extends StatelessWidget {
  const _ApproveMemoryDialog({required this.fact});

  final MemoryFact fact;

  @override
  Widget build(BuildContext context) {
    final isSensitive = fact.sensitivity == MemorySensitivity.sensitive;
    return AlertDialog(
      scrollable: true,
      title: Text(
        isSensitive
            ? context.l10n.memoryApproveSensitiveTitle
            : context.l10n.memoryApproveRegularTitle,
      ),
      content: Text(
        isSensitive
            ? context.l10n.memoryApproveSensitiveBody
            : context.l10n.memoryApproveRegularBody,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('memory.approve.confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.commonApprove),
        ),
      ],
    );
  }
}

final class _EditMemoryDialog extends StatefulWidget {
  const _EditMemoryDialog({required this.initialFact});

  final String initialFact;

  @override
  State<_EditMemoryDialog> createState() => _EditMemoryDialogState();
}

final class _EditMemoryDialogState extends State<_EditMemoryDialog> {
  late final TextEditingController _controller;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialFact);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(
        () => _validationMessage = context.l10n.memoryEditValidationError,
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.l10n.memoryEditDialogTitle),
      content: TextField(
        key: const Key('memory.edit.field'),
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          labelText: context.l10n.memoryEditFieldLabel,
          errorText: _validationMessage,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('memory.edit.save'),
          onPressed: _save,
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}

final class _DeleteMemoryDialog extends StatelessWidget {
  const _DeleteMemoryDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.l10n.memoryDeleteDialogTitle),
      content: Text(context.l10n.memoryDeleteDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('memory.delete.confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.commonDelete),
        ),
      ],
    );
  }
}

String _statusLabel(MemoryStatus status, AppLocalizations l10n) {
  return l10n.memoryStatusLabel(status.name);
}

String _categoryLabel(MemoryCategory category, AppLocalizations l10n) {
  return l10n.memoryCategoryLabel(category.name);
}
