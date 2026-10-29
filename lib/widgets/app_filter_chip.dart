import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';

/// Pill filter chip: secondary (navy) label when unselected, white on the
/// navy fill when selected. The colour is set on the label itself so it does
/// not depend on how the chip theme resolves.
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselected = isDark ? AppColors.white : AppColors.secondary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.plusJakartaSans,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : unselected,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
