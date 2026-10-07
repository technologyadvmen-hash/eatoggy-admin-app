import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final Widget? icon;
  final double? height;
  final double? width;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 5.5.h;
    final effectiveRadius = BorderRadius.circular(borderRadius ?? 14.0);

    if (type == AppButtonType.primary) {
      return Container(
        width: width ?? double.infinity,
        height: effectiveHeight,
        decoration: BoxDecoration(
          gradient: backgroundColor == null ? AppColors.primaryGradient : null,
          color: backgroundColor,
          borderRadius: effectiveRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: effectiveRadius,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 2.8.h,
                      height: 2.8.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          SizedBox(width: 2.w),
                        ],
                        Text(
                          text,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: textColor ?? Colors.white,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    if (type == AppButtonType.outline) {
      return Container(
        width: width ?? double.infinity,
        height: effectiveHeight,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: effectiveRadius,
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: effectiveRadius,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 2.5.h,
                      height: 2.5.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          icon!,
                          SizedBox(width: 2.w),
                        ],
                        Text(
                          text,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: textColor ?? AppColors.textPrimary,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    // Default secondary or text
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        minimumSize: Size(width ?? 0, effectiveHeight),
        shape: RoundedRectangleBorder(borderRadius: effectiveRadius),
      ),
      child: Text(
        text,
        style: AppTextStyles.buttonMedium.copyWith(
          color: textColor ?? AppColors.primary,
          fontSize: 13.5.sp,
        ),
      ),
    );
  }
}
