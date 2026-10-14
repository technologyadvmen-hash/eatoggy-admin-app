import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../widgets/animated_cloche_logo.dart';
import '../providers/register_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _headerSlide;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _heroSlide;
  late final Animation<double> _heroScale;
  late final Animation<double> _buttonSlide;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _headerSlide = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _headerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    _heroSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _heroScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _buttonSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.60, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStartRegistration(BuildContext context) {
    ref.read(registerProvider.notifier).startRegistration(
      onSuccess: () {
        context.push(AppRoutes.businessProfile);
      },
      onError: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);
    final data = registerState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Animated Top Header Title
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _headerSlide.value),
                    child: Opacity(
                      opacity: _headerOpacity.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: data.titlePrefix,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                        children: [
                          TextSpan(
                            text: data.brandName,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: '\n${data.titleSuffix.trim()}',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.2.h),
                    Text(
                      data.subtitle,
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 13.5.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Animated Hero Image Banner with Subtle Zoom & Shadow
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _heroSlide.value),
                    child: Transform.scale(
                      scale: _heroScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const AnimatedClocheLogo(
                        size: ClocheLogoSize.medium,
                        showGlow: true,
                        showSpeedTrails: true,
                      ),
                      SizedBox(height: 1.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: AppColors.primary,
                              size: 12.sp,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              'OFFICIAL RESTAURANT PARTNER ONBOARDING',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Staggered Feature Cards Entrance
              ...List.generate(data.features.length, (index) {
                final feature = data.features[index];
                final startInterval = 0.35 + (index * 0.10);
                final endInterval = math.min(1.0, startInterval + 0.30);

                final featureAnim = Tween<double>(begin: 25.0, end: 0.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
                  ),
                );

                final opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: Interval(startInterval, math.min(1.0, startInterval + 0.20), curve: Curves.easeIn),
                  ),
                );

                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(featureAnim.value, 0),
                      child: Opacity(
                        opacity: opacityAnim.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 2.2.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Center(
                            child: Icon(
                              feature.icon,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature.title,
                                style: AppTextStyles.subheadMedium.copyWith(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                feature.subtitle,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 2.h),

              // Animated Start Registration Button
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _buttonSlide.value),
                    child: Opacity(
                      opacity: _buttonOpacity.value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 6.2.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: registerState.isLoading
                        ? null
                        : () => _onStartRegistration(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: registerState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.buttonText,
                                style: AppTextStyles.buttonLarge.copyWith(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              Center(
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.login);
                    }
                  },
                  child: Text.rich(
                    TextSpan(
                      text: '${data.loginPrefix} ',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 13.5.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: data.loginAction,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }
}
