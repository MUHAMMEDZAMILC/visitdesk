import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';

/// Single text widget for the app: body text uses Liberation Sans, headings
/// and labels pass [fontFamily] = [AppFonts.plusJakartaSans].
class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.color,
    this.size = 14,
    this.weight = FontWeight.w400,
    this.lineheight,
    this.textalign,
    this.maxline = 1,
    this.overflow = TextOverflow.ellipsis,
    this.fontFamily,
  });

  /// Heading / label style (Plus Jakarta Sans, bold).
  const AppText.heading({
    super.key,
    required this.text,
    this.color,
    this.size = 18,
    this.weight = FontWeight.w700,
    this.lineheight,
    this.textalign,
    this.maxline = 1,
    this.overflow = TextOverflow.ellipsis,
  }) : fontFamily = AppFonts.plusJakartaSans;

  final String text;
  final Color? color;
  final double size;
  final FontWeight? weight;
  final double? lineheight;
  final TextAlign? textalign;
  final int? maxline;
  final TextOverflow? overflow;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      maxLines: maxline,
      overflow: overflow,
      textAlign: textalign ?? TextAlign.start,
      style: TextStyle(
        fontFamily: fontFamily ?? AppFonts.liberationSans,
        fontSize: size,
        fontWeight: weight,
        height: lineheight,
        color: color ?? (isDark ? AppColors.white : AppColors.textTitle),
      ),
    );
  }
}
