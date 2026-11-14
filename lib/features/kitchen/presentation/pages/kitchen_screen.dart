import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/kitchen_provider.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(kitchenProvider);
    final notifier = ref.read(kitchenProvider.notifier);
    final model = state.model;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1.5.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 8.w,
                          height: 8.w,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.5.w),
                      Text(
                        model.appName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        state.isOnline ? 'ONLINE' : 'OFFLINE',
                        style: AppTextStyles.captionMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: state.isOnline
                              ? AppColors.success
                              : AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 1.5.w),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: state.isOnline,
                          onChanged: notifier.toggleOnline,
                          activeTrackColor: const Color(0xFF22C55E),
                          activeThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.border,
                          inactiveThumbColor: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3.5.h, horizontal: 5.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: state.isOnline
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 5.5.w,
                          height: 5.5.w,
                          decoration: BoxDecoration(
                            color: state.isOnline
                                ? const Color(0xFF22C55E)
                                : AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (state.isOnline
                                        ? const Color(0xFF22C55E)
                                        : AppColors.error)
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.isOnline
                          ? model.onlineStatusTitle
                          : 'Kitchen is Currently Offline',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      model.onlineStatusSubtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    const Divider(color: AppColors.divider, height: 1),
                    SizedBox(height: 2.5.h),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'TOTAL HOURS',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              Text(
                                model.totalHours,
                                style: AppTextStyles.heading.copyWith(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 5.h,
                          color: AppColors.divider,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'ACTIVE QUEUE',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(height: 0.8.h),
                              Text(
                                model.activeQueue,
                                style: AppTextStyles.heading.copyWith(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.5.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acceptance Settings',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Auto-accept subscription requests',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: state.autoAcceptSubscription,
                            onChanged: notifier.toggleAutoAccept,
                            activeTrackColor: const Color(0xFF22C55E),
                            activeThumbColor: Colors.white,
                            inactiveTrackColor: AppColors.border,
                            inactiveThumbColor: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.5.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Offline Schedule',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily closing time',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          model.dailyClosingTime,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Afternoon break slot',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          model.afternoonBreakSlot,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () => context.push(AppRoutes.kitchenHygiene),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.5.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
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
                        child: const Center(
                          child: Icon(
                            Icons.clean_hands_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kitchen Hygiene Proof',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              'Submit daily hygiene photos & compliance',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11.5.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                width: double.infinity,
                height: 5.8.h,
                child: ElevatedButton(
                  onPressed: () {
                    final nextStatus = !state.isOnline;
                    notifier.toggleOnline(nextStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Kitchen status updated to ${nextStatus ? 'Online' : 'Offline'}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isOnline
                        ? AppColors.error
                        : const Color(0xFF15803D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    state.isOnline ? 'Go Offline Now' : 'Go Online Now',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
}
