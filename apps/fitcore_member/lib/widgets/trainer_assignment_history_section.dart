import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_card.dart';
import '../providers/trainer_provider.dart';

/// Recent workout/diet assignments (trainer Plans tab).
class TrainerAssignmentHistorySection extends ConsumerWidget {
  const TrainerAssignmentHistorySection({super.key, this.type});

  /// When set, filters to `workout` or `diet`.
  final String? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(trainerProvider).assignmentHistory;
    final filtered = type == null ? history : history.where((a) => a.type == type).toList();

    if (filtered.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = filtered.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent assignments', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        FitCoreCard(
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(height: 20, color: AppColors.border),
                Row(
                  children: [
                    Icon(
                      items[i].type == 'diet'
                          ? Icons.restaurant_outlined
                          : Icons.calendar_view_week_outlined,
                      color: AppColors.secondaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i].planName,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${items[i].memberName} · ${items[i].assignedAtLabel}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
