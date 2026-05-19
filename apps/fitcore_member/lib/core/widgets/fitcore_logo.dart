import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FitCore logo colors (transparent background; intended for dark UI).
abstract final class FitCoreBrandColors {
  static const Color accent = Color(0xFF3E7C59);
  static const Color accentLight = Color(0xFF5A9B72);
  static const Color accentDeep = Color(0xFF2D5E44);
  static const Color lockupText = Color(0xFFF5F5F2);
  static const Color energy = Color(0xFFC56A3D);
}

/// Premium FitCore mark — shield badge with geometric **F** and energy core ring.
///
/// Renders on a transparent background; use on dark surfaces per design system.
class FitCoreLogo extends StatelessWidget {
  const FitCoreLogo({
    super.key,
    required this.size,
    this.color = FitCoreBrandColors.accent,
    this.showGlow = false,
  });

  /// Square edge length for the mark.
  final double size;

  /// Primary fill; gradients derive from this when [showGlow] is true.
  final Color color;

  /// Adds a soft outer glow (splash / hero surfaces).
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FitCoreMarkPainter(color: color, showGlow: showGlow),
      ),
    );
  }
}

/// Horizontal lockup: [FitCoreLogo] + **FitCore** (Poppins SemiBold), [#F5F5F2].
class FitCoreLogoLockup extends StatelessWidget {
  const FitCoreLogoLockup({
    super.key,
    required this.logoSize,
    this.textColor = FitCoreBrandColors.lockupText,
    this.spacing,
    this.tagline,
    this.taglineColor,
    this.wordmarkStyle,
    this.taglineStyle,
  });

  /// Icon size; wordmark scales proportionally.
  final double logoSize;

  final Color textColor;

  /// Gap between icon and wordmark; defaults to ~0.26 × [logoSize].
  final double? spacing;

  /// Optional second line (e.g. “Power Your Gym”).
  final String? tagline;

  final Color? taglineColor;

  /// When set, used for “FitCore” instead of loading Poppins via [google_fonts] (tests / offline raster).
  final TextStyle? wordmarkStyle;

  /// When set, used for [tagline] instead of loading Inter via [google_fonts].
  final TextStyle? taglineStyle;

  @override
  Widget build(BuildContext context) {
    final gap = spacing ?? logoSize * 0.26;
    final nameSize = logoSize * 0.48;
    final tagSize = logoSize * 0.22;

    final wordStyle = wordmarkStyle ??
        GoogleFonts.poppins(
          fontSize: nameSize,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.0,
          letterSpacing: -0.4,
        );

    final subStyle = taglineStyle ??
        GoogleFonts.inter(
          fontSize: tagSize,
          fontWeight: FontWeight.w400,
          color: taglineColor ?? const Color(0xFFB8B6B0),
          height: 1.2,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FitCoreLogo(size: logoSize, color: FitCoreBrandColors.accent),
            SizedBox(width: gap),
            Text('FitCore', style: wordStyle),
          ],
        ),
        if (tagline != null) ...[
          SizedBox(height: logoSize * 0.12),
          Padding(
            padding: EdgeInsets.only(left: logoSize + gap),
            child: Text(tagline!, style: subStyle),
          ),
        ],
      ],
    );
  }
}

