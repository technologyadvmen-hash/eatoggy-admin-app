import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/tiffin_deliveries_model.dart';
import '../providers/subscriber_card_provider.dart';

class SubscriberCardScreen extends ConsumerStatefulWidget {
  const SubscriberCardScreen({
    super.key,
    required this.item,
  });

  final DeliveryMealItem item;

  @override
  ConsumerState<SubscriberCardScreen> createState() =>
      _SubscriberCardScreenState();
}

class _SubscriberCardScreenState extends ConsumerState<SubscriberCardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(subscriberCardProvider.notifier)
          .initializeForCustomer(widget.item);
    });
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Cancel Subscription?',
          style: AppTextStyles.headingPrimary.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.error,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel the meal subscription for ${widget.item.customerName}?',
          style: AppTextStyles.body.copyWith(
            fontSize: 13.sp,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Subscription',
              style: AppTextStyles.captionMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription cancelled successfully.'),
                  backgroundColor: AppColors.error,
                ),
              );
              context.pop();
            },
            child: Text(
              'Cancel Plan',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriberCardProvider);
    final notifier = ref.read(subscriberCardProvider.notifier);
    final model = state.model;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
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
                                model.customerName,
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
                        border: Border.all(
                          color: AppColors.border,
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
                              Text(
                                model.planTitle,
                                style: AppTextStyles.headingPrimary.copyWith(
                                  fontSize: 15.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.5.w,
                                  vertical: 0.4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: state.isPaused
                                      ? AppColors.warningBg
                                      : AppColors.successBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: state.isPaused
                                            ? AppColors.warning
                                            : AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      model.statusText,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: state.isPaused
                                            ? AppColors.warning
                                            : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            model.durationText,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          Divider(
                            color: AppColors.border,
                            height: 1,
                          ),
                          SizedBox(height: 1.5.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Days Remaining',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12.5.sp,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                model.daysRemainingText,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
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
                            'DELIVERY ADDRESS',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMuted,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            model.deliveryAddress,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
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
                            'SPECIAL INSTRUCTIONS',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.warning,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            model.specialInstructions,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Text(
                      'Delivery History (Last 7 Days)',
                      style: AppTextStyles.headingPrimary.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    ...model.history.map((h) {
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 1.2.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.5.w,
                          vertical: 1.5.h,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              h.dateText,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  h.statusText,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: h.isDelivered
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                                SizedBox(width: 1.5.w),
                                Icon(
                                  h.isDelivered
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  size: 14.sp,
                                  color: h.isDelivered
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 5.8.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              notifier.togglePausePlan();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.isPaused
                                        ? 'Subscription resumed!'
                                        : 'Subscription paused!',
                                  ),
                                  backgroundColor: state.isPaused
                                      ? AppColors.success
                                      : AppColors.warning,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.pause_rounded,
                              color: AppColors.textPrimary,
                              size: 16.sp,
                            ),
                            label: Text(
                              state.isPaused ? 'Resume Plan' : 'Pause Plan',
                              style: AppTextStyles.buttonMedium.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Container(
                          height: 5.8.h,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => notifier.callPartner(),
                            icon: Icon(
                              Icons.call_outlined,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            label: Text(
                              'Call Partner',
                              style: AppTextStyles.buttonMedium.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  SizedBox(
                    width: double.infinity,
                    height: 5.8.h,
                    child: OutlinedButton(
                      onPressed: () => _showCancelSubscriptionDialog(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.error,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        backgroundColor: AppColors.surface,
                      ),
                      child: Text(
                        'Cancel Subscription',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
