import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/revenue_earnings_provider.dart';

class RevenueEarningsScreen extends ConsumerWidget {
  const RevenueEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(revenueEarningsProvider);
    final notifier = ref.read(revenueEarningsProvider.notifier);
    final model = state.model;
    final earnings = state.activeEarnings;
    final selectedPeriod = state.selectedPeriod;

    const periods = ['Today', 'This Week', 'This Month', 'Custom'];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: notifier.refreshEarnings,
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
                            'Revenue & Earnings',
                            style: AppTextStyles.headingPrimary.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            'Finances and payouts tracker',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.2.h),
                Row(
                  children: periods.map((period) {
                    final isSelected = selectedPeriod == period;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: GestureDetector(
                          onTap: () {
                            if (period == 'Custom') {
                              notifier.selectCustomDateRange(context);
                            } else {
                              notifier.selectPeriod(period);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.1.h),
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : AppColors.surface,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.border,
                                width: 1,
                              ),
                              boxShadow: isSelected ? AppColors.cardShadow : null,
                            ),
                            child: Center(
                              child: Text(
                                period,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
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
                  width: double.infinity,
                  padding: EdgeInsets.all(4.5.w),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL EARNINGS (${earnings.periodLabel})',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        earnings.totalEarnings,
                        style: AppTextStyles.headingPrimary.copyWith(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.success,
                            size: 18.sp,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            earnings.trendText,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Earnings Breakdown',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                      _buildBreakdownRow(
                        title: 'Food Orders',
                        subtitle: earnings.foodOrdersCount,
                        amount: earnings.foodOrdersAmount,
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 8,
                        endIndent: 8,
                      ),
                      _buildBreakdownRow(
                        title: 'Subscription/Tiffin',
                        subtitle: earnings.subscriptionsCount,
                        amount: earnings.subscriptionsAmount,
                      ),
                      const Divider(
                        height: 1,
                        color: AppColors.divider,
                        indent: 8,
                        endIndent: 8,
                      ),
                      _buildBreakdownRow(
                        title: 'Packaging Charges',
                        subtitle: earnings.packagingRate,
                        amount: earnings.packagingAmount,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Last 7 Days Trend',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  height: 18.h,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: model.weeklyTrend.map((trend) {
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: trend.heightFactor,
                                  child: Container(
                                    width: 4.w,
                                    decoration: BoxDecoration(
                                      color: trend.isHighlighted
                                          ? AppColors.primary
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 1.2.h),
                            Text(
                              trend.dayLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: trend.isHighlighted
                                    ? AppColors.headingPrimary
                                    : AppColors.textSecondary,
                                fontWeight: trend.isHighlighted
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 2.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: AppTextStyles.headingPrimary.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.transactions),
                      child: Text(
                        'View All',
                        style: AppTextStyles.captionPrimary.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                if (model.transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Center(
                      child: Text(
                        'No recent transactions recorded',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  ...model.transactions.map((tx) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.2.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.8.h,
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.code,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingPrimary,
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Text(
                                '${tx.type} • ${tx.timeAgo}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            tx.amount,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: tx.isCredit
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                SizedBox(height: 3.5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.headingPrimary,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: AppTextStyles.h2.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
