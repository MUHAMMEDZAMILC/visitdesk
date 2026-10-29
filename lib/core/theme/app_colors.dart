import 'package:flutter/material.dart';

/// Palette shared with the GoLoad user app.
class AppColors {
  AppColors._();

  static const white = Color(0xFFFFFFFF);
  static const transparent = Colors.transparent;

  static const primarycolor = Color(0xFF00D1A7);
  static const primaryLight = Color(0xFFD6FFF6);
  static const mintTint = Color(0x1A00D1A7);
  static const secondary = Color(0xFF07161E);

  static const scaffoldBg = Color(0xFFFFFFFF);
  static const scaffoldOffWhite = Color(0xFFF6F7F9);
  static const cardBorder = Color(0xE5E2E8F0);
  static const dividerGray = Color(0xFFE2E4E9);

  static const textTitle = Color(0xFF191A1D);
  static const subtitle = Color(0xFF64748B);
  static const fieldBg = Color(0xFFF3F4F6);
  static const fieldHint = Color(0xFF76777B);
  static const buttonDisabledBg = Color(0xFFF1F5F9);

  static const redPrimary = Color(0xFFDC2626);
  static const redLight = Color(0xCCFFF1F2);
  static const successGreen = Color(0xFF10B981);
  static const noticeIcon = Color(0xFFF59E0B);
  static const chillText = Color(0xFF005FA3);

  // Dark theme surfaces (GoLoad has no dark mode; derived from [secondary]).
  static const darkBg = Color(0xFF07161E);
  static const darkSurface = Color(0xFF10252F);
  static const darkBorder = Color(0xFF1E3A47);

  static const defaultShadow = [
    BoxShadow(color: Color(0x0D191C1E), offset: Offset(0, 4), blurRadius: 18),
  ];
}
