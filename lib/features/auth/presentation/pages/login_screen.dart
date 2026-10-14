import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../widgets/animated_cloche_logo.dart';
import '../providers/login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _heroSlide;
  late final Animation<double> _heroScale;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _cardSlide;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _buttonSlide;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _footerOpacity;

  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    final currentPhone = ref.read(loginProvider).phoneNumber;
    if (currentPhone.isNotEmpty) {
      _phoneController.text = currentPhone;
    }

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1300),
      vsync: this,
    );

    // Staggered choreographed entrance
    _heroSlide = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOutBack),
      ),
    );

    _heroScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _titleSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.20, 0.60, curve: Curves.easeIn),
      ),
    );

    _cardSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.40, 0.75, curve: Curves.easeIn),
      ),
    );

    _buttonSlide = Tween<double>(begin: 25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
      ),
    );

    _footerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onLoginSubmitted() {
    final notifier = ref.read(loginProvider.notifier);
    if (_phoneController.text.trim().isNotEmpty) {
      notifier.updatePhoneNumber(_phoneController.text.trim());
    }
    notifier.loginWithOtp(
      onSuccess: (testOtp) {
        if (!mounted) return;
        final cleanNumber = ref.read(loginProvider).sanitizedPhoneNumber;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'OTP sent successfully to your mobile number',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
        context.push(
          AppRoutes.otp,
          extra: {'phone': cleanNumber, 'testOtp': testOtp},
        );
      },
      onError: (errorMessage) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
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

  void _onRegisterTap() {
    context.push(AppRoutes.register);
  }

  void _fillDemoPhone() {
    _phoneController.text = '9999999999';
    ref.read(loginProvider.notifier).updatePhoneNumber('9999999999');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final data = loginState.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 2.h),

                      // 1. Centered Hero Animated Cloche Logo Showcase
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
                        child: Column(
                          children: [
                            const AnimatedClocheLogo(
                              size: ClocheLogoSize.large,
                              showGlow: true,
                              showSpeedTrails: true,
                            ),
                            SizedBox(height: 1.5.h),

                            // Partner Pill Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
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
                                    color: AppColors.primary.withValues(alpha: 0.10),
                                    blurRadius: 10,
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
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 1.5.w),
                                  Text(
                                    'EATOGGY PARTNER PORTAL',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // 2. Animated Title & Subtitle
                      AnimatedBuilder(
                        animation: _animController,
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
                          children: [
                            Text(
                              data.title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Text(
                              data.subtitle,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 13.sp,
                                color: AppColors.textMuted,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // 3. Animated Phone Input Card
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _cardSlide.value),
                            child: Opacity(
                              opacity: _cardOpacity.value.clamp(0.0, 1.0),
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
                                  data.phoneInputLabel,
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                // 1-Tap Demo Auto-Fill Pill
                                GestureDetector(
                                  onTap: _fillDemoPhone,
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.5.w,
                                      vertical: 0.4.h,
                                    ),
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
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 11.sp,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'Demo: 9999999999',
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
                            SizedBox(height: 1.h),

                            // Elevated Input Container with dynamic focus glow
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: loginState.errorMessage != null
                                      ? AppColors.error
                                      : (_focusNode.hasFocus
                                          ? AppColors.primary
                                          : AppColors.border),
                                  width: _focusNode.hasFocus ? 1.8 : 1.0,
                                ),
                                boxShadow: _focusNode.hasFocus
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : AppColors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 3.5.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.5.w,
                                      vertical: 0.8.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '🇮🇳',
                                          style: TextStyle(fontSize: 13.sp),
                                        ),
                                        SizedBox(width: 1.5.w),
                                        Text(
                                          data.countryCode,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      focusNode: _focusNode,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.done,
                                      cursorColor: AppColors.primary,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: 1.2,
                                      ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      onChanged: (value) {
                                        ref
                                            .read(loginProvider.notifier)
                                            .updatePhoneNumber(value);
                                      },
                                      onFieldSubmitted: (_) => _onLoginSubmitted(),
                                      decoration: InputDecoration(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        hintText: 'Enter 10-digit number',
                                        hintStyle: AppTextStyles.hint.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 13.sp,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 1.8.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (loginState.phoneNumber.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        Icons.cancel_rounded,
                                        size: 18.sp,
                                        color: AppColors.textMuted,
                                      ),
                                      onPressed: () {
                                        _phoneController.clear();
                                        ref
                                            .read(loginProvider.notifier)
                                            .updatePhoneNumber('');
                                      },
                                    ),
                                  SizedBox(width: 2.w),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (loginState.errorMessage != null) ...[
                        SizedBox(height: 1.2.h),
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
                              Expanded(
                                child: Text(
                                  loginState.errorMessage!,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: 3.h),

                      // 4. Animated CTA Button with Spring Feedback & Glow
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
                        child: AnimatedScale(
                          scale: _isButtonPressed ? 0.96 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            width: double.infinity,
                            height: 6.2.h,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: loginState.isLoading
                                  ? null
                                  : _onLoginSubmitted,
                              onHover: (hovered) {
                                if (_isButtonPressed != hovered) {
                                  setState(() => _isButtonPressed = hovered);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: loginState.isLoading
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
                                          Icons.arrow_forward_rounded,
                                          size: 18.sp,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // 5. Quick Trust Value Props
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _footerOpacity.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTrustPill(
                              Icons.verified_user_rounded,
                              'Verified Partner',
                            ),
                            SizedBox(width: 2.w),
                            _buildTrustPill(
                              Icons.bolt_rounded,
                              'Instant Orders',
                            ),
                            SizedBox(width: 2.w),
                            _buildTrustPill(
                              Icons.account_balance_wallet_rounded,
                              'Daily Payout',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // 6. Animated Footer Registration Link
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _footerOpacity.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 2.h, top: 1.5.h),
                          child: Center(
                            child: GestureDetector(
                              onTap: _onRegisterTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 1.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    text: '${data.newRestaurantText} ',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: data.registerText,
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 13.5.sp,
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrustPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: AppColors.primary),
          SizedBox(width: 1.2.w),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
