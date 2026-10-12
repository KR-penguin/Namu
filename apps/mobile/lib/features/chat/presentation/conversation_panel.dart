import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/presentation/gateway_failure_message.dart';
import '../../../l10n/namu_localizations.dart';
import '../../media/presentation/local_photo.dart';
import '../../persona/domain/ai_persona.dart';
import '../../persona/presentation/persona_avatar.dart';
import '../application/chat_controller.dart';
import '../domain/message.dart';

class ConversationPanel extends StatefulWidget {
  const ConversationPanel({
    required this.controller,
    required this.persona,
    required this.gatewayConfigured,
    this.aiRequestsAllowed = true,
    required this.onShowDiary,
    this.onAttachPhoto,
    this.onEditPersona,
    this.photoBytesLoader,
    super.key,
  });

  final ChatController controller;
  final AiPersona persona;
  final bool gatewayConfigured;
  final bool aiRequestsAllowed;
  final VoidCallback onShowDiary;
  final VoidCallback? onAttachPhoto;
  final VoidCallback? onEditPersona;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  State<ConversationPanel> createState() => _ConversationPanelState();
}

class _ConversationPanelState extends State<ConversationPanel> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadMessages());
      }
    });
  }

  @override
  void didUpdateWidget(covariant ConversationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_loadMessages());
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      await widget.controller.load();
    } catch (_) {
      if (mounted) {
        _showFailure(context.l10n.chatLoadError);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty || widget.controller.isSending) {
      return;
    }

    _composerController.clear();
    try {
      await widget.controller.sendText(text);
    } catch (error) {
      if (mounted) {
        _showFailure(
          gatewayFailureMessage(
            error,
            operation: AiGatewayOperation.chatReply,
            l10n: context.l10n,
          ),
        );
      }
    }
  }

  Future<void> _retryMessage(Message message) async {
    try {
      await widget.controller.retryFailed(message.id);
    } catch (error) {
      if (mounted) {
        _showFailure(
          gatewayFailureMessage(
            error,
            operation: AiGatewayOperation.chatReply,
            l10n: context.l10n,
          ),
        );
      }
    }
  }

  void _showFailure(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _scrollToEnd() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _attachPhoto() {
    final onAttachPhoto = widget.onAttachPhoto;
    if (onAttachPhoto != null) {
      onAttachPhoto();
      return;
    }
    _showFailure(context.l10n.chatPhotoPickerUnavailable);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = widget.controller;

    return ColoredBox(
      key: const Key('conversation.live.panel'),
      color: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _ProfileHeader(
              persona: widget.persona,
              gatewayConfigured: widget.gatewayConfigured,
              aiRequestsAllowed: widget.aiRequestsAllowed,
              onEditPersona: widget.onEditPersona,
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Expanded(
              child: _ConversationBody(
                controller: controller,
                persona: widget.persona,
                scrollController: _scrollController,
                onRetry: (message) => unawaited(_retryMessage(message)),
                photoBytesLoader: widget.photoBytesLoader,
              ),
            ),
            _DiaryCallToAction(onPressed: widget.onShowDiary),
            _Composer(
              controller: _composerController,
              isSending: controller.isSending,
              onAttach: _attachPhoto,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationBody extends StatelessWidget {
  const _ConversationBody({
    required this.controller,
    required this.persona,
    required this.scrollController,
    required this.onRetry,
    required this.photoBytesLoader,
  });

  final ChatController controller;
  final AiPersona persona;
  final ScrollController scrollController;
  final ValueChanged<Message> onRetry;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (controller.messages.isEmpty) {
      return const _EmptyConversation();
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      children: [
        const _DayDivider(),
        const SizedBox(height: 18),
        for (var index = 0; index < controller.messages.length; index++) ...[
          _MessageBubble(
            message: controller.messages[index],
            persona: persona,
            onRetry: onRetry,
            photoBytesLoader: photoBytesLoader,
          ),
          if (index != controller.messages.length - 1)
            const SizedBox(height: 12),
        ],
        if (controller.isSending) ...[
          const SizedBox(height: 12),
          const _TypingIndicator(),
        ],
      ],
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                color: colors.onPrimaryContainer,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              context.l10n.chatPrompt,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.chatLocalFirstBody,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.persona,
    required this.gatewayConfigured,
    required this.aiRequestsAllowed,
    required this.onEditPersona,
  });

  final AiPersona persona;
  final bool gatewayConfigured;
  final bool aiRequestsAllowed;
  final VoidCallback? onEditPersona;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          PersonaAvatar(
            key: const Key('conversation.avatar.header'),
            avatarSeed: persona.avatarSeed,
            semanticLabel: context.l10n.chatAiFriendProfileSemantics(
              persona.name,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  persona.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  !gatewayConfigured
                      ? context.l10n.chatGatewaySetupNeeded
                      : aiRequestsAllowed
                      ? context.l10n.chatAiReady
                      : context.l10n.chatConsentNeeded,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ConnectionBadge(
            configured: gatewayConfigured,
            allowed: aiRequestsAllowed,
          ),
          IconButton(
            tooltip: context.l10n.chatPersonaSettingsTooltip,
            onPressed: onEditPersona,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.configured, required this.allowed});

  final bool configured;
  final bool allowed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ready = configured && allowed;
    final background = ready ? colors.primaryContainer : colors.errorContainer;
    final foreground = ready
        ? colors.onPrimaryContainer
        : colors.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        !configured
            ? context.l10n.chatConnectionBadgeNeedsSetup
            : allowed
            ? context.l10n.chatConnectionBadgeReady
            : context.l10n.chatConnectionBadgeNeedsConsent,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.l10n.chatTodayDivider,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant)),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.persona,
    required this.onRetry,
    required this.photoBytesLoader,
  });

  final Message message;
  final AiPersona persona;
  final ValueChanged<Message> onRetry;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    return switch (message.role) {
      MessageRole.user => _UserMessage(
        message: message,
        onRetry: () => onRetry(message),
        photoBytesLoader: photoBytesLoader,
      ),
      MessageRole.assistant => _AssistantMessage(
        message: message,
        persona: persona,
        photoBytesLoader: photoBytesLoader,
      ),
    };
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({
    required this.message,
    required this.persona,
    required this.photoBytesLoader,
  });

  final Message message;
  final AiPersona persona;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      key: const Key('conversation.message.assistant'),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PersonaAvatar(
            key: const Key('conversation.avatar.assistant'),
            avatarSeed: persona.avatarSeed,
            size: 26,
            semanticLabel: context.l10n.chatPersonaProfileSemantics(
              persona.name,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: _MessageSurface(
              color: colors.surfaceContainerHighest,
              foregroundColor: colors.onSurface,
              text: message.text,
              photoAssetId: message.photoAssetId,
              photoBytesLoader: photoBytesLoader,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({
    required this.message,
    required this.onRetry,
    required this.photoBytesLoader,
  });

  final Message message;
  final VoidCallback onRetry;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final failed = message.status == MessageStatus.failed;

    return Align(
      key: const Key('conversation.message.user'),
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _MessageSurface(
              color: failed ? colors.errorContainer : colors.primary,
              foregroundColor: failed
                  ? colors.onErrorContainer
                  : colors.onPrimary,
              text: message.text,
              photoAssetId: message.photoAssetId,
              photoBytesLoader: photoBytesLoader,
            ),
            if (failed) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.chatReplyFailed,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    key: const Key('conversation.message.retry'),
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(48, 32),
                    ),
                    child: Text(context.l10n.commonRetry),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageSurface extends StatelessWidget {
  const _MessageSurface({
    required this.color,
    required this.foregroundColor,
    required this.text,
    required this.photoAssetId,
    required this.photoBytesLoader,
  });

  final Color color;
  final Color foregroundColor;
  final String? text;
  final String? photoAssetId;
  final LocalPhotoBytesLoader? photoBytesLoader;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoAssetId != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 220,
                  height: 164,
                  child: LocalPhoto(
                    assetId: photoAssetId!,
                    loadBytes: photoBytesLoader,
                    cacheWidth: 720,
                    backgroundColor: foregroundColor.withValues(alpha: 0.12),
                    foregroundColor: foregroundColor,
                  ),
                ),
              ),
              if (text != null) const SizedBox(height: 7),
            ],
            if (text != null)
              Text(
                text!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: foregroundColor, height: 1.35),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: context.l10n.chatTypingSemantics,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DiaryCallToAction extends StatelessWidget {
  const _DiaryCallToAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: colors.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: const Key('conversation.openDiary'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_outlined,
                  size: 20,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.chatOpenDiary,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onAttach,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: context.l10n.chatAttachPhotoTooltip,
              onPressed: isSending ? null : onAttach,
              icon: const Icon(Icons.add_photo_alternate_outlined),
            ),
            Expanded(
              child: TextField(
                key: const Key('conversation.composer.field'),
                controller: controller,
                enabled: !isSending,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: context.l10n.chatPrompt,
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              tooltip: context.l10n.chatSendMessageTooltip,
              onPressed: isSending ? null : onSend,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
