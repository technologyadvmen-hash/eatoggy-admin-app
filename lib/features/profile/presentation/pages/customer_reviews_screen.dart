import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/customer_reviews_model.dart';
import '../providers/customer_reviews_provider.dart';

class CustomerReviewsScreen extends ConsumerStatefulWidget {
  const CustomerReviewsScreen({
    super.key,
    this.initialModel,
  });

  final CustomerReviewsListModel? initialModel;

  @override
  ConsumerState<CustomerReviewsScreen> createState() =>
      _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends ConsumerState<CustomerReviewsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(customerReviewsProvider.notifier)
            .initializeWithModel(widget.initialModel!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerReviewsProvider);
    final notifier = ref.read(customerReviewsProvider.notifier);
    final reviews = state.model.reviews;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: notifier.refreshReviews,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.headingPrimary,
                            size: 18.sp,
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
                            'Customer Reviews',
                            style: AppTextStyles.headingPrimary.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Recent testimonials & replies',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),
                if (reviews.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 38.sp,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          'No Customer Reviews Yet',
                          style: AppTextStyles.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingPrimary,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          'Reviews and ratings submitted by your customers will appear here.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...reviews.map((item) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.8.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: item.isCritical
                              ? AppColors.error.withValues(alpha: 0.3)
                              : AppColors.border,
                          width: 1,
                        ),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingPrimary,
                                ),
                              ),
                              if (item.isCritical) ...[
                                SizedBox(width: 2.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.error.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Critical',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                item.timeAgo,
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.8.h),
                          Row(
                            children: List.generate(5, (index) {
                              if (index < item.rating) {
                                return Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFF59E0B),
                                  size: 16.sp,
                                );
                              }
                              return Icon(
                                Icons.star_outline_rounded,
                                color: AppColors.border,
                                size: 16.sp,
                              );
                            }),
                          ),
                          SizedBox(height: 1.2.h),
                          Text(
                            item.comment,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 13.sp,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                          if (item.partnerReply != null) ...[
                            SizedBox(height: 1.2.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Reply',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(height: 0.3.h),
                                  Text(
                                    item.partnerReply!,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 12.sp,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (item.orderedItem != null || item.canReply) ...[
                            SizedBox(height: 1.4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.orderedItem != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.5.w,
                                      vertical: 0.6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      item.orderedItem!,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 11.5.sp,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                if (item.canReply)
                                  GestureDetector(
                                    onTap: () => context.push(
                                      AppRoutes.respondToReview,
                                      extra: item,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.5.w,
                                        vertical: 0.9.h,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Reply',
                                        style: AppTextStyles.buttonMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
