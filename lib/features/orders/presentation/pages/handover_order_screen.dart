import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/orders_page_provider.dart';
import '../providers/handover_order_provider.dart';

class HandoverOrderScreen extends ConsumerStatefulWidget {
  const HandoverOrderScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<HandoverOrderScreen> createState() =>
      _HandoverOrderScreenState();
}

class _HandoverOrderScreenState extends ConsumerState<HandoverOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orders = ref.read(ordersPageProvider).ordersList;
      final matching = orders.where(
        (o) => o.id == widget.orderId || o.orderNumber == widget.orderId,
      ).firstOrNull ?? (orders.isNotEmpty ? orders.first : null);
      if (matching != null) {
        ref.read(handoverOrderProvider.notifier).initializeForOrder(matching);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(handoverOrderProvider);
    final order = state.order;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order #${order.orderNumber}',
          style: AppTextStyles.title.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStepItem(label: 'Accepted', isDone: true, isActive: false),
                  _buildStepConnector(isDone: true),
                  _buildStepItem(label: 'Preparing', isDone: true, isActive: false),
                  _buildStepConnector(isDone: true),
                  _buildStepItem(label: 'Ready', isDone: true, isActive: false),
                  _buildStepConnector(isDone: true),
                  _buildStepItem(label: 'Picked Up', isDone: true, isActive: true),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 28.sp,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              order.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading.copyWith(
                fontSize: 19.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1.2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                order.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 4.h),
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
                    'Delivery Partner Details',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.8.h),
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.two_wheeler_rounded,
                            color: AppColors.primary,
                            size: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.partnerName,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.4.h),
                            Text(
                              order.partnerVehicleNo,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 11.w,
                        height: 11.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.phone_in_talk_rounded,
                            color: AppColors.primary,
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 6.h,
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
              child: ElevatedButton(
                onPressed: () {
                  ref.read(ordersPageProvider.notifier).markCompleted(order.orderId);
                  context.go(AppRoutes.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Done',
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
    );
  }

  Widget _buildStepItem({
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.success,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 13.sp,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 1.8.w),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primary : AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isDone}) {
    return Container(
      width: 6.w,
      height: 1.5,
      margin: EdgeInsets.symmetric(horizontal: 1.8.w),
      color: AppColors.success,
    );
  }
}
