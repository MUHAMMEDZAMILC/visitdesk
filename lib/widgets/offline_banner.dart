import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'app_text.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.noticeIcon.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 18, color: AppColors.noticeIcon),
          SizedBox(width: 8),
          Expanded(
            child: AppText(
              text: 'Offline — showing last saved data. Pull to refresh.',
              size: 13,
              maxline: 2,
            ),
          ),
        ],
      ),
    );
  }
}
