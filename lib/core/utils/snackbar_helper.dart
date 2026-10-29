import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SnackbarHelper {
  SnackbarHelper._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.successGreen);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.redPrimary);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
