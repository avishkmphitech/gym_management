import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/member_identity.dart';
import '../../providers/member_provider.dart';
import '../shared/trainer_member_chat_screen.dart';

/// Member → assigned trainer chat (resolves roster id from signed-in user).
class MemberTrainerChatScreen extends ConsumerWidget {
  const MemberTrainerChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canChat = ref.watch(memberCanUseChatProvider);
    if (!canChat) {
      return Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          title: const Text('Trainer messages'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You do not have an assigned trainer yet.\nMessaging opens once a trainer is assigned to you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.secondaryText, height: 1.45),
            ),
          ),
        ),
      );
    }

    final memberId = ref.watch(memberTrainerIdProvider);
    final membership = ref.watch(memberMembershipProvider);

    return TrainerMemberChatScreen(
      memberId: memberId,
      peerName: membership.trainerName,
    );
  }
}
