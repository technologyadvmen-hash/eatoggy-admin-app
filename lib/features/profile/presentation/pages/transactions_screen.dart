import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/transactions_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  void _showFilterModal(
    BuildContext context,
    String selectedType,
    void Function(String) onSelect,
  ) {
    const options = [
      'All Types',
      'Settlement',
      'Food Order',
      'Subscription',
      'Deduction',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      builder: (ctx) {
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
                  'Filter by Type',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.5.h),
                ...options.map((option) {
                  final isSelected = option == selectedType;
                  return GestureDetector(
                    onTap: () {
                      onSelect(option);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.headingPrimary,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                              size: 16.sp,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsProvider);
    final notifier = ref.read(transactionsProvider.notifier);
    final transactions = state.filteredTransactions;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => notifier.refreshTransactions(),
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
                            'Transactions',
                            style: AppTextStyles.headingPrimary.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Logs, settlements, and deductions',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Refresh',
                        onPressed: () => notifier.refreshTransactions(),
                      ),
                    ),
                  ],
                ),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceAlt,
                    ),
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => notifier.selectDateRange(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.3.h,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.primary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  state.dateRangeLabel,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.headingPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showFilterModal(
                            context,
                            state.selectedType,
                            (type) => notifier.filterByType(type),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.3.h,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                color: AppColors.primary,
                                size: 16.sp,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  state.selectedType,
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.headingPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.8.h),
                Container(
                  width: double.infinity,
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
                      Text(
                        'Withdrawable Balance',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        state.model.withdrawableBalance,
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.8.h),
                if (transactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    alignment: Alignment.center,
                    child: Text(
                      'No transactions found for selected filter.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...transactions.map((item) {
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.2.h),
                      padding: EdgeInsets.all(4.w),
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
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.title,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.headingPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceAlt,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.border,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        item.tag,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                item.amount,
                                style: AppTextStyles.h2.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: item.isCredit
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.6.h),
                          Text(
                            item.subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 0.4.h),
                          Text(
                            item.timestamp,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                if (state.canLoadMore) ...[
                  SizedBox(height: 1.h),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        final hasMore = notifier.loadMore();
                        if (!hasMore) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All transactions loaded'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        child: Text(
                          'Load More Transactions',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
