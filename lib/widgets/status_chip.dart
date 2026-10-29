import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../data/models/visitor.dart';

class StatusChip extends StatelessWidget {
  final VisitorStatus status;

  const StatusChip({super.key, required this.status});

  static Color colorOf(VisitorStatus s) => switch (s) {
    VisitorStatus.registered => AppColors.chillText,
    VisitorStatus.checkedIn => AppColors.successGreen,
    VisitorStatus.checkedOut => AppColors.noticeIcon,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontFamily: AppFonts.plusJakartaSans,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
