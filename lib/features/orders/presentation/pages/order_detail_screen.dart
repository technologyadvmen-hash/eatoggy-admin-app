import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/order_detail_provider.dart';
import '../providers/orders_page_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(orderDetailProvider(orderId));
    final model = detailState.orderDetail;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order #${model.orderNumber}',
          style: AppTextStyles.title.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.5.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STATUS',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 0.6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          model.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  const Divider(color: AppColors.divider, height: 1),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              model.customerName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              model.customerAddress,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 11.w,
                        height: 11.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 1),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.phone_in_talk_rounded,
                            color: AppColors.primary,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              'Select Preparation Time',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14.5.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: model.prepTimeOptions.map((time) {
                final isSelected = detailState.selectedPrepTime == time;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(orderPrepTimeProvider.notifier)
                            .setPrepTime(orderId, time);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 5.2.h,
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppColors.primaryGradient : null,
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
                        child: Center(
                          child: Text(
                            '$time min',
                            style: AppTextStyles.buttonMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 12.5.sp,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                    'Items List',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.8.h),
                  ...model.items.map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: _buildItemRow(
                        qty: item.qty,
                        title: item.title,
                        subtitle: item.subtitle,
                        price: item.price,
                      ),
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
                children: [
                  _buildBillRow('Item Total', model.itemTotal),
                  SizedBox(height: 1.2.h),
                  _buildBillRow('GST (5%)', model.gst),
                  SizedBox(height: 1.2.h),
                  _buildBillRow('Packaging charges', model.packagingCharges),
                  SizedBox(height: 1.2.h),
                  _buildBillRow('Delivery Partner Fee', model.deliveryFee),
                  SizedBox(height: 1.5.h),
                  const Divider(color: AppColors.divider, height: 1),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grand Total',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        model.grandTotal,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 5.5.h,
                    child: OutlinedButton(
                      onPressed: () {
                        _showRejectOrderDialog(context, ref, model.id);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Reject Order',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Container(
                    height: 5.5.h,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(ordersPageProvider.notifier)
                            .acceptOrder(model.id, estimatedPrepTime: 20);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Order Accepted successfully! Cooking timer: 20m'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          context.pushReplacement(AppRoutes.preparingOrder,
                              extra: model.id);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Accept Order',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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

  Widget _buildItemRow({
    required String qty,
    required String title,
    required String subtitle,
    required String price,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            qty,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11.5.sp,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: 0.3.h),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          price,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showRejectOrderDialog(
      BuildContext context, WidgetRef ref, String orderId) {
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
                        ref.read(ordersPageProvider.notifier).rejectOrder(
                              orderId,
                              reasonCode: selectedReason,
                              reasonNote: selectedItem['label']!,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Order rejected: ${selectedItem['label']}'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        context.pop();
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
