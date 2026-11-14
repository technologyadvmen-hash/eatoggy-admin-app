import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/orders_page_provider.dart';
import '../providers/preparing_order_provider.dart';

class PreparingOrderScreen extends ConsumerStatefulWidget {
  const PreparingOrderScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  ConsumerState<PreparingOrderScreen> createState() =>
      _PreparingOrderScreenState();
}

class _PreparingOrderScreenState extends ConsumerState<PreparingOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orders = ref.read(ordersPageProvider).ordersList;
      final matching = orders.firstWhere(
        (o) => o.id == widget.orderId || o.orderNumber == widget.orderId,
        orElse: () => ref.read(ordersPageProvider).ordersList.first,
      );
      ref.read(preparingOrderProvider.notifier).initializeForOrder(matching);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preparingOrderProvider);
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
          'Preparing Order #${order.orderNumber}',
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStepItem(
                    label: 'Accepted',
                    isDone: true,
                    isActive: false,
                  ),
                  _buildStepConnector(isDone: true),
                  _buildStepItem(
                    label: 'Preparing',
                    isDone: true,
                    isActive: true,
                  ),
                  _buildStepConnector(isDone: false),
                  _buildStepItem(
                    label: 'Ready',
                    isDone: false,
                    isActive: false,
                  ),
                  _buildStepConnector(isDone: false),
                  _buildStepItem(
                    label: 'Picked Up',
                    isDone: false,
                    isActive: false,
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Text(
                    'PREPARATION TIME REMAINING',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    state.formattedTime,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    order.acceptingMoreOrdersText,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),
            Container(
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
                  Text(
                    'Item Preparation Checklist',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ...order.checklist.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 1.4.h),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(preparingOrderProvider.notifier)
                              .toggleItemCheck(item.id);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: item.isDone
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: item.isDone
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 1.2,
                                ),
                              ),
                              child: item.isDone
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 14.sp,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(width: 3.5.w),
                            Expanded(
                              child: Text(
                                item.title,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: item.isDone
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  decoration: item.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.5.h),
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
                  ref
                      .read(ordersPageProvider.notifier)
                      .markReady(order.orderId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order marked as Ready!'),
                    ),
                  );
                  context.pushReplacement(AppRoutes.readyOrder, extra: order.orderId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Mark as Ready',
                  style: AppTextStyles.buttonMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 5.6.h,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling customer ${order.customerPhone}...'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Call Customer',
                        style: AppTextStyles.buttonMedium.copyWith(
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
                    height: 5.6.h,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling delivery partner ${order.deliveryPartnerPhone}...'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Call Partner',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
    Color circleColor;
    Color borderColor;
    Color textColor;

    if (isActive) {
      circleColor = AppColors.primary;
      borderColor = AppColors.primary;
      textColor = AppColors.primary;
    } else if (isDone) {
      circleColor = AppColors.success;
      borderColor = AppColors.success;
      textColor = AppColors.success;
    } else {
      circleColor = AppColors.surface;
      borderColor = AppColors.border;
      textColor = AppColors.textMuted;
    }

    return Row(
      children: [
        Container(
          width: 5.w,
          height: 5.w,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: (isDone || isActive)
                ? Icon(
                    Icons.check_rounded,
                    size: 13.sp,
                    color: Colors.white,
                  )
                : Container(
                    width: 1.8.w,
                    height: 1.8.w,
                    decoration: const BoxDecoration(
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        SizedBox(width: 1.8.w),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
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
      color: isDone ? AppColors.success : AppColors.border,
    );
  }
}
