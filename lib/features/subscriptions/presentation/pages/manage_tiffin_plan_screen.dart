import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/manage_tiffin_plan_provider.dart';

class ManageTiffinPlanScreen extends ConsumerStatefulWidget {
  const ManageTiffinPlanScreen({
    super.key,
    required this.programId,
  });

  final String programId;

  @override
  ConsumerState<ManageTiffinPlanScreen> createState() =>
      _ManageTiffinPlanScreenState();
}

class _ManageTiffinPlanScreenState
    extends ConsumerState<ManageTiffinPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(manageTiffinPlanProvider.notifier)
          .initializeForProgram(widget.programId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manageTiffinPlanProvider);
    final notifier = ref.read(manageTiffinPlanProvider.notifier);
    final model = state.model;
    final subscribers = state.filteredSubscribers;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.primary,
                          size: 15.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.planTitle,
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontSize: 17.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          model.subtitle,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.5.w),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.priceTitle,
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: state.isPaused
                                ? AppColors.warningBg
                                : AppColors.successBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.isPaused ? 'PAUSED' : 'ACTIVE',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: state.isPaused
                                  ? AppColors.warning
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    Row(
                      children: [
                        Text('🕒', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Delivery window: ',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.5.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          model.deliveryWindow,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Row(
                      children: [
                        Text('🍲', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 1.5.w),
                        Text(
                          'Meal setup: ',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.5.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          model.mealSetup,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.5.h),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 5.2.h,
                            child: ElevatedButton(
                              onPressed: () {
                                notifier.togglePausePlan();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      state.isPaused
                                          ? 'Plan has been paused!'
                                          : 'Plan has been resumed!',
                                    ),
                                    backgroundColor: state.isPaused
                                        ? AppColors.warning
                                        : AppColors.success,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                elevation: 0,
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                state.isPaused ? 'Resume Plan' : 'Pause Plan',
                                style: AppTextStyles.buttonMedium.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.5.w),
                        Expanded(
                          child: SizedBox(
                            height: 5.2.h,
                            child: ElevatedButton(
                              onPressed: () {
                                context.push(AppRoutes.createTiffinPlan);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                elevation: 0,
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Edit Details',
                                style: AppTextStyles.buttonMedium.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscribers (${model.subscribersCount})',
                    style: AppTextStyles.headingPrimary.copyWith(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => notifier.toggleSearch(),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.isSearchActive) ...[
                SizedBox(height: 1.5.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: TextField(
                    onChanged: notifier.updateSearch,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search subscriber by name or phone...',
                      hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 1.8.h),
              if (subscribers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
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
                    child: Text(
                      'No subscribers enrolled in this plan yet',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ...subscribers.map((sub) {
                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 1.5.h),
                    padding: EdgeInsets.all(3.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 11.w,
                          height: 11.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              sub.avatarLetter,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 0.4.h),
                              Text(
                                sub.phone,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Ends in ${sub.endsInDays} days',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11.5.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.3.h,
                              ),
                              decoration: BoxDecoration(
                                color: sub.isActive
                                    ? AppColors.successBg
                                    : AppColors.warningBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                sub.status,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: sub.isActive
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
