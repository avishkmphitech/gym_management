import 'package:flutter/material.dart';

import '../../providers/mock_ui_phase_provider.dart';
import '../tokens/app_colors.dart';

class PhaseChips extends StatelessWidget {
  const PhaseChips({
    super.key,
    required this.phase,
    required this.onChanged,
  });

  final MockUiPhase phase;
  final ValueChanged<MockUiPhase> onChanged;

  static const options = MockUiPhase.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in options) ...[
            ChoiceChip(
              label: Text(o.name),
              selected: phase == o,
              onSelected: (_) => onChanged(o),
              selectedColor: AppColors.primaryAccent.withValues(alpha: 0.35),
              labelStyle: TextStyle(
                color: phase == o ? AppColors.primaryText : AppColors.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              side: const BorderSide(color: AppColors.border),
              backgroundColor: AppColors.cardBg,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
