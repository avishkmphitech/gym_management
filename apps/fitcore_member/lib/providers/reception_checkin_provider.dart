import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reception_checkin.dart';

/// Mock member directory for QR payloads and phone lookup.
abstract final class ReceptionMemberDirectory {
  static const defaultMemberId = 'M-20481';

  static const members = <ReceptionMemberResult>[
    ReceptionMemberResult(
      memberId: 'M-20481',
      memberName: 'Aarav Khanna',
      plan: 'Pro',
      phone: '9876543210',
    ),
    ReceptionMemberResult(
      memberId: 'M-20102',
      memberName: 'Priya Shah',
      plan: 'Standard',
      phone: '9123456780',
    ),
    ReceptionMemberResult(
      memberId: 'M-19877',
      memberName: 'Rahul Sharma',
      plan: 'Pro',
      phone: '9988776655',
    ),
  ];

  static String qrPayloadFor(String memberId) => 'fitcore:attendance:$memberId';

  static ReceptionMemberResult? byMemberId(String id) {
    for (final m in members) {
      if (m.memberId == id) return m;
    }
    return null;
  }

  static ReceptionMemberResult? byPhoneDigits(String digits) {
    if (digits.length < 4) return null;
    for (final m in members) {
      final phone = m.phone?.replaceAll(RegExp(r'\D'), '') ?? '';
      if (phone.endsWith(digits) || phone == digits) return m;
    }
    return null;
  }

  static ReceptionMemberResult? fromQrValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final attendance = RegExp(r'fitcore:attendance:(M-\d+)', caseSensitive: false).firstMatch(value);
    if (attendance != null) {
      return byMemberId(attendance.group(1)!);
    }

    final legacy = RegExp(r'fitcore:checkin:(M-\d+)', caseSensitive: false).firstMatch(value);
    if (legacy != null) {
      return byMemberId(legacy.group(1)!);
    }

    final idOnly = RegExp(r'M-\d+').firstMatch(value);
    if (idOnly != null) {
      return byMemberId(idOnly.group(0)!);
    }

    return null;
  }

  static String memberIdForMemberUser(String? userName) {
    if (userName == null) return defaultMemberId;
    final lower = userName.toLowerCase();
    for (final m in members) {
      if (lower.contains(m.memberName.split(' ').first.toLowerCase())) {
        return m.memberId;
      }
    }
    return defaultMemberId;
  }
}

class ReceptionAttendanceState {
  const ReceptionAttendanceState({
    required this.log,
    required this.activeSessions,
  });

  final List<ReceptionCheckInRecord> log;
  final Map<String, ActiveMemberSession> activeSessions;

  bool isCheckedIn(String memberId) => activeSessions.containsKey(memberId);
}

class ReceptionCheckInNotifier extends StateNotifier<ReceptionAttendanceState> {
  ReceptionCheckInNotifier()
      : super(
          ReceptionAttendanceState(
            log: const [
              ReceptionCheckInRecord(
                id: 'log_seed_1',
                memberId: 'M-20481',
                memberName: 'Aarav Khanna',
                timeLabel: '6:42 AM',
                method: CheckInMethod.qr,
                action: AttendanceAction.checkIn,
              ),
              ReceptionCheckInRecord(
                id: 'log_seed_2',
                memberId: 'M-20102',
                memberName: 'Priya Shah',
                timeLabel: '6:38 AM',
                method: CheckInMethod.phone,
                action: AttendanceAction.checkIn,
                phone: '9123456780',
              ),
            ],
            activeSessions: {
              'M-20481': ActiveMemberSession(
                memberId: 'M-20481',
                checkInTimeLabel: 'Yesterday · 7:00 AM',
                checkedInAt: DateTime.now().subtract(const Duration(hours: 25)),
              ),
              'M-20102': ActiveMemberSession(
                memberId: 'M-20102',
                checkInTimeLabel: 'Today · 6:38 AM',
                checkedInAt: DateTime.now().subtract(const Duration(hours: 2)),
              ),
            },
          ),
        );

  int _logCounter = 100;

