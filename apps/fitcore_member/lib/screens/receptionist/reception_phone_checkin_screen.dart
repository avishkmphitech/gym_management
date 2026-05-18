import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/reception_checkin.dart';
import '../../providers/reception_checkin_provider.dart';
import '../../providers/reception_members_provider.dart';
import '../../models/gym_member_profile.dart';

GymMemberProfile? _findGymMemberByPhone(WidgetRef ref, String digits) {
  for (final m in ref.read(receptionMembersProvider)) {
    final phone = m.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.endsWith(digits) || phone == digits) return m;
  }
  return null;
}

/// Check in a member by registered mobile number (mock lookup).
class ReceptionPhoneCheckInScreen extends ConsumerStatefulWidget {
  const ReceptionPhoneCheckInScreen({super.key});

  @override
  ConsumerState<ReceptionPhoneCheckInScreen> createState() => _ReceptionPhoneCheckInScreenState();
}

class _ReceptionPhoneCheckInScreenState extends ConsumerState<ReceptionPhoneCheckInScreen> {
  final _phoneController = TextEditingController();
  ReceptionMemberResult? _foundMember;
  String? _errorText;
  bool _searching = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchMember() async {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      setState(() {
        _foundMember = null;
        _errorText = 'Enter at least 4 digits of the mobile number.';
      });
      return;
    }

    setState(() {
      _searching = true;
      _errorText = null;
      _foundMember = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final gymMember = _findGymMemberByPhone(ref, digits);
    setState(() {
      _searching = false;
      if (gymMember == null) {
        _errorText = 'No member found for this number.';
      } else {
        _foundMember = ReceptionMemberResult(
          memberId: gymMember.id,
          memberName: gymMember.name,
          plan: gymMember.plan,
          phone: gymMember.phone,
        );
      }
    });
  }

  void _confirmAttendance() {
    final member = _foundMember;
    if (member == null) return;

    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final result = ref.read(receptionAttendanceProvider.notifier).toggleAttendance(
          member,
          CheckInMethod.phone,
          phone: digits,
        );
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile lookup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Enter mobile number — confirms check-in if member is out, or check-out if already in gym.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _searchMember(),
            decoration: const InputDecoration(
              hintText: 'e.g. 98765 43210',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 16),
          FitCoreButton(
            label: _searching ? 'Searching…' : 'Find member',
            icon: Icons.search_rounded,
            onPressed: _searching ? null : _searchMember,
          ),
          const SizedBox(height: 24),
          if (_foundMember != null)
            _MemberConfirmCard(
              member: _foundMember!,
              isCheckedIn: ref.watch(memberCheckedInProvider(_foundMember!.memberId)),
              onConfirm: _confirmAttendance,
            ),
          const SizedBox(height: 24),
          Text('Sample numbers (mock)', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          ...ref.watch(receptionMembersProvider).map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FitCoreCard(
                child: ListTile(
                  dense: true,
                  title: Text(m.name, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text('${m.id} · ${m.phone}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryAccent),
                    onPressed: () {
                      _phoneController.text = m.phone;
                      _searchMember();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberConfirmCard extends ConsumerWidget {
  const _MemberConfirmCard({
    required this.member,
    required this.isCheckedIn,
    required this.onConfirm,
  });

  final ReceptionMemberResult member;
  final bool isCheckedIn;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeMemberSessionProvider(member.memberId));

    return FitCoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.2),
                child: Text(
                  member.memberName.split(' ').map((e) => e[0]).take(2).join(),
                  style: const TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.memberName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
                    ),
                    Text(
                      '${member.memberId} · ${member.plan} plan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (member.phone != null)
                      Text(member.phone!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (isCheckedIn ? AppColors.secondaryAccent : AppColors.success).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isCheckedIn
                  ? 'Currently checked in since ${session?.checkInTimeLabel ?? '—'}. Next action: check out.'
                  : 'Not in gym. Next action: check in.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCheckedIn ? AppColors.secondaryAccent : AppColors.success,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          FitCoreButton(
            label: isCheckedIn ? 'Confirm check-out' : 'Confirm check-in',
            icon: isCheckedIn ? Icons.logout_rounded : Icons.how_to_reg_rounded,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
