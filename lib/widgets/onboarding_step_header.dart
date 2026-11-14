import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Reusable animated header for onboarding wizard steps (Step 1 to 4)
/// Provides smooth animated progress bar, glowing indicator, and step status badge.
class OnboardingStepHeader extends StatefulWidget {
  const OnboardingStepHeader({
    super.key,
    required this.title,
    required this.currentStep,
    this.totalSteps = 4,
    required this.onBack,
  });

  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  State<OnboardingStepHeader> createState() => _OnboardingStepHeaderState();
}

class _OnboardingStepHeaderState extends State<OnboardingStepHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    final double startFraction =
        ((widget.currentStep - 1).clamp(0, widget.totalSteps)) /
            widget.totalSteps;
    final double targetFraction =
        (widget.currentStep.clamp(1, widget.totalSteps)) / widget.totalSteps;

    _progressAnimation = Tween<double>(
      begin: startFraction,
      end: targetFraction,
    ).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Back button + Title + Step badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: widget.onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                      size: 13.sp,
                    ),
                    SizedBox(width: 1.5.w),
                    Text(
                      widget.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Step counter pill badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Step ${widget.currentStep} of ${widget.totalSteps}',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 1.5.h),

        // Animated Smooth Progress Bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, _) {
            final progress = _progressAnimation.value.clamp(0.0, 1.0);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Container(
                  width: double.infinity,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Active Progress Fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 4.5,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
