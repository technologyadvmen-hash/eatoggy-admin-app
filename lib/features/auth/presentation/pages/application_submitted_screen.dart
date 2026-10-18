import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../widgets/animated_cloche_logo.dart';
import '../providers/application_submitted_provider.dart';

class ApplicationSubmittedScreen extends ConsumerStatefulWidget {
  const ApplicationSubmittedScreen({super.key});

  @override
  ConsumerState<ApplicationSubmittedScreen> createState() =>
      _ApplicationSubmittedScreenState();
}

class _ApplicationSubmittedScreenState extends ConsumerState<ApplicationSubmittedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _btnScaleController;

  late final Animation<double> _badgeScale;
  late final Animation<double> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // 1. Choreographed entrance (1200ms)
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 2. Continuous pulse for success ripple
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // 3. Button tap micro-interaction
    _btnScaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      vsync: this,
    )..value = 1.0;

    // Checkmark pop with elastic spring
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.65, curve: Curves.elasticOut),
      ),
    );

    // Title & subtitle slide
    _contentSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.30, 0.70, curve: Curves.easeIn),
      ),
    );

    // Main Card entrance
    _cardScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 0.88, curve: Curves.easeOutBack),
      ),
    );

    // CTA button slide
    _buttonSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _btnScaleController.dispose();
    super.dispose();
  }

  void _copyAppId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Application ID copied to clipboard: $id'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationSubmittedProvider);
    final data = state.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient soft radial gradient background
          Positioned(
            top: -10.h,
            right: -10.w,
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.success.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Top Hero Brand Cloche Logo with animated speed trails
                  Center(
                    child: const AnimatedClocheLogo(
                      size: ClocheLogoSize.small,
                      showSpeedTrails: true,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Celebratory Success Badge with Expanding Ripple Rings
                  AnimatedBuilder(
                    animation: Listenable.merge([_badgeScale, _pulseController]),
                    builder: (context, _) {
                      final scale = _badgeScale.value;
                      final pulse = _pulseController.value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ripple Ring 1
                          Transform.scale(
                            scale: scale * (1.0 + (pulse * 0.35)),
                            child: Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.success.withValues(
                                    alpha: (1.0 - pulse) * 0.45,
                                  ),
                                  width: 2.5,
                                ),
                              ),
                            ),
                          ),

                          // Ripple Ring 2
                          Transform.scale(
                            scale: scale * (1.0 + (pulse * 0.65)),
                            child: Container(
                              width: 22.w,
                              height: 22.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: (1.0 - pulse) * 0.25,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          // Core Success Icon Badge
                          Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF059669),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 3.h),

                  // Staggered Title & Subtitle
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _contentSlide.value),
                        child: Opacity(
                          opacity: _contentFade.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 13.5.sp,
                            color: AppColors.textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.5.h),

                  // Elevated Animated Status Card
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardScale.value,
                        child: Opacity(
                          opacity: _contentFade.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Header with live pulsating green radar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data.applicationIdLabel,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.8.w,
                                  vertical: 0.4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, _) {
                                        return Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF10B981).withValues(
                                                  alpha: 0.5 + (_pulseController.value * 0.4),
                                                ),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      'UNDER REVIEW',
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF047857),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 1.h),

                          // Application ID with Copy Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data.applicationIdValue,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontSize: 16.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _copyAppId(data.applicationIdValue),
                                icon: const Icon(Icons.copy_rounded),
                                color: AppColors.primary,
                                iconSize: 18.sp,
                                tooltip: 'Copy ID',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.h),
                          Divider(color: AppColors.border.withValues(alpha: 0.7), height: 1),
                          SizedBox(height: 2.h),

                          // Verification turnaround notice
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.bolt_rounded,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 12.5.sp,
                                      color: AppColors.textMuted,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Our onboarding desk verifies your documents within ",
                                      ),
                                      TextSpan(
                                        text: '24-48 hours',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: '. You will receive an SMS and WhatsApp update once approved.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Interactive Go To Dashboard CTA Button
                  AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _buttonSlide.value),
                        child: Opacity(
                          opacity: _contentFade.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: ScaleTransition(
                      scale: _btnScaleController,
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
                          onPressed: () {
                            _btnScaleController.forward().then((_) {
                              _btnScaleController.reverse();
                              context.go(AppRoutes.dashboard);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data.buttonText,
                                style: AppTextStyles.buttonLarge.copyWith(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.8.h),

                  Text(
                    data.accessibleNote,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Support Phone Trigger
                  GestureDetector(
                    onTap: () => Helpers.makePhoneCall('18001234567'),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.headset_mic_rounded,
                            color: AppColors.primary,
                            size: 15.sp,
                          ),
                          SizedBox(width: 2.w),
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.textMuted,
                              ),
                              children: [
                                TextSpan(text: data.needHelpPrefix),
                                TextSpan(
                                  text: data.contactSupportText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
