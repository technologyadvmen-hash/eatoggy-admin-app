import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/orders_page_model.dart';
import '../providers/orders_page_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ordersPageProvider);
    final notifier = ref.read(ordersPageProvider.notifier);
    final data = state.data;
    final ordersList = state.filteredOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 1.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.8.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Row(
                children: state.filterTabsWithCounts.map((tab) {
                  final isSelected = state.activeFilter == tab.id;
                  return Padding(
                    padding: EdgeInsets.only(right: 2.5.w),
                    child: GestureDetector(
                      onTap: () => notifier.selectFilter(tab.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.1.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : AppColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Text(
                              tab.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (tab.badgeCount > 0) ...[
                              SizedBox(width: 1.8.w),
                              Container(
                                width: 2.3.h,
                                height: 2.3.h,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${tab.badgeCount}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: notifier.refreshOrders,
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: ordersList.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 38.sp,
                                      color: AppColors.textMuted,
                                    ),
                                    SizedBox(height: 1.8.h),
                                    Text(
                                      state.activeFilter == 'all'
                                          ? 'No Orders Yet'
                                          : 'No ${state.activeFilter[0].toUpperCase()}${state.activeFilter.substring(1)} Orders',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 0.8.h),
                                    Text(
                                      'Incoming customer orders will appear here in real-time.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textMuted,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        itemCount: ordersList.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.8.h),
                        itemBuilder: (context, index) {
                          final order = ordersList[index];
                          return _buildOrderCard(context, order, notifier);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    OrderItemDetail order,
    OrdersPageNotifier notifier,
  ) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.orderDetail, extra: order.id),
      child: Container(
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
              children: [
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '  •  ${order.timeAgo}',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  order.amount,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.2.h),
            const Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 1.2.h),
            Text(
              order.customerName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 0.6.h),
            ...order.itemsList.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 0.4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (order.status == 'New') ...[
              SizedBox(height: 1.8.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 5.h,
                      child: OutlinedButton(
                        onPressed: () =>
                            _showRejectOrderDialog(context, order.id, notifier),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: AppTextStyles.buttonMedium.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.5.w),
                  Expanded(
                    child: Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          await notifier.acceptOrder(order.id,
                              estimatedPrepTime: 20);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Order accepted! Cooking time set to 20 mins.'),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            context.push(AppRoutes.orderDetail, extra: order.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: AppTextStyles.buttonMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == 'Preparing') ...[
              SizedBox(height: 1.8.h),
              Container(
                width: double.infinity,
                height: 5.h,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => notifier.markReady(order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Mark Ready',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRejectOrderDialog(
    BuildContext context,
    String orderId,
    OrdersPageNotifier notifier,
  ) {
    String selectedReason = 'OUT_OF_STOCK';
    final reasons = [
      {'code': 'OUT_OF_STOCK', 'label': 'Item Not Available / Out of Stock'},
      {'code': 'KITCHEN_BUSY', 'label': 'Kitchen at Peak Capacity'},
      {'code': 'CLOSING_SOON', 'label': 'Restaurant Closing Soon'},
      {'code': 'OTHER', 'label': 'Other Operational Reason'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Select Rejection Reason',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    ...reasons.map((r) {
                      final isSelected = r['code'] == selectedReason;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedReason = r['code']!;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.errorLight
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.error
                                  : AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r['label']!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 12.5.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 1.5.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        minimumSize: Size(double.infinity, 5.2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final selectedItem = reasons.firstWhere(
                            (r) => r['code'] == selectedReason);
                        notifier.rejectOrder(
                          orderId,
                          reasonCode: selectedReason,
                          reasonNote: selectedItem['label']!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Order rejected: ${selectedItem['label']}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      child: Text(
                        'Confirm Reject & Refund',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