/// Paints the FitCore mark into [canvas] within [size] (square recommended).
///
/// Used by [FitCoreLogo] and by tooling that rasterizes PNG exports.
void paintFitCoreMark(
  Canvas canvas,
  Size size,
  Color color, {
  bool showGlow = false,
}) {
  final w = size.width;
  final h = size.height;
  final cx = w * 0.5;
  final cy = h * 0.5;

  if (showGlow) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.45),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.58))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(Offset(cx, cy), w * 0.48, glow);
  }

  final fill = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final accent = Paint()
    ..color = Color.lerp(color, Colors.white, 0.22)!
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  // Squircle shield — premium app-icon frame.
  final inset = w * 0.06;
  final shieldR = w * 0.24;
  final shield = RRect.fromRectAndRadius(
    Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
    Radius.circular(shieldR),
  );
  canvas.drawRRect(shield, fill);

  // Inner cut — darker inset for depth.
  final innerInset = w * 0.11;
  final innerR = w * 0.19;
  final innerShield = RRect.fromRectAndRadius(
    Rect.fromLTWH(
      innerInset,
      innerInset,
      w - innerInset * 2,
      h - innerInset * 2,
    ),
    Radius.circular(innerR),
  );
  canvas.drawRRect(
    innerShield,
    Paint()
      ..color = Color.lerp(color, const Color(0xFF151515), 0.35)!
      ..style = PaintingStyle.fill
      ..isAntiAlias = true,
  );

  // Energy arc (top-right) — orbital ring suggesting motion.
  final arcRect = Rect.fromCenter(
    center: Offset(cx + w * 0.08, cy - h * 0.06),
    width: w * 0.52,
    height: h * 0.52,
  );
  canvas.drawArc(
    arcRect,
    -math.pi * 0.15,
    math.pi * 0.72,
    false,
    Paint()
      ..color = accent.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.042
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true,
  );

  // Core dot at arc end.
  final arcEnd = Offset(
    arcRect.center.dx + arcRect.width * 0.42 * math.cos(-math.pi * 0.15 + math.pi * 0.72),
    arcRect.center.dy + arcRect.height * 0.42 * math.sin(-math.pi * 0.15 + math.pi * 0.72),
  );
  canvas.drawCircle(arcEnd, w * 0.038, accent);

  // Bold geometric F on inner field.
  final fColor = const Color(0xFFF5F5F2);
  final fPaint = Paint()
    ..color = fColor
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final stemLeft = w * 0.22;
  final stemW = w * 0.14;
  final stemTop = h * 0.28;
  final stemBottom = h * 0.72;
  final stemR = stemW * 0.35;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(stemLeft, stemTop, stemLeft + stemW, stemBottom),
      Radius.circular(stemR),
    ),
    fPaint,
  );

  final topH = h * 0.11;
  final topW = w * 0.34;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stemLeft, stemTop, topW, topH),
      Radius.circular(topH * 0.35),
    ),
    fPaint,
  );

  final midTop = h * 0.46;
  final midH = h * 0.09;
  final midEnd = stemLeft + w * 0.28;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stemLeft, midTop, midEnd - stemLeft, midH),
      Radius.circular(midH * 0.4),
    ),
    fPaint,
  );

  // Energy core — middle bar flows into pulsing circle (premium, not dumbbell).
  final coreCx = stemLeft + w * 0.36;
  final coreCy = midTop + midH / 2;
  final coreR = w * 0.065;

  canvas.drawLine(
    Offset(midEnd, coreCy),
    Offset(coreCx - coreR * 1.1, coreCy),
    Paint()
      ..color = fColor
      ..strokeWidth = midH * 0.55
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true,
  );

  canvas.drawCircle(Offset(coreCx, coreCy), coreR, fPaint);

  // Inner core highlight.
  canvas.drawCircle(
    Offset(coreCx, coreCy),
    coreR * 0.45,
    Paint()..color = color.withValues(alpha: 0.85),
  );

  // Ascending strength bars at bottom.
  final barBaseY = h * 0.78;
  final barW = w * 0.055;
  final barGap = w * 0.04;
  final barHeights = [h * 0.06, h * 0.09, h * 0.12];
  final barStartX = cx - (barHeights.length * barW + (barHeights.length - 1) * barGap) / 2;

  for (var i = 0; i < barHeights.length; i++) {
    final x = barStartX + i * (barW + barGap);
    final bh = barHeights[i];
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, barBaseY - bh, barW, bh),
        Radius.circular(barW * 0.4),
      ),
      Paint()
        ..color = Color.lerp(color, Colors.white, 0.15 + i * 0.12)!
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }
}

/// Vector brand mark: shield badge, geometric **F**, energy core, strength bars.
class _FitCoreMarkPainter extends CustomPainter {
  _FitCoreMarkPainter({required this.color, this.showGlow = false});

  final Color color;
  final bool showGlow;

  @override
  void paint(Canvas canvas, Size size) =>
      paintFitCoreMark(canvas, size, color, showGlow: showGlow);

  @override
  bool shouldRepaint(covariant _FitCoreMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.showGlow != showGlow;
}
