import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gym_member_profile.dart';

final _initialMembers = [
  GymMemberProfile(
    id: 'M-20481',
    name: 'Aarav Khanna',
    email: 'aarav.k@email.com',
    phone: '9876543210',
    plan: 'Pro',
    membershipEnds: DateTime(2026, 8, 15),
    status: 'Active',
    trainerName: 'Coach Riya',
    joinedOn: 'Jan 12, 2025',
    lastCheckIn: 'Today · 6:42 AM',
    totalCheckIns: 142,
    emergencyContact: 'Priya Khanna · 9876500001',
    notes: 'Prefers morning slots.',
  ),
  GymMemberProfile(
    id: 'M-20102',
    name: 'Priya Shah',
    email: 'priya.shah@email.com',
    phone: '9123456780',
    plan: 'Standard',
    membershipEnds: DateTime(2026, 6, 30),
    status: 'Active',
    trainerName: 'Coach Arjun',
    joinedOn: 'Mar 3, 2025',
    lastCheckIn: 'Today · 6:38 AM',
    totalCheckIns: 98,
    emergencyContact: 'Rohan Shah · 9123400002',
  ),
  GymMemberProfile(
    id: 'M-19877',
    name: 'Rahul Sharma',
    email: 'rahul.s@email.com',
    phone: '9988776655',
    plan: 'Pro',
    membershipEnds: DateTime(2026, 5, 20),
    status: 'Active',
    trainerName: 'Coach Riya',
    joinedOn: 'Nov 8, 2024',
    lastCheckIn: 'Yesterday · 7:10 PM',
    totalCheckIns: 210,
    emergencyContact: 'Sunita Sharma · 9988700003',
  ),
  GymMemberProfile(
    id: 'M-21004',
    name: 'Meera Shah',
    email: 'meera.s@email.com',
    phone: '9012345678',
    plan: 'Yoga + strength',
    membershipEnds: DateTime(2026, 4, 1),
    status: 'Expiring soon',
    trainerName: 'Coach Riya',
    joinedOn: 'Feb 18, 2025',
    lastCheckIn: 'May 16 · 6:55 AM',
    totalCheckIns: 76,
    emergencyContact: 'Anil Shah · 9012300004',
  ),
  GymMemberProfile(
    id: 'M-21110',
    name: 'Dev Malhotra',
    email: 'dev.m@email.com',
    phone: '9090909090',
    plan: 'Athletic',
    membershipEnds: DateTime(2025, 12, 1),
    status: 'Expired',
    trainerName: 'Coach Arjun',
    joinedOn: 'Aug 22, 2024',
    lastCheckIn: 'May 9 · 7:05 AM',
    totalCheckIns: 54,
    emergencyContact: 'Kiran Malhotra · 9090900005',
  ),
];

class ReceptionMembersNotifier extends StateNotifier<List<GymMemberProfile>> {
  ReceptionMembersNotifier() : super(List.of(_initialMembers));

  GymMemberProfile? byId(String id) {
    for (final m in state) {
      if (m.id == id) return m;
    }
    return null;
  }

  void updateMembership({
    required String memberId,
    required String plan,
    required DateTime membershipEnds,
  }) {
    state = [
      for (final m in state)
        if (m.id == memberId)
          m.copyWith(
            plan: plan,
            membershipEnds: membershipEnds,
            status: membershipEnds.isAfter(DateTime.now()) ? 'Active' : 'Expired',
          )
        else
          m,
    ];
  }
}

final receptionMembersProvider =
    StateNotifierProvider<ReceptionMembersNotifier, List<GymMemberProfile>>(
  (ref) => ReceptionMembersNotifier(),
);

final receptionMemberSearchProvider = StateProvider<String>((ref) => '');

final filteredReceptionMembersProvider = Provider<List<GymMemberProfile>>((ref) {
  final query = ref.watch(receptionMemberSearchProvider).trim().toLowerCase();
  final members = ref.watch(receptionMembersProvider);
  if (query.isEmpty) return members;

  return members.where((m) {
    final phoneDigits = m.phone.replaceAll(RegExp(r'\D'), '');
    final qDigits = query.replaceAll(RegExp(r'\D'), '');
    return m.name.toLowerCase().contains(query) ||
        m.id.toLowerCase().contains(query) ||
        m.email.toLowerCase().contains(query) ||
        (qDigits.isNotEmpty && phoneDigits.contains(qDigits));
  }).toList();
});

final receptionMemberByIdProvider = Provider.family<GymMemberProfile?, String>((ref, id) {
  for (final m in ref.watch(receptionMembersProvider)) {
    if (m.id == id) return m;
  }
  return null;
});
