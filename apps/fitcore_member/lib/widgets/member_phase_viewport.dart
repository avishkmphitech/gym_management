import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/phase_chips.dart';
import '../providers/mock_ui_phase_provider.dart';

/// Dev/prototype UI states — [child] is unchanged when phase is [MockUiPhase.filled].
class MemberPhaseViewport extends ConsumerWidget {
  const MemberPhaseViewport({
    super.key,
    required this.child,
    this.emptyMessage = 'Nothing to show in this view.',
    this.errorMessage = 'Could not load this screen.',
    this.showPhaseChips = true,
    this.expandChild = true,
  });

  final Widget child;
  final String emptyMessage;
  final String errorMessage;
  final bool showPhaseChips;
  final bool expandChild;

  Widget _phaseBody(MockUiPhase phase) {
    return switch (phase) {
      MockUiPhase.loading => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
      MockUiPhase.empty => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(emptyMessage, textAlign: TextAlign.center),
          ),
        ),
      MockUiPhase.error => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(errorMessage, textAlign: TextAlign.center),
          ),
        ),
      MockUiPhase.filled => child,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final body = _phaseBody(phase);

    if (!showPhaseChips) {
      return expandChild ? Expanded(child: body) : body;
    }

    final chips = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: PhaseChips(
        phase: phase,
        onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
      ),
    );

    if (expandChild) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chips,
          Expanded(child: body),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        chips,
        body,
      ],
    );
  }
}
