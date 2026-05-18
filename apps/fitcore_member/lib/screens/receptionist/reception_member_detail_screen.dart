import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/gym_member_profile.dart';
import '../../providers/reception_members_provider.dart';

/// Full member profile; receptionist can update plan and membership end date.
class ReceptionMemberDetailScreen extends ConsumerStatefulWidget {
  const ReceptionMemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  ConsumerState<ReceptionMemberDetailScreen> createState() => _ReceptionMemberDetailScreenState();
}

class _ReceptionMemberDetailScreenState extends ConsumerState<ReceptionMemberDetailScreen> {
  String? _selectedPlan;
  DateTime? _membershipEnds;
  bool _dirty = false;

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(receptionMemberByIdProvider(widget.memberId));

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member')),
        body: Center(
          child: Text('Member not found.', style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }

    final plan = _selectedPlan ?? member.plan;
    final ends = _membershipEnds ?? member.membershipEnds;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FitCoreCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.2),
                  child: Text(
                    member.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(member.id, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      _StatusBadge(active: ends.isAfter(DateTime.now()), status: member.status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Contact'),
          FitCoreCard(
            child: Column(
              children: [
                _DetailRow(label: 'Phone', value: member.phone, icon: Icons.phone_outlined),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(label: 'Email', value: member.email, icon: Icons.email_outlined),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(
                  label: 'Emergency',
                  value: member.emergencyContact,
                  icon: Icons.emergency_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Membership (editable)'),
          FitCoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Plan', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(plan),
                  initialValue: plan,
                  items: [
                    for (final p in GymMembershipPlans.options)
                      DropdownMenuItem(value: p, child: Text(p)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _selectedPlan = v;
                      _dirty = true;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Membership ends', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickEndDate(context, ends),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(endsLabel(ends)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryText,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  ends.isAfter(DateTime.now())
                      ? 'Member can check in until end of this date.'
                      : 'Membership has expired. Update the end date to reactivate.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: 'Gym & activity'),
          FitCoreCard(
            child: Column(
              children: [
                _DetailRow(label: 'Gym ID', value: member.gymId, icon: Icons.fitness_center_outlined),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(label: 'Trainer', value: member.trainerName, icon: Icons.person_outline),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(label: 'Joined', value: member.joinedOn, icon: Icons.event_outlined),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(label: 'Last check-in', value: member.lastCheckIn, icon: Icons.login_rounded),
                const Divider(height: 1, color: AppColors.border),
                _DetailRow(
                  label: 'Total check-ins',
                  value: '${member.totalCheckIns}',
                  icon: Icons.fact_check_outlined,
                ),
              ],
            ),
          ),
          if (member.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionTitle(title: 'Notes'),
            FitCoreCard(
              child: Text(member.notes, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
          const SizedBox(height: 24),
          FitCoreButton(
            label: _dirty ? 'Save membership changes' : 'Membership up to date',
            icon: Icons.save_outlined,
            onPressed: _dirty
                ? () {
                    ref.read(receptionMembersProvider.notifier).updateMembership(
                          memberId: member.id,
                          plan: plan,
                          membershipEnds: ends,
                        );
                    setState(() => _dirty = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated ${member.name}\'s membership')),
                    );
                  }
                : null,
          ),
          const SizedBox(height: 12),
          FitCoreButton(
            label: 'Check in member',
            variant: FitCoreButtonVariant.secondary,
            icon: Icons.how_to_reg_outlined,
            onPressed: () => context.push('/receptionist/checkin/phone'),
          ),
        ],
      ),
    );
  }

  String endsLabel(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _pickEndDate(BuildContext context, DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Membership end date',
    );
    if (picked != null) {
      setState(() {
        _membershipEnds = picked;
        _dirty = true;
      });
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primaryText),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.secondaryAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active, required this.status});

  final bool active;
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
