/// Check-in vs check-out action at the desk.
enum AttendanceAction { checkIn, checkOut }

/// How attendance was recorded at reception.
enum CheckInMethod { qr, phone }

/// Member resolved for attendance (mock / QR payload).
class ReceptionMemberResult {
  const ReceptionMemberResult({
    required this.memberId,
    required this.memberName,
    required this.plan,
    this.phone,
  });

  final String memberId;
  final String memberName;
  final String plan;
  final String? phone;
}

/// Result after toggling member attendance (check-in or check-out).
class AttendanceToggleResult {
  const AttendanceToggleResult({
    required this.member,
    required this.action,
    required this.timeLabel,
    required this.method,
    this.checkInTimeLabel,
  });

  final ReceptionMemberResult member;
  final AttendanceAction action;
  final String timeLabel;
  final CheckInMethod method;
  /// Set on check-out — when the member originally checked in.
  final String? checkInTimeLabel;
}

/// A log entry on the receptionist check-in hub.
class ReceptionCheckInRecord {
  const ReceptionCheckInRecord({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.timeLabel,
    required this.method,
    required this.action,
    this.phone,
    this.checkInTimeLabel,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String timeLabel;
  final CheckInMethod method;
  final AttendanceAction action;
  final String? phone;
  final String? checkInTimeLabel;

  String get methodLabel => method == CheckInMethod.qr ? 'QR' : 'Phone';

  String get actionLabel => action == AttendanceAction.checkIn ? 'IN' : 'OUT';

  ReceptionCheckInRecord copyWith({
    String? memberId,
    String? memberName,
    String? timeLabel,
    CheckInMethod? method,
    AttendanceAction? action,
    String? phone,
    String? checkInTimeLabel,
    bool clearCheckInTimeLabel = false,
  }) {
    return ReceptionCheckInRecord(
      id: id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      timeLabel: timeLabel ?? this.timeLabel,
      method: method ?? this.method,
      action: action ?? this.action,
      phone: phone ?? this.phone,
      checkInTimeLabel: clearCheckInTimeLabel ? null : (checkInTimeLabel ?? this.checkInTimeLabel),
    );
  }
}

/// Active gym session for a member (checked in, not yet out).
class ActiveMemberSession {
  const ActiveMemberSession({
    required this.memberId,
    required this.checkInTimeLabel,
    required this.checkedInAt,
  });

  final String memberId;
  final String checkInTimeLabel;
  /// Used for overstay alerts when checkout is missing (e.g. > 23 hours).
  final DateTime checkedInAt;
}
