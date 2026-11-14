import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../../widgets/animated_cloche_logo.dart';
import '../providers/otp_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phoneNumber, this.testOtp});

  final String phoneNumber;
  final String? testOtp;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _animController;
  late final Animation<double> _headerSlide;
  late final Animation<double> _headerOpacity;
  late final Animation<double> _buttonSlide;
  late final Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();

    final otpState = ref.read(otpProvider);
    final count = otpState.data.otpLength;

    _controllers = List.generate(
      count,
      (_) => TextEditingController(),
    );

    _focusNodes = List.generate(count, (_) => FocusNode());

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    _buttonSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.80, curve: Curves.easeIn),
      ),
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpProvider.notifier).init(widget.phoneNumber);

      for (final c in _controllers) {
        c.clear();
      }
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    final notifier = ref.read(otpProvider.notifier);
    if (value.length > 1) {
      final clean = value.replaceAll(RegExp(r'\D'), '');
      if (clean.length == _controllers.length) {
        for (int i = 0; i < clean.length; i++) {
          _controllers[i].text = clean[i];
          notifier.updateDigit(i, clean[i]);
        }
        _focusNodes.last.requestFocus();
        return;
      }
    }

    if (value.isNotEmpty) {
      final lastChar = value.characters.last;
      _controllers[index].value = TextEditingValue(
        text: lastChar,
        selection: TextSelection.collapsed(offset: lastChar.length),
      );
      notifier.updateDigit(index, lastChar);

      if (index < _controllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      notifier.clearDigit(index);
    }
    setState(() {});
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      ref.read(otpProvider.notifier).clearDigit(index - 1);
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _onVerifySubmitted() {
    final notifier = ref.read(otpProvider.notifier);
    notifier.verifyOtp(
      onSuccess: (data) {
        if (!mounted) return;
        final user = data['user'] as Map<String, dynamic>? ?? {};
        final destination = SessionManager.resolveDestination(user);
        context.go(destination);
      },
      onError: (msg) {
        if (!mounted) return;
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);
    final data = otpState.data;
    final displayPhone = otpState.phoneNumber;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Animated Back Button
              GestureDetector(
                onTap: () => context.pop(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9.w,
                      height: 9.w,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      data.headerTitle,
                      style: AppTextStyles.subheadMedium.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Animated Mini Cloche Hero
              Center(
                child: Column(
                  children: [
                    const AnimatedClocheLogo(
                      size: ClocheLogoSize.small,
                      showGlow: true,
                      showSpeedTrails: true,
                    ),
                    SizedBox(height: 1.2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.primary,
                            size: 11.sp,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            'SECURE OTP VERIFICATION',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.5.h),

              // Animated Title & Subtitle with Shield Icon
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.title,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (widget.testOtp != null && widget.testOtp!.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              final digits = widget.testOtp!.split('');
                              for (int i = 0; i < digits.length && i < _controllers.length; i++) {
                                _controllers[i].text = digits[i];
                                ref.read(otpProvider.notifier).updateDigit(i, digits[i]);
                              }
                              setState(() {});
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.touch_app_rounded, size: 10.sp, color: AppColors.primary),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Fill: ${widget.testOtp}',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${data.subtitlePrefix}${data.defaultCountryCode}$displayPhone',
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 13.5.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              color: AppColors.primary,
                              size: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.5.h),

              // Staggered Pop-in for 6 OTP Digit Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(data.otpLength, (index) {
                  final start = 0.20 + (index * 0.05);
                  final end = math.min(1.0, start + 0.25);

                  final boxAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(start, end, curve: Curves.easeOutBack),
                    ),
                  );

                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: boxAnim.value,
                        child: child,
                      );
                    },
                    child: _OtpBoxItem(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (val) => _onDigitChanged(index, val),
                      onBackspace: () => _onBackspace(index),
                    ),
                  );
                }),
              ),

              if (otpState.errorMessage != null) ...[
                SizedBox(height: 1.5.h),
                Padding(
                  padding: EdgeInsets.only(left: 1.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 14.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 1.5.w),
                      Text(
                        otpState.errorMessage!,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.5.sp,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 3.5.h),

              // Animated Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.resendPrefix,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  GestureDetector(
                    onTap: otpState.canResend
                        ? () {
                            ref.read(otpProvider.notifier).resendOtp(
                              onSuccess: () {
                                if (!mounted) return;
                                for (var c in _controllers) {
                                  c.clear();
                                }
                                _focusNodes[0].requestFocus();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'OTP resent successfully to your mobile number',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              onError: (msg) {
                                if (!mounted) return;
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
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          }
                        : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.6.h,
                      ),
                      decoration: BoxDecoration(
                        color: otpState.canResend
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!otpState.canResend) ...[
                            Icon(
                              Icons.timer_outlined,
                              size: 13.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 1.5.w),
                          ],
                          Text(
                            otpState.canResend
                                ? data.resendActionText
                                : '00:${otpState.timerSeconds.toString().padLeft(2, '0')}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 13.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Animated Verify & Proceed CTA
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
                    onPressed: otpState.isLoading ? null : _onVerifySubmitted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: otpState.isLoading
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBoxItem extends StatelessWidget {
  const _OtpBoxItem({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    final isFocused = focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 12.5.w,
      height: 7.2.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused
              ? AppColors.primary
              : (hasValue
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.border),
          width: isFocused ? 2.0 : (hasValue ? 1.5 : 1.0),
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : AppColors.cardShadow,
      ),
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              onBackspace();
            }
          },
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            cursorColor: AppColors.primary,
            style: AppTextStyles.body.copyWith(
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            decoration: const InputDecoration(
              filled: false,
              fillColor: Colors.transparent,
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }
}
