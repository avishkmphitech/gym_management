/// Full gym member profile for receptionist management (mock data).
class GymMemberProfile {
  const GymMemberProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.plan,
    required this.membershipEnds,
    required this.status,
    required this.trainerName,
    required this.joinedOn,
    required this.lastCheckIn,
    required this.totalCheckIns,
    required this.emergencyContact,
    this.notes = '',
    this.gymId = 'apex-iron-01',
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String plan;
  final DateTime membershipEnds;
  final String status;
  final String trainerName;
  final String joinedOn;
  final String lastCheckIn;
  final int totalCheckIns;
  final String emergencyContact;
  final String notes;
  final String gymId;

  bool get isActive => membershipEnds.isAfter(DateTime.now());

  String get membershipEndsLabel {
    final d = membershipEnds;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  GymMemberProfile copyWith({
    String? plan,
    DateTime? membershipEnds,
    String? status,
  }) {
    return GymMemberProfile(
      id: id,
      name: name,
      email: email,
      phone: phone,
      plan: plan ?? this.plan,
      membershipEnds: membershipEnds ?? this.membershipEnds,
      status: status ?? this.status,
      trainerName: trainerName,
      joinedOn: joinedOn,
      lastCheckIn: lastCheckIn,
      totalCheckIns: totalCheckIns,
      emergencyContact: emergencyContact,
      notes: notes,
      gymId: gymId,
    );
  }
}

/// Membership plans receptionist can assign.
abstract final class GymMembershipPlans {
  static const options = [
    'Pro',
    'Standard',
    'Basic',
    'Athletic',
    'Yoga + strength',
  ];
}
