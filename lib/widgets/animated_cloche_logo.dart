import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../core/theme/app_colors.dart';

enum ClocheLogoSize {
  large,
  medium,
  small,
  mini,
}

/// A high-performance, beautiful animated delivery cloche logo widget.
/// Features smooth continuous floating, radial ambient glow, and animated speed trails.
class AnimatedClocheLogo extends StatefulWidget {
  const AnimatedClocheLogo({
    super.key,
    this.size = ClocheLogoSize.large,
    this.showGlow = true,
    this.showSpeedTrails = true,
    this.animateContinuous = true,
    this.customWidth,
    this.customHeight,
    this.onTap,
  });

  final ClocheLogoSize size;
  final bool showGlow;
  final bool showSpeedTrails;
  final bool animateContinuous;
  final double? customWidth;
  final double? customHeight;
  final VoidCallback? onTap;

  @override
  State<AnimatedClocheLogo> createState() => _AnimatedClocheLogoState();
}

class _AnimatedClocheLogoState extends State<AnimatedClocheLogo>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _trailController;
  late final AnimationController _shimmerController;
  late final Animation<double> _floatAnimation;

  double _pressScale = 1.0;

  @override
  void initState() {
    super.initState();

    // 1. Smooth floating / hover bobbing controller (2400ms cycle)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 2. Speed trails pulsing controller (1200ms)
    _trailController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 3. Shimmer sweep highlight controller (2800ms)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );

    if (widget.animateContinuous) {
      _floatController.repeat(reverse: true);
      _trailController.repeat(reverse: true);
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedClocheLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateContinuous != oldWidget.animateContinuous) {
      if (widget.animateContinuous) {
        _floatController.repeat(reverse: true);
        _trailController.repeat(reverse: true);
        _shimmerController.repeat();
      } else {
        _floatController.stop();
        _trailController.stop();
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _trailController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  double get _logoWidth {
    if (widget.customWidth != null) return widget.customWidth!;
    switch (widget.size) {
      case ClocheLogoSize.large:
        return 58.w;
      case ClocheLogoSize.medium:
        return 42.w;
      case ClocheLogoSize.small:
        return 28.w;
      case ClocheLogoSize.mini:
        return 16.w;
    }
  }

  double get _logoHeight {
    if (widget.customHeight != null) return widget.customHeight!;
    switch (widget.size) {
      case ClocheLogoSize.large:
        return 14.h;
      case ClocheLogoSize.medium:
        return 10.h;
      case ClocheLogoSize.small:
        return 6.5.h;
      case ClocheLogoSize.mini:
        return 4.h;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = _logoWidth;
    final height = _logoHeight;

    Widget content = SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Ambient Radial Glow Backdrop
          if (widget.showGlow)
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, _) {
                final glowScale = 1.0 + (_floatController.value * 0.12);
                return Center(
                  child: Container(
                    width: width * 1.35 * glowScale,
                    height: height * 1.5 * glowScale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.18),
                          AppColors.primaryDark.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

          // 2. Animated Speed Trails on Left
          if (widget.showSpeedTrails &&
              widget.size != ClocheLogoSize.mini &&
              widget.size != ClocheLogoSize.small)
            Positioned(
              left: -(width * 0.18),
              child: AnimatedBuilder(
                animation: _trailController,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(width * 0.35, height * 0.6),
                    painter: _SpeedTrailsPainter(
                      pulseValue: _trailController.value,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),

          // 3. Floating Hero Cloche Logo
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cloche Image
                Image.asset(
                  'assets/images/eatoggy_delivery_logo.png',
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/eatoggy_delivery_logo_original.jpg',
                      width: width,
                      height: height,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error2, stackTrace2) {
                        return Icon(
                          Icons.restaurant_rounded,
                          size: width * 0.4,
                          color: AppColors.primary,
                        );
                      },
                    );
                  },
                ),

                // 4. Subtle Shimmer / Light Reflection Pass
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, _) {
                      final shimmerPos = _shimmerController.value;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(height * 0.5),
                        child: ShaderMask(
                          blendMode: BlendMode.srcATop,
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment(-2.0 + (shimmerPos * 3.5), -1.0),
                              end: Alignment(-1.0 + (shimmerPos * 3.5), 1.0),
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.28),
                                Colors.white.withValues(alpha: 0.0),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.40, 0.50, 0.60, 1.0],
                            ).createShader(bounds);
                          },
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _pressScale = 0.94),
        onTapUp: (_) {
          setState(() => _pressScale = 1.0);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressScale = 1.0),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressScale,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Dynamic painter rendering 3 sleek aerodynamic speed lines
class _SpeedTrailsPainter extends CustomPainter {
  const _SpeedTrailsPainter({
    required this.pulseValue,
    required this.color,
  });

  final double pulseValue;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25 + (pulseValue * 0.45))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final lineSpacing = size.height * 0.28;

    // Top trail
    final topWidth = size.width * (0.65 + (pulseValue * 0.25));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - topWidth, centerY - lineSpacing - 2, topWidth, 4.5),
        const Radius.circular(3),
      ),
      paint,
    );

    // Center trail (longest)
    final midWidth = size.width * (0.85 + (pulseValue * 0.15));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - midWidth, centerY - 2, midWidth, 5.0),
        const Radius.circular(3),
      ),
      paint..color = color.withValues(alpha: 0.40 + (pulseValue * 0.40)),
    );

    // Bottom trail
    final botWidth = size.width * (0.50 + (pulseValue * 0.35));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - botWidth, centerY + lineSpacing - 2, botWidth, 4.0),
        const Radius.circular(3),
      ),
      paint..color = color.withValues(alpha: 0.20 + (pulseValue * 0.35)),
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedTrailsPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.color != color;
  }
}
