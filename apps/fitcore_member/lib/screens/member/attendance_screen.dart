import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../providers/member_identity.dart';
import '../../providers/member_provider.dart';
import '../../providers/reception_checkin_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/member_phase_viewport.dart';
import '../../widgets/role_guard.dart';

/// Member attendance — MEMBER role only ([RoleGuard]).
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  late DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  String get _memberId => ref.watch(memberReceptionIdProvider);

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(memberMonthAttendanceSummaryProvider(_visibleMonth));
    final calendarDays = ref.watch(memberCalendarDaysProvider(_visibleMonth));
    final logEntries = ref.watch(memberFormattedAttendanceLogProvider);
    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      fallback: const _AccessDenied(),
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'My Attendance',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                final now = DateTime.now();
                setState(() => _visibleMonth = DateTime(now.year, now.month));
              },
              icon: const Icon(Icons.today_outlined, color: AppColors.primaryText, size: 26),
              tooltip: 'Jump to today',
            ),
          ],
        ),
        body: MemberPhaseViewport(
          expandChild: true,
          emptyMessage: 'No attendance in this preview state.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _MonthSelectorRow(
                month: _visibleMonth,
                onPrev: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
              const SizedBox(height: 16),
              _SummaryRow(summary: summary),
              const SizedBox(height: 16),
              _AttendanceStatusBanner(memberId: _memberId),
              const SizedBox(height: 20),
              _AttendanceCalendar(visibleMonth: _visibleMonth, days: calendarDays),
              const SizedBox(height: 20),
              _QrAttendanceCard(
                memberId: _memberId,
                onGenerate: () => _showQrModal(context, _memberId),
              ),
              const SizedBox(height: 24),
              _LogSection(entries: logEntries),
            ],
          ),
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context, String memberId) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _QrModal(memberId: memberId),
    );
  }
}

