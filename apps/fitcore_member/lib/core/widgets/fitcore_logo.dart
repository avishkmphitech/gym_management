import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FitCore logo colors (transparent background; intended for dark UI).
abstract final class FitCoreBrandColors {
  static const Color accent = Color(0xFF3E7C59);
  static const Color lockupText = Color(0xFFF5F5F2);
}

/// Stylized **F** merged with a minimalist dumbbell — scales to any size.
///
/// Renders on a transparent background; use on dark surfaces per design system.
class FitCoreLogo extends StatelessWidget {
  const FitCoreLogo({
    super.key,
    required this.size,
    this.color = FitCoreBrandColors.accent,
  });

  /// Square edge length for the mark.
  final double size;

  /// Defaults to FitCore green accent [#3E7C59].
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FitCoreMarkPainter(color: color),
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
void paintFitCoreMark(Canvas canvas, Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final stemLeft = w * 0.06;
  final stemW = w * 0.22;
  final stemTop = h * 0.08;
  final stemBottom = h * 0.92;
  final stemR = stemW * 0.28;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(stemLeft, stemTop, stemLeft + stemW, stemBottom),
      Radius.circular(stemR),
    ),
    paint,
  );

  final topH = h * 0.13;
  final topW = w * 0.44;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stemLeft, stemTop, topW, topH),
      Radius.circular(topH * 0.35),
    ),
    paint,
  );

  final midTop = h * 0.40;
  final midH = h * 0.12;
  final midArmEnd = w * 0.42;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(stemLeft, midTop, midArmEnd - stemLeft, midH),
      Radius.circular(midH * 0.4),
    ),
    paint,
  );

  final cy = midTop + midH / 2;
  final shaftT = h * 0.052;
  final shaftL = midArmEnd - stemW * 0.12;
  final shaftR = w * 0.93;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset((shaftL + shaftR) / 2, cy),
        width: shaftR - shaftL,
        height: shaftT,
      ),
      Radius.circular(shaftT / 2),
    ),
    paint,
  );

  final plateW = w * 0.092;
  final plateH = h * 0.24;
  final leftCx = shaftL + w * 0.06;
  final rightCx = shaftR - w * 0.06;

  for (final cx in [leftCx, rightCx]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy),
          width: plateW,
          height: plateH,
        ),
        Radius.circular(plateW * 0.42),
      ),
      paint,
    );
  }
}

/// Vector brand mark: bold **F** with middle stroke flowing into a dumbbell shaft.
class _FitCoreMarkPainter extends CustomPainter {
  _FitCoreMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) => paintFitCoreMark(canvas, size, color);

  @override
  bool shouldRepaint(covariant _FitCoreMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
