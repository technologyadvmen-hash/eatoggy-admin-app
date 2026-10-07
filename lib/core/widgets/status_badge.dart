import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_colors.dart';

enum StatusBadgeVariant { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.variant = StatusBadgeVariant.neutral,
    this.customBackgroundColor,
    this.customTextColor,
    this.icon,
  });

  final String label;
  final StatusBadgeVariant variant;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (variant) {
      case StatusBadgeVariant.success:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case StatusBadgeVariant.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
      case StatusBadgeVariant.error:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
      case StatusBadgeVariant.info:
        bg = AppColors.infoLight;
        fg = AppColors.info;
        break;
      case StatusBadgeVariant.neutral:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: customBackgroundColor ?? bg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: (customTextColor ?? fg).withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: 1.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: customTextColor ?? fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