class _AttendanceStatusBanner extends ConsumerWidget {
  const _AttendanceStatusBanner({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIn = ref.watch(memberCheckedInProvider(memberId));
    final session = ref.watch(activeMemberSessionProvider(memberId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isIn ? AppColors.success : AppColors.cardBg).withValues(alpha: isIn ? 0.12 : 1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isIn ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isIn ? Icons.place_rounded : Icons.home_outlined,
            color: isIn ? AppColors.success : AppColors.secondaryText,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isIn
                  ? 'You are checked in · since ${session?.checkInTimeLabel ?? '—'}. Show QR at exit to check out.'
                  : 'You are not checked in. Show QR at the desk to check in.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isIn ? AppColors.success : AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Center(
        child: Text(
          'Attendance is available for members only.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}

class _MonthSelectorRow extends StatelessWidget {
  const _MonthSelectorRow({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final label = '${_months[month.month - 1]} ${month.year}';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left, color: AppColors.primaryText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: AppColors.primaryText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final MemberMonthAttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            bg: const Color(0xFF1F3B2D),
            textColor: const Color(0xFF5A8F58),
            icon: '✓',
            label: 'Present',
            value: '${summary.present}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            bg: const Color(0xFF3B1F1F),
            textColor: const Color(0xFFA94A4A),
            icon: '✗',
            label: 'Absent',
            value: '${summary.absent}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            bg: const Color(0xFF2B2B2B),
            textColor: const Color(0xFFF5F5F2),
            icon: '∑',
            label: 'Total',
            value: '${summary.total}',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.bg,
    required this.textColor,
    required this.icon,
    required this.label,
    required this.value,
  });

  final Color bg;
  final Color textColor;
  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 18, color: textColor)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: textColor.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}

enum _DayCellKind { present, absent, today, future, rest }

class _AttendanceCalendar extends StatelessWidget {
  const _AttendanceCalendar({
    required this.visibleMonth,
    required this.days,
  });

  final DateTime visibleMonth;
  final List<MemberDayAttendance> days;

  static const _headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  _DayCellKind _kindForDay(int day) {
    final entry = days.firstWhere(
      (d) => d.date.day == day,
      orElse: () => MemberDayAttendance(date: DateTime(visibleMonth.year, visibleMonth.month, day), kind: 'future'),
    );
    switch (entry.kind) {
      case 'present':
        return _DayCellKind.present;
      case 'absent':
        return _DayCellKind.absent;
      case 'today':
        return _DayCellKind.today;
      case 'rest':
        return _DayCellKind.rest;
      default:
        return _DayCellKind.future;
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final startWeekday = first.weekday;
    final leading = startWeekday - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: _headers
              .map(
                (h) => Expanded(
                  child: Center(
                    child: Text(
                      h,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: const Color(0xFFB8B6B0),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        _CalendarWeekGrid(
          leading: leading,
          daysInMonth: daysInMonth,
          kindForDay: _kindForDay,
        ),
      ],
    );
  }
}

class _CalendarWeekGrid extends StatelessWidget {
  const _CalendarWeekGrid({
    required this.leading,
    required this.daysInMonth,
    required this.kindForDay,
  });

  final int leading;
  final int daysInMonth;
  final _DayCellKind Function(int day) kindForDay;

  @override
  Widget build(BuildContext context) {
    final cells = <int?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Column(
      children: [
        for (var row = 0; row < cells.length ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (col) {
                final day = cells[row * 7 + col];
                if (day == null) {
                  return const SizedBox(width: 40, height: 40);
                }
                return _DayCell(day: day, kind: kindForDay(day));
              }),
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.kind});

  final int day;
  final _DayCellKind kind;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BoxBorder? border;

    switch (kind) {
      case _DayCellKind.present:
        bg = const Color(0xFF3E7C59);
        fg = Colors.white;
        break;
      case _DayCellKind.absent:
        bg = const Color(0xFFA94A4A);
        fg = Colors.white;
        break;
      case _DayCellKind.today:
        bg = Colors.transparent;
        fg = const Color(0xFFF5F5F2);
        border = Border.all(color: const Color(0xFF3E7C59), width: 2);
        break;
      case _DayCellKind.future:
        bg = const Color(0xFF2B2B2B);
        fg = const Color(0xFF444444);
        break;
      case _DayCellKind.rest:
        bg = Colors.transparent;
        fg = const Color(0xFF444444);
        break;
    }

    return Center(
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: border,
        ),
        child: Text(
          '$day',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
        ),
      ),
    );
  }
}

class _QrAttendanceCard extends ConsumerWidget {
  const _QrAttendanceCard({required this.memberId, required this.onGenerate});

  final String memberId;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIn = ref.watch(memberCheckedInProvider(memberId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.qr_code_2_rounded, size: 48, color: Color(0xFF3E7C59)),
          const SizedBox(height: 12),
          Text(
            isIn ? 'Check out at your gym' : 'Check in at your gym',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 6),
          Text(
            isIn
                ? 'Show this QR at the desk when leaving — reception will check you out.'
                : 'Show this QR at the desk — reception will check you in.',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFB8B6B0)),
          ),
          const SizedBox(height: 16),
          FitCoreButton(
            label: isIn ? 'Generate QR (check out)' : 'Generate QR (check in)',
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }
}

class _QrModal extends ConsumerStatefulWidget {
  const _QrModal({required this.memberId});

  final String memberId;

  @override
  ConsumerState<_QrModal> createState() => _QrModalState();
}

class _QrModalState extends ConsumerState<_QrModal> {
  static const _duration = 60;
  int _remaining = _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= 1) {
        _timer?.cancel();
        setState(() => _remaining = 0);
        return;
      }
      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _timerColor {
    final t = _remaining / _duration;
    return Color.lerp(const Color(0xFF5A8F58), const Color(0xFFA94A4A), 1 - t)!;
  }

  @override
  Widget build(BuildContext context) {
    final isIn = ref.watch(memberCheckedInProvider(widget.memberId));

    return Dialog(
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: ReceptionMemberDirectory.qrPayloadFor(widget.memberId),
              size: 180,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              ref.watch(authServiceProvider)?.name ?? 'Member',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              'Member ID: ${widget.memberId}',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 8),
            Text(
              isIn ? 'Desk scan → check out' : 'Desk scan → check in',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isIn ? AppColors.secondaryAccent : AppColors.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Valid for $_remaining seconds',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _timerColor,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogSection extends StatelessWidget {
  const _LogSection({required this.entries});

  final List<MemberAttendanceDayLog> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "This Month's Log",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Text(
            'No attendance logged yet. Check in at the desk with your QR.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
          )
        else
        ...entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: e.completed ? const Color(0xFF1F3B2D) : const Color(0xFF2B2B2B),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    e.completed ? '✓' : '→',
                    style: TextStyle(
                      color: e.completed ? const Color(0xFF5A8F58) : AppColors.secondaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  e.title,
                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    e.subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText, height: 1.35),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B3B2B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    e.methodLabel,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF5A8F58)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
