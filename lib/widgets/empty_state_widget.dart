import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'app_text.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.people_outline,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.subtitle),
            const SizedBox(height: AppSpacing.md),
            AppText.heading(
              text: title,
              textalign: TextAlign.center,
              maxline: 2,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              AppText(
                text: subtitle!,
                textalign: TextAlign.center,
                color: AppColors.subtitle,
                maxline: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
