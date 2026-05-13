import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../widgets/role_guard.dart';

/// Member attendance — MEMBER role only ([RoleGuard]).
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _visibleMonth = DateTime(2026, 6);

  void _shiftMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  static final DateTime _mockToday = DateTime(2026, 6, 13);

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {},
              icon: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryText, size: 26),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _MonthSelectorRow(
              month: _visibleMonth,
              onPrev: () => _shiftMonth(-1),
              onNext: () => _shiftMonth(1),
            ),
            const SizedBox(height: 16),
            const _SummaryRow(),
            const SizedBox(height: 20),
            _AttendanceCalendar(visibleMonth: _visibleMonth, mockToday: _mockToday),
            const SizedBox(height: 20),
            _QrCheckInCard(onGenerate: () => _showQrModal(context)),
            const SizedBox(height: 24),
            const _LogSection(),
          ],
        ),
      ),
    );
  }

  void _showQrModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _QrModal(),
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
  const _SummaryRow();

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
            value: '18',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            bg: const Color(0xFF3B1F1F),
            textColor: const Color(0xFFA94A4A),
            icon: '✗',
            label: 'Absent',
            value: '8',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            bg: const Color(0xFF2B2B2B),
            textColor: const Color(0xFFF5F5F2),
            icon: '∑',
            label: 'Total',
            value: '26',
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
    required this.mockToday,
  });

  final DateTime visibleMonth;
  final DateTime mockToday;

  static const _headers = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  _DayCellKind _kindForDay(int day) {
    final dt = DateTime(visibleMonth.year, visibleMonth.month, day);
    final wd = dt.weekday;

    if (visibleMonth.year != 2026 || visibleMonth.month != 6) {
      if (dt.isAfter(mockToday)) return _DayCellKind.future;
      if (wd == DateTime.saturday || wd == DateTime.sunday) return _DayCellKind.rest;
      return _DayCellKind.present;
    }

    if (_sameDate(dt, mockToday)) return _DayCellKind.today;

    if (dt.isAfter(mockToday)) {
      if (wd == DateTime.saturday || wd == DateTime.sunday) return _DayCellKind.rest;
      return _DayCellKind.future;
    }

    if (wd == DateTime.saturday || wd == DateTime.sunday) return _DayCellKind.rest;

    if (day <= 13) {
      if (day == 5 || day == 8 || day == 11) return _DayCellKind.absent;
      return _DayCellKind.present;
    }

    if (wd == DateTime.saturday || wd == DateTime.sunday) return _DayCellKind.rest;
    return _DayCellKind.future;
  }

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

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

class _QrCheckInCard extends StatelessWidget {
  const _QrCheckInCard({required this.onGenerate});

  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
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
            'Check in at your gym',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 6),
          Text(
            'Show this QR at the entrance scanner',
            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFB8B6B0)),
          ),
          const SizedBox(height: 16),
          FitCoreButton(label: 'Generate QR Code', onPressed: onGenerate),
        ],
      ),
    );
  }
}

class _QrModal extends StatefulWidget {
  const _QrModal();

  @override
  State<_QrModal> createState() => _QrModalState();
}

class _QrModalState extends State<_QrModal> {
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
    return Dialog(
      backgroundColor: const Color(0xFF222222),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _MockQrPattern(),
            const SizedBox(height: 16),
            Text(
              'Rahul Sharma',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              'Member ID: M-20481',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 16),
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

/// Simple deterministic mock QR pattern.
class _MockQrPattern extends StatelessWidget {
  const _MockQrPattern();

  @override
  Widget build(BuildContext context) {
    const size = 180.0;
    const cells = 21;
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: Colors.white,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cells,
              childAspectRatio: 1,
            ),
            itemCount: cells * cells,
            itemBuilder: (context, i) {
              final r = i ~/ cells;
              final c = i % cells;
              final on = (r * 7 + c * 3 + (r ^ c)) % 3 != 0;
              return ColoredBox(color: on ? Colors.black : Colors.white);
            },
          ),
        ),
      ),
    );
  }
}

class _LogEntry {
  const _LogEntry({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

class _LogSection extends StatelessWidget {
  const _LogSection();

  static const _entries = [
    _LogEntry(
      title: 'Jun 13, 2026 — Saturday',
      subtitle: 'Check-in: 6:32 AM | Check-out: 8:15 AM | Duration: 1h 43m',
    ),
    _LogEntry(
      title: 'Jun 12, 2026 — Friday',
      subtitle: 'Check-in: 6:45 AM | Check-out: 8:02 AM | Duration: 1h 17m',
    ),
    _LogEntry(
      title: 'Jun 11, 2026 — Thursday',
      subtitle: 'Check-in: — | Check-out: — | Duration: —',
    ),
    _LogEntry(
      title: 'Jun 10, 2026 — Wednesday',
      subtitle: 'Check-in: 6:28 AM | Check-out: 7:55 AM | Duration: 1h 27m',
    ),
    _LogEntry(
      title: 'Jun 9, 2026 — Tuesday',
      subtitle: 'Check-in: 6:40 AM | Check-out: 8:30 AM | Duration: 1h 50m',
    ),
  ];

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
        ..._entries.map(
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
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F3B2D),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('✓', style: TextStyle(color: Color(0xFF5A8F58), fontSize: 18, fontWeight: FontWeight.w700)),
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
                    'QR Scan',
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
