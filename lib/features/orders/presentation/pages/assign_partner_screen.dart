import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/assign_partner_provider.dart';
import '../providers/orders_page_provider.dart';

class AssignPartnerScreen extends ConsumerWidget {
  const AssignPartnerScreen({
    super.key,
    required this.orderId,
  });

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assignPartnerProvider);
    final notifier = ref.read(assignPartnerProvider.notifier);
    final partners = state.filteredPartners;

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
          state.model.title,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: TextField(
                onChanged: notifier.updateSearch,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13.5.sp,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: state.model.searchHint,
                  hintStyle: AppTextStyles.caption.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 18.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1.4.h),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              state.model.sectionHeader,
              style: AppTextStyles.body.copyWith(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            if (partners.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.delivery_dining_outlined,
                      size: 38.sp,
                      color: AppColors.textMuted.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'No Delivery Partners Nearby',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      'Available delivery fleet riders will appear here automatically when orders are ready.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...partners.map(
              (partner) {
                final isSelected = state.selectedPartnerId == partner.id;
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 13.w,
                          height: 13.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F4),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.two_wheeler_rounded,
                              color: AppColors.primary,
                              size: 18.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.name,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 0.6.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: const Color(0xFFD97706),
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${partner.rating} • ${partner.distance}',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.5.w,
                                vertical: 0.4.h,
                              ),
                              decoration: BoxDecoration(
                                color: partner.isAvailable
                                    ? AppColors.successLight
                                    : AppColors.warningLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                partner.status,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: partner.isAvailable
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                            ),
                            SizedBox(height: 1.2.h),
                            SizedBox(
                              height: 4.8.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  notifier.selectPartner(partner.id);
                                  ref.read(ordersPageProvider.notifier).markCompleted(orderId);
                                  context.pushReplacement(
                                    AppRoutes.handoverOrder,
                                    extra: orderId,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size.zero,
                                  backgroundColor: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 5.w,
                                  ),
                                ),
                                child: Text(
                                  'Assign',
                                  style: AppTextStyles.buttonMedium.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
