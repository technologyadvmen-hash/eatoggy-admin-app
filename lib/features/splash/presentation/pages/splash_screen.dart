import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/splash_model.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // Main timeline controller (entrance, logo flight, text reveals)
  late final AnimationController _mainAnimController;

  // Continuous subtle floating & pulse controller
  late final AnimationController _floatAnimController;

  // Shimmer / light sweep controller
  late final AnimationController _shimmerController;

  // Animations
  late final Animation<double> _logoSlideFromLeft;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _speedTrails;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _badgeScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _progressBar;
  late final Animation<double> _footerOpacity;

  @override
  void initState() {
    super.initState();

    // 1. Main choreographed entrance timeline (2400 ms)
    _mainAnimController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    // 2. Infinite gentle hover & halo breathing
    _floatAnimController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);

    // 3. Shimmer light sweep controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();

    // Logo slides with momentum from off-screen left (-1.8) to center (0.0)
    _logoSlideFromLeft = Tween<double>(begin: -1.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.05, 0.50, curve: Curves.easeOutBack),
      ),
    );

    // Dynamic scale spring on brake
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutQuart)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.05, 0.58),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.05, 0.30, curve: Curves.easeIn),
      ),
    );

    // Speed trails expansion and dissipation
    _speedTrails = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.0, 0.55),
      ),
    );

    // Title entrance: slides up smoothly
    _titleSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.40, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.40, 0.65, curve: Curves.easeOut),
      ),
    );

    // Partner badge pop
    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.55, 0.78, curve: Curves.elasticOut),
      ),
    );

    // Tagline fade
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.65, 0.85, curve: Curves.easeIn),
      ),
    );

    // Progress bar fill from 0 to 100%
    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.20, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    // Footer info
    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    // Play entrance
    _mainAnimController.forward();

    // Trigger router check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashProvider.notifier).initSplash();
    });
  }

  @override
  void dispose() {
    _mainAnimController.dispose();
    _floatAnimController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashProvider, (previous, next) {
      if (next.canNavigate && mounted) {
        context.go(next.data.nextRoute);
      }
    });

    final splashState = ref.watch(splashProvider);
    final data = splashState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient soft radial gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatAnimController,
              builder: (context, _) {
                final scale = 1.0 + (_floatAnimController.value * 0.15);
                return Center(
                  child: Container(
                    width: 90.w * scale,
                    height: 90.w * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.10),
                          AppColors.primary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Animated Center Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),

                          // Animated Logo + Speed Trails + Floating effect
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _mainAnimController,
                    _floatAnimController,
                    _shimmerController,
                  ]),
                  builder: (context, child) {
                    final slideOffset = _logoSlideFromLeft.value;
                    final floatY = math.sin(_floatAnimController.value * math.pi) * 5.0;

                    return Transform.translate(
                      offset: Offset(slideOffset * 100.w, floatY),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: _buildHeroLogoSection(data),
                ),

                SizedBox(height: 3.5.h),

                // Staggered Brand Title Reveal
                AnimatedBuilder(
                  animation: _mainAnimController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _titleSlide.value),
                      child: Opacity(
                        opacity: _titleOpacity.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "EATOGGY" Bold Branding with tracking
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              AppColors.textPrimary,
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                            stops: [0.0, 0.65, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          data.appTitle,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.5,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 1.2.h),

                      // "RESTAURANT PARTNER" Pill Badge
                      Transform.scale(
                        scale: _badgeScale.value,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.5.w,
                            vertical: 0.6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.primary,
                                size: 14.sp,
                              ),
                              SizedBox(width: 1.5.w),
                              Text(
                                'RESTAURANT PARTNER',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 1.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 1.6.h),

                      // Tagline
                      Opacity(
                        opacity: _taglineOpacity.value.clamp(0.0, 1.0),
                        child: Text(
                          data.tagline,
                          style: AppTextStyles.subhead.copyWith(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // Sleek Animated Loading Progress Line
                AnimatedBuilder(
                  animation: _mainAnimController,
                  builder: (context, _) {
                    final progress = _progressBar.value;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 3.5,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.border.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: 2.h),

                // Footer Version Information
                AnimatedBuilder(
                  animation: _mainAnimController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _footerOpacity.value.clamp(0.0, 1.0),
                      child: child,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.versionInfo,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      );
    },
  ),
),
      ],
    ),
  );
}

  /// Builds the hero logo card with glowing backdrop, speed trails, and reflection
  Widget _buildHeroLogoSection(SplashModel data) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 1. Dynamic Speed Trails on the Left
        Positioned(
          left: -12.w,
          child: AnimatedBuilder(
            animation: _mainAnimController,
            builder: (context, _) {
              final trailFactor = _speedTrails.value;
              return Opacity(
                opacity: trailFactor.clamp(0.0, 1.0),
                child: CustomPaint(
                  size: Size(18.w * trailFactor, 8.h),
                  painter: _SpeedTrailsPainter(
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ),

        // 2. Halo Energy Ring
        Container(
          width: 58.w,
          height: 58.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.22),
                AppColors.primaryDark.withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.48, 1.0],
            ),
          ),
        ),

        // 3. Elevated Glassmorphic Card for the Cloche Logo
        Container(
          width: 62.w,
          height: 18.h,
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Logo Image
              Image.asset(
                data.logoAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant_rounded,
                    size: 35.sp,
                    color: AppColors.primary,
                  );
                },
              ),

              // Light Sheen / Shimmer Sweep crossing across the cloche
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  final sweep = (_shimmerController.value * 2.5) - 1.2;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Transform.translate(
                      offset: Offset(sweep * 60.w, 0),
                      child: Container(
                        width: 14.w,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            transform: const GradientRotation(math.pi / 4),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom painter for dynamic high-speed streaks trailing behind the delivery cloche
class _SpeedTrailsPainter extends CustomPainter {
  _SpeedTrailsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    // Line 1: Top speed streak
    paint.color = color.withValues(alpha: 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.22, size.width * 0.85, 4.5),
        const Radius.circular(3),
      ),
      paint,
    );

    // Line 2: Middle long streak
    paint.color = color.withValues(alpha: 0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.45, size.width * 0.90, 5.0),
        const Radius.circular(3),
      ),
      paint,
    );

    // Line 3: Bottom speed streak
    paint.color = color.withValues(alpha: 0.65);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.68, size.width * 0.70, 4.0),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedTrailsPainter oldDelegate) =>
      oldDelegate.color != color;
}
