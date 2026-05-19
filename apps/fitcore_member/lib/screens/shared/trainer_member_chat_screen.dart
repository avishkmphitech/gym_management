import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../services/auth_service.dart';

/// Shared member ↔ trainer conversation (one thread per roster member id).
class TrainerMemberChatScreen extends ConsumerStatefulWidget {
  const TrainerMemberChatScreen({
    super.key,
    required this.memberId,
    this.peerName,
  });

  final String memberId;
  final String? peerName;

  @override
  ConsumerState<TrainerMemberChatScreen> createState() => _TrainerMemberChatScreenState();
}

class _TrainerMemberChatScreenState extends ConsumerState<TrainerMemberChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  var _openedMarkedRead = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _peerName(bool isTrainer) {
    if (widget.peerName != null) return widget.peerName!;
    if (isTrainer) {
      return ref.read(trainerProvider).memberById(widget.memberId)?.name ?? 'Member';
    }
    return ref.read(memberMembershipProvider).trainerName;
  }

  void _markReadAndScroll(bool isTrainer) {
    ref.read(chatProvider.notifier).markRead(widget.memberId, viewerIsTrainer: isTrainer);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _send(bool isTrainer) {
    if (!_canAccess(isTrainer)) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).send(
          memberId: widget.memberId,
          body: text,
          fromTrainer: isTrainer,
        );
    _controller.clear();
    _scrollToBottom();
  }

  bool _canAccess(bool isTrainer) {
    if (isTrainer) {
      return ref.watch(trainerCanChatWithMemberProvider(widget.memberId));
    }
    return ref.watch(memberCanAccessChatThreadProvider(widget.memberId));
  }

  @override
  Widget build(BuildContext context) {
    final isTrainer = ref.watch(authServiceProvider)?.role == 'TRAINER';
    final canAccess = _canAccess(isTrainer);

    if (!canAccess) {
      return Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          title: const Text('Messages'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isTrainer
                  ? 'You can only message members assigned to you.'
                  : 'Messaging is only available with your assigned trainer.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.secondaryText, height: 1.45),
            ),
          ),
        ),
      );
    }

    final messages = ref.watch(chatMessagesProvider(widget.memberId));
    final peer = _peerName(isTrainer);

    if (!_openedMarkedRead) {
      _openedMarkedRead = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _markReadAndScroll(isTrainer));
    }

    ref.listen(chatMessagesProvider(widget.memberId), (prev, next) {
      if (next.length != (prev?.length ?? 0)) {
        ref.read(chatProvider.notifier).markRead(widget.memberId, viewerIsTrainer: isTrainer);
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(peer, style: const TextStyle(fontSize: 17)),
            Text(
              isTrainer ? 'Member chat' : 'Your trainer',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Say hello to $peer.\nPlan questions and check-ins stay here.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.secondaryText, height: 1.45),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _ChatBubble(
                      message: messages[i],
                      isMine: isTrainer
                          ? messages[i].isFromTrainer
                          : messages[i].isFromMember,
                    ),
                  ),
          ),
          _Composer(
            controller: _controller,
            onSend: () => _send(isTrainer),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMine ? AppColors.primaryAccent : AppColors.cardBg;
    final textColor = isMine ? Colors.white : AppColors.primaryText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              border: isMine ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              message.body,
              style: GoogleFonts.inter(fontSize: 14, color: textColor, height: 1.35),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _timeLabel(message.sentAt),
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ap = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: AppColors.secondaryBg,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(color: AppColors.primaryText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: GoogleFonts.inter(color: AppColors.secondaryText),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryAccent),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primaryAccent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onSend,
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
