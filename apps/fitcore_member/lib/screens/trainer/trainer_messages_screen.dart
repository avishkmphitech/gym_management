import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../models/chat_message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/mock_ui_phase_provider.dart';

/// Trainer inbox — one thread per assigned member.
class TrainerMessagesScreen extends ConsumerWidget {
  const TrainerMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final threads = ref.watch(chatThreadSummariesForTrainerProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        title: const Text('Messages'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Assigned members only — no direct chat outside your roster.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText, height: 1.3),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
          ),
          Expanded(
            child: switch (phase) {
              MockUiPhase.loading => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                ),
              MockUiPhase.empty => Center(
                  child: Text(
                    'No member threads.',
                    style: GoogleFonts.inter(color: AppColors.secondaryText),
                  ),
                ),
              MockUiPhase.error => Center(
                  child: Text(
                    'Could not load messages.',
                    style: GoogleFonts.inter(color: AppColors.error),
                  ),
                ),
              MockUiPhase.filled => threads.isEmpty
                  ? Center(
                      child: Text(
                        'No assigned members to message.',
                        style: GoogleFonts.inter(color: AppColors.secondaryText),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: threads.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final t = threads[i];
                        return _ThreadTile(
                          thread: t,
                          onTap: () => context.push('/trainer/messages/${t.memberId}'),
                        );
                      },
                    ),
            },
          ),
        ],
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.onTap});

  final ChatThreadSummary thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: FitCoreCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondaryBg,
                child: Text(
                  thread.peerName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryText),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.peerName,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        if (thread.lastSentAt != null)
                          Text(
                            _relativeTime(thread.lastSentAt!),
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.lastPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: thread.unreadCount > 0
                            ? AppColors.primaryText
                            : AppColors.secondaryText,
                        fontWeight:
                            thread.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (thread.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${thread.unreadCount}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ] else
                const Icon(Icons.chevron_right, color: AppColors.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${t.day}/${t.month}';
  }
}
