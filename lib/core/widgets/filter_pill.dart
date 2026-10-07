import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
    this.countColor,
    this.countBackgroundColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;
  final Color? countColor;
  final Color? countBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: borderRadius,
          border: isSelected
              ? null
              : Border.all(color: AppColors.border, width: 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 1.5.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.8.w, vertical: 0.2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (countBackgroundColor ?? Colors.white)
                      : (countBackgroundColor ?? AppColors.primaryLight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? (countColor ?? AppColors.primary)
                        : (countColor ?? AppColors.primary),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
