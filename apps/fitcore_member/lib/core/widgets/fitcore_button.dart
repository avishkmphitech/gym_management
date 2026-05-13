import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

enum FitCoreButtonVariant { primary, secondary, danger, small }

class FitCoreButton extends StatelessWidget {
  const FitCoreButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FitCoreButtonVariant.primary,
    this.expanded = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final FitCoreButtonVariant variant;
  final bool expanded;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isSmall = variant == FitCoreButtonVariant.small;
    final height = isSmall ? 36.0 : 52.0;
    final radius = isSmall ? 10.0 : 14.0;
    final fontSize = isSmall ? 12.0 : 14.0;

    Color bg;
    Color fg = AppColors.primaryText;
    BorderSide? side;

    switch (variant) {
      case FitCoreButtonVariant.primary:
        bg = AppColors.primaryAccent;
        fg = Colors.white;
        break;
      case FitCoreButtonVariant.secondary:
        bg = AppColors.secondaryButtonBg;
        side = const BorderSide(color: AppColors.border);
        break;
      case FitCoreButtonVariant.danger:
        bg = AppColors.error;
        fg = Colors.white;
        break;
      case FitCoreButtonVariant.small:
        bg = AppColors.primaryAccent;
        fg = Colors.white;
        break;
    }

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
        ),
      ],
    );

    final button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.35),
        elevation: 0,
        minimumSize: Size(expanded ? double.infinity : 0, height),
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: side ?? BorderSide.none,
        ),
      ),
      onPressed: onPressed,
      child: child,
    );

    if (expanded) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }
    return SizedBox(height: height, child: button);
  }
}
