import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/visitor.dart';
import 'app_container.dart';
import 'app_text.dart';
import 'status_chip.dart';

class VisitorCard extends StatelessWidget {
  final Visitor visitor;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VisitorCard({
    super.key,
    required this.visitor,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainer(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: visitor.name,
                  size: 16,
                  weight: FontWeight.w700,
                  fontFamily: AppFonts.plusJakartaSans,
                ),
                const SizedBox(height: 2),
                AppText(text: visitor.mobile, color: AppColors.subtitle),
                const SizedBox(height: 2),
                AppText(
                  text: '${visitor.project} · ${visitor.visitorType}',
                  color: AppColors.subtitle,
                ),
                const SizedBox(height: AppSpacing.sm),
                StatusChip(status: visitor.status),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.redPrimary,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
