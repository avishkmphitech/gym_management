import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../models/reception_checkin.dart';
import '../../providers/reception_checkin_provider.dart';

enum _ScannerUiState { loading, active, permissionDenied, error }

/// Scan member attendance QR — camera starts only after permission is granted.
class ReceptionQrCheckInScreen extends ConsumerStatefulWidget {
  const ReceptionQrCheckInScreen({super.key});

  @override
  ConsumerState<ReceptionQrCheckInScreen> createState() => _ReceptionQrCheckInScreenState();
}

class _ReceptionQrCheckInScreenState extends ConsumerState<ReceptionQrCheckInScreen> {
  MobileScannerController? _scannerController;
  _ScannerUiState _uiState = _ScannerUiState.loading;
  String? _errorMessage;
  bool _handledScan = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_startScanner()));
  }

  @override
  void dispose() {
    unawaited(_scannerController?.dispose());
    super.dispose();
  }

  Future<void> _startScanner() async {
    if (!mounted) return;

    setState(() {
      _uiState = _ScannerUiState.loading;
      _errorMessage = null;
    });

    await _scannerController?.dispose();
    _scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    try {
      await _scannerController!.start();
      if (!mounted) return;
      setState(() => _uiState = _ScannerUiState.active);
    } on MobileScannerException catch (e) {
      if (!mounted) return;
      await _scannerController?.dispose();
      _scannerController = null;
      setState(() {
        if (e.errorCode == MobileScannerErrorCode.permissionDenied) {
          _uiState = _ScannerUiState.permissionDenied;
        } else {
          _uiState = _ScannerUiState.error;
        }
        _errorMessage = e.errorDetails?.message ?? e.errorCode.message;
      });
    } catch (e) {
      if (!mounted) return;
      await _scannerController?.dispose();
      _scannerController = null;
      setState(() {
        _uiState = _ScannerUiState.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_handledScan || _uiState != _ScannerUiState.active) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;

    final member = ReceptionMemberDirectory.fromQrValue(value);
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unrecognized QR code. Ask member to regenerate from Attendance.')),
      );
      return;
    }

    _handledScan = true;
    final result = ref.read(receptionAttendanceProvider.notifier).toggleAttendance(
          member,
          CheckInMethod.qr,
        );
    context.pop(result);
  }

  void _showSettingsHint() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Open Settings → Apps → FitCore Member → Permissions → Camera → Allow. '
          'On emulator: enable camera in AVD settings, then tap Try again.',
        ),
        duration: Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _scannerController;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.primaryText,
        title: const Text('QR scan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_uiState == _ScannerUiState.active && controller != null)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: controller,
              builder: (context, state, child) {
                if (!state.isRunning) return const SizedBox.shrink();
                return IconButton(
                  tooltip: state.torchState == TorchState.on ? 'Flash off' : 'Flash on',
                  onPressed: controller.toggleTorch,
                  icon: Icon(
                    state.torchState == TorchState.on ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: switch (_uiState) {
              _ScannerUiState.loading => const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryAccent),
                      SizedBox(height: 16),
                      Text(
                        'Requesting camera access…',
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              _ScannerUiState.permissionDenied => _PermissionBlockedView(
                  title: 'Camera access required',
                  message: 'Allow camera permission to scan member QR codes at the desk.',
                  onRetry: _startScanner,
                  onOpenSettings: _showSettingsHint,
                ),
              _ScannerUiState.error => _PermissionBlockedView(
                  title: 'Camera unavailable',
                  message: _errorMessage ?? 'Could not open the camera.',
                  onRetry: _startScanner,
                  onOpenSettings: _showSettingsHint,
                ),
              _ScannerUiState.active => Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: controller!,
                      onDetect: _onBarcodeDetected,
                      errorBuilder: (context, error) => _PermissionBlockedView(
                        title: 'Scanner error',
                        message: error.errorDetails?.message ?? error.errorCode.message,
                        onRetry: _startScanner,
                        onOpenSettings: _showSettingsHint,
                      ),
                    ),
                    IgnorePointer(
                      child: Center(
                        child: CustomPaint(
                          size: const Size(260, 260),
                          painter: _ScannerFramePainter(),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      child: Text(
                        'Align the member\'s attendance QR inside the frame',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                  ],
                ),
            },
          ),
          Container(
            width: double.infinity,
            color: AppColors.secondaryBg,
            padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + MediaQuery.paddingOf(context).bottom),
            child: Text(
              'One QR toggles check-in / check-out · ${ReceptionMemberDirectory.qrPayloadFor('M-20481')}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionBlockedView extends StatelessWidget {
  const _PermissionBlockedView({
    required this.title,
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primaryBg,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_rounded, size: 64, color: AppColors.warning),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FitCoreButton(
              label: 'Allow camera & retry',
              icon: Icons.camera_alt_outlined,
              onPressed: onRetry,
            ),
            const SizedBox(height: 12),
            FitCoreButton(
              label: 'How to enable camera',
              variant: FitCoreButtonVariant.secondary,
              onPressed: onOpenSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const corner = 28.0;
    final paint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    void cornerPath(Offset start, Offset hEnd, Offset vEnd) {
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(hEnd.dx, hEnd.dy)
        ..moveTo(start.dx, start.dy)
        ..lineTo(vEnd.dx, vEnd.dy);
      canvas.drawPath(path, paint);
    }

    cornerPath(Offset.zero, const Offset(corner, 0), const Offset(0, corner));
    cornerPath(Offset(size.width, 0), Offset(size.width - corner, 0), Offset(size.width, corner));
    cornerPath(Offset(0, size.height), Offset(corner, size.height), Offset(0, size.height - corner));
    cornerPath(
      Offset(size.width, size.height),
      Offset(size.width - corner, size.height),
      Offset(size.width, size.height - corner),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
