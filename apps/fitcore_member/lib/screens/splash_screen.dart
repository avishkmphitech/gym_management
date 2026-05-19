import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_logo.dart';
import '../services/auth_service.dart';

/// Cinematic FitCore splash — premium gym entrance experience.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const Duration _totalDuration = Duration(milliseconds: 3800);

  late final AnimationController _master;
  late final AnimationController _shimmer;
  late final AnimationController _particles;

  late final Animation<double> _ambient;
  late final Animation<double> _doors;
  late final Animation<double> _logoReveal;
  late final Animation<double> _logoScale;
  late final Animation<double> _ringExpand;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;
  late final Animation<double> _floorGlow;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _scheduleNavigation();
  }

  void _initAnimations() {
    _master = AnimationController(vsync: this, duration: _totalDuration);

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _particles = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();

    _ambient = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _doors = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.08, 0.55, curve: Curves.easeInOutCubic),
    );

    _logoReveal = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
    );

    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.28, 0.68, curve: Curves.easeOutBack),
      ),
    );

    _ringExpand = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.32, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _titleSlide = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.45, 0.72, curve: Curves.easeOut),
    );

    _taglineFade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.52, 0.78, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.35, 0.92, curve: Curves.easeInOut),
    );

    _floorGlow = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOut),
    );

    _master.forward();
  }

  void _scheduleNavigation() {
    Future<void>(() async {
      await Future<void>.delayed(_totalDuration);
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
    _master.dispose();
    _shimmer.dispose();
    _particles.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final barWidth = size.width * 0.62;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_master, _shimmer, _particles]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _AmbientLayer(opacity: _ambient.value),
              _LightRaysLayer(intensity: _ambient.value * 0.85),
              _ParticleLayer(progress: _particles.value),
              _DoorRevealLayer(openAmount: _doors.value),
              _FloorGlowLayer(intensity: _floorGlow.value),
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    _buildLogoSection(),
                    const SizedBox(height: 32),
                    _buildTitleSection(),
                    const Spacer(flex: 3),
                    _buildProgressSection(barWidth),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogoSection() {
    return Opacity(
      opacity: _logoReveal.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding energy ring.
              Transform.scale(
                scale: _ringExpand.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FitCoreBrandColors.accent.withValues(
                        alpha: 0.25 * (1 - _ringExpand.value * 0.5),
                      ),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: _ringExpand.value * 0.82,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FitCoreBrandColors.energy.withValues(
                        alpha: 0.18 * (1 - _ringExpand.value * 0.4),
                      ),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Shimmer overlay on logo.
              ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  final slide = (_shimmer.value * 2 - 0.5) * bounds.width;
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientTranslation(slide, 0),
                  ).createShader(bounds);
                },
                child: const FitCoreLogo(
                  size: 120,
                  color: FitCoreBrandColors.accent,
                  showGlow: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Transform.translate(
      offset: Offset(0, _titleSlide.value),
      child: Opacity(
        opacity: _titleFade.value,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xFFF5F5F2),
                  Color(0xFFD4D2CC),
                ],
              ).createShader(bounds),
              child: Text(
                'FitCore',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Opacity(
              opacity: _taglineFade.value,
              child: Text(
                'Enter Your Peak Performance',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.3,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Opacity(
              opacity: _taglineFade.value * 0.7,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PremiumBadge(),
                  const SizedBox(width: 8),
                  Text(
                    'PREMIUM FITNESS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: FitCoreBrandColors.energy.withValues(alpha: 0.9),
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(double barWidth) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: _taglineFade.value,
            child: Text(
              _progress.value < 0.98 ? 'Preparing your experience…' : 'Welcome',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: barWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                    height: 5,
                    color: AppColors.border.withValues(alpha: 0.35),
                  ),
                  FractionallySizedBox(
                    widthFactor: _progress.value.clamp(0.0, 1.0),
                    child: Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            FitCoreBrandColors.accentDeep,
                            FitCoreBrandColors.accent,
                            FitCoreBrandColors.accentLight,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'v2.0.0',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: FitCoreBrandColors.energy.withValues(alpha: 0.5),
        ),
        gradient: LinearGradient(
          colors: [
            FitCoreBrandColors.energy.withValues(alpha: 0.15),
            FitCoreBrandColors.energy.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Text(
        'PRO',
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: FitCoreBrandColors.energy,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

/// Translates a gradient horizontally for shimmer sweep.
class GradientTranslation extends GradientTransform {
  const GradientTranslation(this.dx, this.dy);

  final double dx;
  final double dy;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, dy, 0);
  }
}

// ─── Background layers ───────────────────────────────────────────────────────

class _AmbientLayer extends StatelessWidget {
  const _AmbientLayer({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(opacity: opacity),
      size: Size.infinite,
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.38;

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.primaryBg,
    );

    final greenGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 0.9,
        colors: [
          FitCoreBrandColors.accent.withValues(alpha: 0.22 * opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, greenGlow);

    final orangeGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, 0.6),
        radius: 0.55,
        colors: [
          FitCoreBrandColors.energy.withValues(alpha: 0.08 * opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, orangeGlow);

    // Vignette — draws focus to center (gym entrance tunnel).
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment(cx / size.width * 2 - 1, cy / size.height * 2 - 1),
        radius: 0.95,
        colors: [
          Colors.transparent,
          AppColors.primaryBg.withValues(alpha: 0.55 * opacity),
          AppColors.primaryBg.withValues(alpha: 0.92),
        ],
        stops: const [0.35, 0.72, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) => old.opacity != opacity;
}

class _LightRaysLayer extends StatelessWidget {
  const _LightRaysLayer({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LightRaysPainter(intensity: intensity),
      size: Size.infinite,
    );
  }
}

class _LightRaysPainter extends CustomPainter {
  _LightRaysPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final cx = size.width * 0.5;
    final top = -size.height * 0.05;

    for (var i = 0; i < 7; i++) {
      final angle = -math.pi / 2 + (i - 3) * 0.12;
      final path = Path()
        ..moveTo(cx, top)
        ..lineTo(
          cx + math.cos(angle) * size.height * 1.1,
          top + math.sin(angle) * size.height * 1.1,
        )
        ..lineTo(
          cx + math.cos(angle + 0.04) * size.height * 1.1,
          top + math.sin(angle + 0.04) * size.height * 1.1,
        )
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FitCoreBrandColors.accent.withValues(alpha: 0.06 * intensity),
              Colors.transparent,
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LightRaysPainter old) => old.intensity != intensity;
}

class _ParticleLayer extends StatelessWidget {
  const _ParticleLayer({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(progress: progress),
      size: Size.infinite,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress});

  final double progress;
  static const _count = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (var i = 0; i < _count; i++) {
      final seed = i * 0.137;
      final x = (math.sin(seed * 12.7) * 0.5 + 0.5) * size.width;
      final phase = (progress + seed) % 1.0;
      final y = size.height * (1.05 - phase * 1.1);
      final alpha = (math.sin(phase * math.pi) * 0.35).clamp(0.0, 1.0);
      final radius = 1.2 + (i % 3) * 0.6;

      paint.color = (i.isEven ? FitCoreBrandColors.accent : FitCoreBrandColors.energy)
          .withValues(alpha: alpha * 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.progress != progress;
}

/// Simulates gym doors opening — panels slide apart to reveal the brand.
class _DoorRevealLayer extends StatelessWidget {
  const _DoorRevealLayer({required this.openAmount});

  final double openAmount;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final panelWidth = size.width * 0.5 * (1 - openAmount);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: _DoorPanel(isLeft: true, openAmount: openAmount),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: panelWidth,
            child: _DoorPanel(isLeft: false, openAmount: openAmount),
          ),
        ],
      ),
    );
  }
}

class _DoorPanel extends StatelessWidget {
  const _DoorPanel({required this.isLeft, required this.openAmount});

  final bool isLeft;
  final double openAmount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF1A1A1A),
            const Color(0xFF252525).withValues(alpha: 0.95 - openAmount * 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6 * (1 - openAmount)),
            blurRadius: 24,
            offset: Offset(isLeft ? 8 : -8, 0),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _DoorTexturePainter(isLeft: isLeft, fade: 1 - openAmount),
      ),
    );
  }
}

class _DoorTexturePainter extends CustomPainter {
  _DoorTexturePainter({required this.isLeft, required this.fade});

  final bool isLeft;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (fade <= 0.05) return;

    final paint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.12 * fade)
      ..strokeWidth = 1;

    // Vertical brushed-metal lines.
    for (var x = 12.0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Center seam highlight on inner edge.
    final seamX = isLeft ? size.width - 1 : 1.0;
    canvas.drawLine(
      Offset(seamX, 0),
      Offset(seamX, size.height),
      Paint()
        ..color = FitCoreBrandColors.accent.withValues(alpha: 0.35 * fade)
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _DoorTexturePainter old) =>
      old.isLeft != isLeft || old.fade != fade;
}

class _FloorGlowLayer extends StatelessWidget {
  const _FloorGlowLayer({required this.intensity});

  final double intensity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FloorGlowPainter(intensity: intensity),
      size: Size.infinite,
    );
  }
}

class _FloorGlowPainter extends CustomPainter {
  _FloorGlowPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final floorY = size.height * 0.72;
    final rect = Rect.fromLTWH(0, floorY, size.width, size.height - floorY);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FitCoreBrandColors.accent.withValues(alpha: 0.12 * intensity),
            Colors.transparent,
          ],
        ).createShader(rect),
    );

    // Horizon line — gym floor reflection.
    canvas.drawLine(
      Offset(0, floorY),
      Offset(size.width, floorY),
      Paint()
        ..color = FitCoreBrandColors.accent.withValues(alpha: 0.2 * intensity)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _FloorGlowPainter old) => old.intensity != intensity;
}