  String _newLogId() => 'log_${_logCounter++}_${DateTime.now().millisecondsSinceEpoch}';

  static String formatTimeNow() {
    final now = DateTime.now();
    return formatTimeOfDay(TimeOfDay(hour: now.hour, minute: now.minute));
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  static TimeOfDay? parseTimeLabel(String label) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false).firstMatch(label.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final isPm = match.group(3)!.toUpperCase() == 'PM';
    if (hour == 12) {
      hour = isPm ? 12 : 0;
    } else if (isPm) {
      hour += 12;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static Map<String, ActiveMemberSession> deriveActiveSessions(List<ReceptionCheckInRecord> log) {
    final sessions = <String, ActiveMemberSession>{};
    for (final entry in log.reversed) {
      if (entry.action == AttendanceAction.checkIn) {
        sessions[entry.memberId] = ActiveMemberSession(
          memberId: entry.memberId,
          checkInTimeLabel: entry.timeLabel,
          checkedInAt: parseTimeLabel(entry.timeLabel) != null
              ? _dateTimeFromTodayTime(parseTimeLabel(entry.timeLabel)!)
              : DateTime.now(),
        );
      } else {
        sessions.remove(entry.memberId);
      }
    }
    return sessions;
  }

  static DateTime _dateTimeFromTodayTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  void _applyLog(List<ReceptionCheckInRecord> log) {
    state = ReceptionAttendanceState(
      log: log,
      activeSessions: deriveActiveSessions(log),
    );
  }

  AttendanceToggleResult toggleAttendance(
    ReceptionMemberResult member,
    CheckInMethod method, {
    String? phone,
  }) {
    final time = formatTimeNow();
    final isIn = state.isCheckedIn(member.memberId);

    if (isIn) {
      final session = state.activeSessions[member.memberId]!;
      final record = ReceptionCheckInRecord(
        id: _newLogId(),
        memberId: member.memberId,
        memberName: member.memberName,
        timeLabel: time,
        method: method,
        action: AttendanceAction.checkOut,
        phone: phone,
        checkInTimeLabel: session.checkInTimeLabel,
      );
      _applyLog([record, ...state.log]);
      return AttendanceToggleResult(
        member: member,
        action: AttendanceAction.checkOut,
        timeLabel: time,
        method: method,
        checkInTimeLabel: session.checkInTimeLabel,
      );
    }

    final record = ReceptionCheckInRecord(
      id: _newLogId(),
      memberId: member.memberId,
      memberName: member.memberName,
      timeLabel: time,
      method: method,
      action: AttendanceAction.checkIn,
      phone: phone,
    );
    // checkedInAt stored on active session below via deriveActiveSessions
    _applyLog([record, ...state.log]);
    return AttendanceToggleResult(
      member: member,
      action: AttendanceAction.checkIn,
      timeLabel: time,
      method: method,
    );
  }

  void updateLogEntry(ReceptionCheckInRecord updated) {
    final log = [
      for (final e in state.log)
        if (e.id == updated.id) updated else e,
    ];
    _applyLog(log);
  }

  void deleteLogEntry(String id) {
    _applyLog(state.log.where((e) => e.id != id).toList());
  }

  ReceptionCheckInRecord? logById(String id) {
    for (final e in state.log) {
      if (e.id == id) return e;
    }
    return null;
  }
}

final receptionAttendanceProvider =
    StateNotifierProvider<ReceptionCheckInNotifier, ReceptionAttendanceState>(
  (ref) => ReceptionCheckInNotifier(),
);

final receptionCheckInsProvider = Provider<List<ReceptionCheckInRecord>>(
  (ref) => ref.watch(receptionAttendanceProvider).log,
);

final memberCheckedInProvider = Provider.family<bool, String>(
  (ref, memberId) => ref.watch(receptionAttendanceProvider).isCheckedIn(memberId),
);

final activeMemberSessionProvider = Provider.family<ActiveMemberSession?, String>(
  (ref, memberId) => ref.watch(receptionAttendanceProvider).activeSessions[memberId],
);
