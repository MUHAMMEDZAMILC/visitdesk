import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.scaffoldOffWhite;
    final surface = isDark ? AppColors.darkSurface : AppColors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.cardBorder;
    final text = isDark ? AppColors.white : AppColors.textTitle;
    final fieldFill = isDark ? AppColors.darkSurface : AppColors.fieldBg;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarycolor,
      brightness: brightness,
      primary: AppColors.primarycolor,
      onPrimary: AppColors.secondary,
      secondary: AppColors.secondary,
      surface: surface,
      error: AppColors.redPrimary,
    );

    OutlineInputBorder fieldBorder(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.fieldRadius),
      borderSide: BorderSide(color: c),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppFonts.liberationSans,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.plusJakartaSans,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        hintStyle: const TextStyle(color: AppColors.fieldHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: fieldBorder(AppColors.transparent),
        enabledBorder: fieldBorder(AppColors.transparent),
        focusedBorder: fieldBorder(AppColors.primarycolor),
        errorBorder: fieldBorder(AppColors.redPrimary),
        focusedErrorBorder: fieldBorder(AppColors.redPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.primarycolor
              : AppColors.secondary,
          foregroundColor: isDark ? AppColors.secondary : AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.secondary,
        indicatorColor: AppColors.mintTint,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? AppColors.primarycolor
                : AppColors.white,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => TextStyle(
            fontFamily: AppFonts.plusJakartaSans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected)
                ? AppColors.primarycolor
                : AppColors.white,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: isDark ? AppColors.darkBorder : AppColors.secondary,
        backgroundColor: surface,
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        showCheckmark: false,
        labelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            fontFamily: AppFonts.plusJakartaSans,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.white
                : (isDark ? AppColors.white : AppColors.secondary),
          ),
        ),
        secondaryLabelStyle: const TextStyle(color: AppColors.white),
      ),
      dividerColor: border,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primarycolor,
        foregroundColor: AppColors.secondary,
        shape: StadiumBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primarycolor,
      ),
    );
  }
}
