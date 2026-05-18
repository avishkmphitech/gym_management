import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_button.dart';
import '../models/reception_checkin.dart';
import '../providers/reception_checkin_provider.dart';

/// Bottom sheet for receptionist to edit or delete a check-in / check-out log entry.
Future<void> showReceptionEditLogSheet(BuildContext context, WidgetRef ref, ReceptionCheckInRecord record) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: _EditLogSheetBody(initial: record),
    ),
  );
}

class _EditLogSheetBody extends ConsumerStatefulWidget {
  const _EditLogSheetBody({required this.initial});

  final ReceptionCheckInRecord initial;

  @override
  ConsumerState<_EditLogSheetBody> createState() => _EditLogSheetBodyState();
}

class _EditLogSheetBodyState extends ConsumerState<_EditLogSheetBody> {
  late AttendanceAction _action;
  late CheckInMethod _method;
  late String _timeLabel;
  late String _checkInTimeLabel;
  final _checkInTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _action = widget.initial.action;
    _method = widget.initial.method;
    _timeLabel = widget.initial.timeLabel;
    _checkInTimeLabel = widget.initial.checkInTimeLabel ?? '';
    _checkInTimeController.text = _checkInTimeLabel;
  }

  @override
  void dispose() {
    _checkInTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isCheckInTime}) async {
    final initial = ReceptionCheckInNotifier.parseTimeLabel(isCheckInTime ? _checkInTimeLabel : _timeLabel) ??
        TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isCheckInTime ? 'Check-in time' : 'Event time',
    );
    if (picked == null || !mounted) return;
    setState(() {
      final label = ReceptionCheckInNotifier.formatTimeOfDay(picked);
      if (isCheckInTime) {
        _checkInTimeLabel = label;
        _checkInTimeController.text = label;
      } else {
        _timeLabel = label;
      }
    });
  }

  void _save() {
    if (_action == AttendanceAction.checkOut && _checkInTimeLabel.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out entries need the original check-in time.')),
      );
      return;
    }

    final updated = widget.initial.copyWith(
      action: _action,
      method: _method,
      timeLabel: _timeLabel,
      checkInTimeLabel: _action == AttendanceAction.checkOut ? _checkInTimeLabel.trim() : null,
      clearCheckInTimeLabel: _action == AttendanceAction.checkIn,
    );

    ref.read(receptionAttendanceProvider.notifier).updateLogEntry(updated);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance log updated')),
    );
  }

  Future<void> _confirmDelete() async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete log entry?'),
        content: Text(
          'Remove ${widget.initial.actionLabel} for ${widget.initial.memberName} at ${widget.initial.timeLabel}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (delete != true || !mounted) return;
    ref.read(receptionAttendanceProvider.notifier).deleteLogEntry(widget.initial.id);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log entry deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOut = _action == AttendanceAction.checkOut;
    final isIn = _action == AttendanceAction.checkIn;
    final accent = isIn ? AppColors.success : AppColors.secondaryAccent;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIn ? Icons.edit_calendar_rounded : Icons.edit_note_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit activity',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        widget.initial.memberName,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.initial.memberId,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),
            Text('Event type', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<AttendanceAction>(
              key: ValueKey(_action),
              initialValue: _action,
              items: const [
                DropdownMenuItem(value: AttendanceAction.checkIn, child: Text('Check in')),
                DropdownMenuItem(value: AttendanceAction.checkOut, child: Text('Check out')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _action = v);
              },
            ),
            const SizedBox(height: 16),
            Text('Recorded via', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<CheckInMethod>(
              key: ValueKey(_method),
              initialValue: _method,
              items: const [
                DropdownMenuItem(value: CheckInMethod.qr, child: Text('QR scan')),
                DropdownMenuItem(value: CheckInMethod.phone, child: Text('Mobile number')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _method = v);
              },
            ),
            const SizedBox(height: 16),
            Text(isOut ? 'Check-out time' : 'Check-in time', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _pickTime(isCheckInTime: false),
              icon: const Icon(Icons.schedule_rounded),
              label: Text(_timeLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (isOut) ...[
              const SizedBox(height: 16),
              Text('Original check-in time', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _pickTime(isCheckInTime: true),
                icon: const Icon(Icons.login_rounded),
                label: Text(_checkInTimeLabel.isEmpty ? 'Pick check-in time' : _checkInTimeLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FitCoreButton(label: 'Save changes', icon: Icons.save_outlined, onPressed: _save),
            const SizedBox(height: 12),
            FitCoreButton(
              label: 'Delete entry',
              variant: FitCoreButtonVariant.danger,
              icon: Icons.delete_outline_rounded,
              onPressed: _confirmDelete,
            ),
          ],
        ),
      ),
    );
  }
}
