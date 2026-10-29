import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_fonts.dart';
import '../core/theme/app_spacing.dart';

/// Pill button in the GoLoad style: navy fill, mint spinner area when
/// loading, grey when disabled. [outlined] gives the secondary variant.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final Color? btncolor;
  final Color? textcolor;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.btncolor,
    this.textcolor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !isLoading;
    final navy = isDark ? AppColors.primarycolor : AppColors.secondary;

    final fg = !enabled && !isLoading
        ? AppColors.fieldHint
        : outlined
        ? (textcolor ?? (isDark ? AppColors.white : AppColors.secondary))
        : (textcolor ?? (isDark ? AppColors.secondary : AppColors.white));

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: outlined ? navy : fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.plusJakartaSans,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 20 / 15,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
    );
    final size = const WidgetStatePropertyAll(
      Size.fromHeight(AppSpacing.buttonHeight),
    );
    final handler = enabled ? onPressed : null;

    if (outlined) {
      return OutlinedButton(
        onPressed: handler,
        style: ButtonStyle(
          minimumSize: size,
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          shape: WidgetStatePropertyAll(shape),
          side: WidgetStatePropertyAll(
            BorderSide(color: enabled ? navy : AppColors.buttonDisabledBg),
          ),
        ),
        child: content,
      );
    }
    return ElevatedButton(
      onPressed: handler,
      style: ButtonStyle(
        minimumSize: size,
        elevation: const WidgetStatePropertyAll(0),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(shape),
        backgroundColor: WidgetStatePropertyAll(
          isLoading || enabled
              ? (btncolor ?? navy)
              : AppColors.buttonDisabledBg,
        ),
      ),
      child: content,
    );
  }
}
