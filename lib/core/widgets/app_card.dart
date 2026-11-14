import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(borderRadius ?? 16.0);

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: borderWidth ?? 1.0,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}
