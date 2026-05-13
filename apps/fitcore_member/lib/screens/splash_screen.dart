import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_logo.dart';
import '../services/auth_service.dart';

/// FitCore splash — design system: full #151515, logo + typography + progress + version.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  static const Duration _displayDuration = Duration(milliseconds: 2500);
  static const Duration _fadeDuration = Duration(milliseconds: 800);
  static const Duration _scaleDuration = Duration(milliseconds: 600);

  late final AnimationController _introController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(vsync: this, duration: _fadeDuration);
    _fadeAnimation = CurvedAnimation(parent: _introController, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Interval(
          0,
          _scaleDuration.inMilliseconds / _fadeDuration.inMilliseconds,
          curve: Curves.easeOut,
        ),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _introController.forward();

    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    Future<void>(() async {
      await Future<void>.delayed(_displayDuration);
      if (!mounted) return;

      final user = ref.read(authServiceProvider);
      if (user != null) {
        switch (user.role) {
          case 'TRAINER':
            context.go('/trainer/dashboard');
            return;
          case 'RECEPTIONIST':
            context.go('/receptionist/checkin');
            return;
          case 'MEMBER':
          default:
            context.go('/member/home');
            return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(StorageKeys.onboardingComplete) ?? false;

      if (!mounted) return;
      if (onboardingDone) {
        context.go('/login');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = MediaQuery.sizeOf(context).width * 0.6;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: Listenable.merge([_introController, _pulseController]),
                      builder: (context, child) {
                        final pulseScale = 1.0 + 0.03 * _pulseController.value;
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: _scaleAnimation.value * pulseScale,
                            child: const FitCoreLogo(
                              size: 120,
                              color: FitCoreBrandColors.accent,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'FitCore',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F5F2),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Power Your Gym',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFB8B6B0),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: SizedBox(
                      width: barWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 4,
                          backgroundColor: AppColors.border.withValues(alpha: 0.35),
                          color: const Color(0xFF3E7C59),
                          value: null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'v2.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF444444),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
