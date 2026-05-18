import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/app_colors.dart';

ThemeData buildFitCoreTheme() {
  final poppins = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
  final inter = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primaryBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryAccent,
      secondary: AppColors.secondaryAccent,
      surface: AppColors.secondaryBg,
      onSurface: AppColors.primaryText,
      onPrimary: Colors.white,
      onSecondary: AppColors.primaryText,
      error: AppColors.error,
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
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.secondaryText,
      textColor: AppColors.primaryText,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 13,
        color: AppColors.secondaryText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primaryAccent),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryText),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardBg,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.cardBg,
      headerForegroundColor: AppColors.primaryText,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.primaryText;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.primaryText;
      }),
      todayForegroundColor: const WidgetStatePropertyAll(AppColors.primaryAccent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBg,
      labelStyle: inter.bodyMedium?.copyWith(color: AppColors.secondaryText, fontSize: 14),
      hintStyle: inter.bodyMedium?.copyWith(color: AppColors.secondaryText, fontSize: 14),
      prefixIconColor: AppColors.secondaryText,
      suffixIconColor: AppColors.secondaryText,
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
      displaySmall: poppins.displaySmall?.copyWith(color: AppColors.primaryText),
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
      titleMedium: poppins.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleSmall: poppins.titleSmall?.copyWith(
        fontSize: 14,
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
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontSize: 12,
        color: AppColors.secondaryText,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 11,
        color: AppColors.secondaryText,
      ),
    ),
  );
}
