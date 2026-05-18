import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/gym_member_profile.dart';
import '../../providers/reception_members_provider.dart';

/// Receptionist member directory with search.
class ReceptionMembersScreen extends ConsumerWidget {
  const ReceptionMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(filteredReceptionMembersProvider);
    final query = ref.watch(receptionMemberSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              onChanged: (v) => ref.read(receptionMemberSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search name, ID, phone, or email',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => ref.read(receptionMemberSearchProvider.notifier).state = '',
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${members.length} member${members.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: members.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        query.isEmpty
                            ? 'No members in this gym yet.'
                            : 'No members match "$query".',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: members.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _MemberListTile(member: members[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MemberListTile extends StatelessWidget {
  const _MemberListTile({required this.member});

  final GymMemberProfile member;

  @override
  Widget build(BuildContext context) {
    final active = member.isActive;
    return FitCoreCard(
      child: InkWell(
        onTap: () => context.push('/receptionist/members/${member.id}'),
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.2),
            child: Text(
              member.name.split(' ').map((e) => e[0]).take(2).join(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          title: Text(
            member.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          subtitle: Text(
            '${member.id} · ${member.plan} · Ends ${member.membershipEndsLabel}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusChip(label: member.status, active: active),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
