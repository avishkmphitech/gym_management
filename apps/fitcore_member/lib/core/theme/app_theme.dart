import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/app_colors.dart';

ThemeData buildFitCoreTheme() {
  final poppins = GoogleFonts.poppinsTextTheme();
  final inter = GoogleFonts.interTextTheme();

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primaryBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.secondaryBg,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.primaryText,
      onSurface: AppColors.primaryText,
    ),
    dividerColor: AppColors.border,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBg,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.secondaryBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBg,
      hintStyle: inter.bodyMedium?.copyWith(
        color: AppColors.secondaryText,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.sidebarBg,
      indicatorColor: AppColors.primaryAccent.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppColors.primaryAccent : AppColors.secondaryText,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.primaryAccent : AppColors.secondaryText,
          size: 24,
        );
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardBg,
      contentTextStyle: inter.bodyMedium?.copyWith(color: AppColors.primaryText),
      behavior: SnackBarBehavior.floating,
    ),
  );

  return base.copyWith(
    textTheme: inter.copyWith(
      headlineSmall: poppins.headlineSmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 14,
        color: AppColors.primaryText,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.secondaryText,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 12,
        color: AppColors.secondaryText,
      ),
    ),
  );
}
