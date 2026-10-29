import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/theme/app_spacing.dart';
import 'app_container.dart';
import 'app_text.dart';

class DashboardStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              text: label,
              color: AppColors.subtitle,
              fontFamily: AppFonts.plusJakartaSans,
              weight: FontWeight.w500,
            ),
          ),
          AppText(
            text: '$value',
            color: color,
            size: 30,
            weight: FontWeight.w700,
            fontFamily: AppFonts.plusJakartaSans,
          ),
        ],
      ),
    );
  }
}
