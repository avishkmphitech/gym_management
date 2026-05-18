import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../models/reception_checkin.dart';
import '../../providers/reception_checkin_provider.dart';
import '../../widgets/reception_attendance_log_tile.dart';

/// Full attendance activity log — search, summary stats, tap entry to edit.
class ReceptionAttendanceLogScreen extends ConsumerStatefulWidget {
  const ReceptionAttendanceLogScreen({super.key});

  @override
  ConsumerState<ReceptionAttendanceLogScreen> createState() => _ReceptionAttendanceLogScreenState();
}

class _ReceptionAttendanceLogScreenState extends ConsumerState<ReceptionAttendanceLogScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(receptionCheckInsProvider);
    final activeCount = ref.watch(receptionAttendanceProvider).activeSessions.length;
    final checkIns = log.where((e) => e.action == AttendanceAction.checkIn).length;
    final checkOuts = log.where((e) => e.action == AttendanceAction.checkOut).length;

    final filtered = _query.trim().isEmpty
        ? log
        : log.where((e) {
            final q = _query.toLowerCase();
            return e.memberName.toLowerCase().contains(q) ||
                e.memberId.toLowerCase().contains(q) ||
                e.actionLabel.toLowerCase().contains(q) ||
                e.timeLabel.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        title: Text(
          'Activity log',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryStatCard(
                    label: 'In gym',
                    value: '$activeCount',
                    icon: Icons.place_rounded,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Check-ins',
                    value: '$checkIns',
                    icon: Icons.login_rounded,
                    color: AppColors.primaryAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryStatCard(
                    label: 'Check-outs',
                    value: '$checkOuts',
                    icon: Icons.logout_rounded,
                    color: AppColors.secondaryAccent,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search member, ID, or time…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Recent activity',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} entries',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyLogState(isEmpty: log.isEmpty, query: _query)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => ReceptionAttendanceLogTile(record: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

class _EmptyLogState extends StatelessWidget {
  const _EmptyLogState({required this.isEmpty, required this.query});

  final bool isEmpty;
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEmpty ? Icons.history_rounded : Icons.search_off_rounded,
              size: 48,
              color: AppColors.secondaryText.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isEmpty ? 'No activity yet' : 'No matches',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEmpty
                  ? 'Check-ins and check-outs from the desk will appear here.'
                  : 'Nothing matches "$query". Try another search.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
