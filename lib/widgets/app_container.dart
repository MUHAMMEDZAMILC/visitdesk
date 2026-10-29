import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Card-style container: white surface, soft border and shadow.
class AppContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  const AppContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = BorderRadius.circular(radius ?? AppSpacing.radius);
    final bg = color ?? (isDark ? AppColors.darkSurface : AppColors.white);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: r,
        border: Border.all(
          color:
              borderColor ??
              (isDark ? AppColors.darkBorder : AppColors.cardBorder),
        ),
        boxShadow: isDark ? null : AppColors.defaultShadow,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
