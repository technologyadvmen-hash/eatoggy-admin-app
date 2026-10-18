import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../widgets/animated_fade_slide.dart';
import '../../../../widgets/onboarding_step_header.dart';
import '../providers/review_application_provider.dart';

class ReviewApplicationScreen extends ConsumerStatefulWidget {
  const ReviewApplicationScreen({super.key});

  @override
  ConsumerState<ReviewApplicationScreen> createState() =>
      _ReviewApplicationScreenState();
}

class _ReviewApplicationScreenState
    extends ConsumerState<ReviewApplicationScreen> {
  void _onSubmit() {
    ref.read(reviewApplicationProvider.notifier).submitApplication(
      onSuccess: () {
        if (!mounted) return;
        context.push(AppRoutes.applicationSubmitted);
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

  void _showImageSourceDialog(
    BuildContext context,
    void Function(ImageSource) onSourceSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Kitchen Photo Source',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: Text(
                  'Take Photo with Camera',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSourceSelected(ImageSource.camera);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onSourceSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewApplicationProvider);
    final notifier = ref.read(reviewApplicationProvider.notifier);
    final data = state.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: OnboardingStepHeader(
                title: data.screenTitle,
                currentStep: 4,
                totalSteps: 4,
                onBack: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.5.h),
                    AnimatedFadeSlide(
                      delayMs: 80,
                      child: Text(
                        data.headingText,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    AnimatedFadeSlide(
                      delayMs: 120,
                      child: _buildBusinessCard(context, data),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedFadeSlide(
                      delayMs: 170,
                      child: _buildDocumentsCard(context, data),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedFadeSlide(
                      delayMs: 220,
                      child: _buildBankCard(context, data),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedFadeSlide(
                      delayMs: 270,
                      child: _buildKitchenHygieneCard(context, state, notifier),
                    ),
                    SizedBox(height: 2.h),
                    AnimatedFadeSlide(
                      delayMs: 320,
                      child: _buildFeeCard(context, data),
                    ),
                    SizedBox(height: 3.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
              child: AnimatedFadeSlide(
                delayMs: 380,
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
                    onPressed: state.isLoading ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              if (state.statusMessage != null) ...[
                                SizedBox(width: 3.w),
                                Text(
                                  state.statusMessage!,
                                  style: AppTextStyles.buttonLarge.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ],
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
                                Icons.verified_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessCard(BuildContext context, dynamic data) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.businessTitle,
                style: AppTextStyles.subhead.copyWith(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.edit_square,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Text(
            data.restaurantName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            data.businessSubtext,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.5.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(BuildContext context, dynamic data) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.documentsTitle,
            style: AppTextStyles.subhead.copyWith(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...((data.documentsList as List<String>).map(
            (doc) => Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.5.w),
                  Text(
                    doc,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBankCard(BuildContext context, dynamic data) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.bankTitle,
                style: AppTextStyles.subhead.copyWith(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.edit_square,
                  color: AppColors.primary,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Text(
            data.bankInfo,
            style: AppTextStyles.body.copyWith(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(BuildContext context, dynamic data) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.feeTitle,
                  style: AppTextStyles.subhead.copyWith(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  data.feeSubtext,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.feeAmount,
            style: AppTextStyles.title.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenHygieneCard(
    BuildContext context,
    ReviewApplicationState state,
    ReviewApplicationNotifier notifier,
  ) {
    final hasMainPrep = state.kitchenMainPrepPath != null;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasMainPrep
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.soup_kitchen_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Kitchen Hygiene Proof',
                    style: AppTextStyles.subhead.copyWith(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (hasMainPrep)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 13.sp,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Attached',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Photo of your main cooking/prep station is required for hygiene clearance.',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 1.8.h),
          GestureDetector(
            onTap: () => _showImageSourceDialog(
              context,
              (source) => notifier.pickKitchenMainPrep(source),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasMainPrep
                      ? AppColors.primary
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (hasMainPrep)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(state.kitchenMainPrepPath!),
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasMainPrep
                              ? 'Main Prep Station Attached'
                              : 'Upload Main Prep Station *',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          hasMainPrep
                              ? 'Tap to change photo'
                              : 'Required • Camera or Gallery',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    hasMainPrep
                        ? Icons.edit_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
