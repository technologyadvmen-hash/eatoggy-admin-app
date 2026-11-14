import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../widgets/animated_fade_slide.dart';
import '../../../../widgets/onboarding_step_header.dart';
import '../providers/business_profile_provider.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState
    extends ConsumerState<BusinessProfileScreen> {
  late final TextEditingController _restaurantNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(businessProfileProvider);

    _restaurantNameController =
        TextEditingController(text: state.restaurantName);
    _ownerNameController = TextEditingController(text: state.ownerName);
    _phoneController = TextEditingController(text: state.phone);
    _emailController = TextEditingController(text: state.email);
    _addressController = TextEditingController(text: state.address);
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onContinue() {
    ref.read(businessProfileProvider.notifier).submitProfile(
      onSuccess: () {
        if (!mounted) return;
        context.push(AppRoutes.verifyDocuments);
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BusinessProfileState>(businessProfileProvider, (previous, next) {
      if (_restaurantNameController.text.isEmpty &&
          next.restaurantName.isNotEmpty) {
        _restaurantNameController.text = next.restaurantName;
      }
      if (_ownerNameController.text.isEmpty && next.ownerName.isNotEmpty) {
        _ownerNameController.text = next.ownerName;
      }
      if (_phoneController.text.isEmpty && next.phone.isNotEmpty) {
        _phoneController.text = next.phone;
      }
      if (_emailController.text.isEmpty && next.email.isNotEmpty) {
        _emailController.text = next.email;
      }
      if (_addressController.text.isEmpty && next.address.isNotEmpty) {
        _addressController.text = next.address;
      }
    });

    final state = ref.watch(businessProfileProvider);
    final data = state.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.5.h),

              OnboardingStepHeader(
                title: data.headerTitle,
                currentStep: 1,
                totalSteps: 4,
                onBack: () => context.pop(),
              ),

              SizedBox(height: 3.h),

              AnimatedFadeSlide(
                delayMs: 80,
                child: Text(
                  data.title,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              SizedBox(height: 2.5.h),

              AnimatedFadeSlide(
                delayMs: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(data.restaurantNameLabel),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _restaurantNameController,
                      hintText: data.dummyRestaurantName,
                      onChanged: (val) => ref
                          .read(businessProfileProvider.notifier)
                          .updateRestaurantName(val),
                    ),

                    SizedBox(height: 2.2.h),

                    _buildFieldLabel(data.ownerNameLabel),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _ownerNameController,
                      hintText: data.dummyOwnerName,
                      onChanged: (val) => ref
                          .read(businessProfileProvider.notifier)
                          .updateOwnerName(val),
                    ),

                    SizedBox(height: 2.2.h),

                    _buildFieldLabel(data.businessTypeLabel),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.businessType,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 20.sp,
                          ),
                          items: data.businessTypeOptions.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(businessProfileProvider.notifier)
                                  .updateBusinessType(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.2.h),

              AnimatedFadeSlide(
                delayMs: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(data.phoneLabel),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 4.w),
                          Text(
                            data.countryCode,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              cursorColor: AppColors.primary,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              onChanged: (val) => ref
                                  .read(businessProfileProvider.notifier)
                                  .updatePhone(val),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                hintText: data.dummyPhone,
                                hintStyle: AppTextStyles.hint.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.2.h),

                    _buildFieldLabel(data.emailLabel),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _emailController,
                      hintText: data.dummyEmail,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => ref
                          .read(businessProfileProvider.notifier)
                          .updateEmail(val),
                    ),

                    SizedBox(height: 2.2.h),

                    _buildFieldLabel(data.addressLabel),
                    SizedBox(height: 1.h),
                    _buildInputField(
                      controller: _addressController,
                      hintText: data.dummyAddress,
                      maxLines: 2,
                      onChanged: (val) => ref
                          .read(businessProfileProvider.notifier)
                          .updateAddress(val),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              AnimatedFadeSlide(
                delayMs: 300,
                child: Container(
                  width: double.infinity,
                  height: 6.2.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isLoading
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
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.label.copyWith(
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: AppColors.primary,
        style: AppTextStyles.body.copyWith(
          fontSize: 14.5.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hintText: hintText,
          hintStyle: AppTextStyles.hint.copyWith(
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 1.8.h),
        ),
      ),
    );
  }
}
