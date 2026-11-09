import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final model = state.model;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 4.w, top: 1.h, bottom: 1.h),
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.headingPrimary,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          model.title,
          style: AppTextStyles.title.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.headingPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Refresh',
            onPressed: () => notifier.refreshNotifications(),
          ),
          if (model.sections.isNotEmpty)
            TextButton(
              onPressed: () {
                notifier.markAllRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text(
                model.actionText,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => notifier.refreshNotifications(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surfaceAlt,
                  ),
                ),
              if (model.sections.isEmpty && !state.isLoading)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 32.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2.5.h),
                      Text(
                        'No Notifications Yet',
                        style: AppTextStyles.headingPrimary.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          "You'll see alerts here when new food orders, tiffin deliveries, reviews, or payouts arrive.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                ...model.sections.map((section) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.sectionTitle,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      ...section.items.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 1.5.h),
                          child: GestureDetector(
                            onTap: () => notifier.markItemRead(item.id),
                            child: Container(
                              width: double.infinity,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      if (item.isUnread) ...[
                                        Container(
                                          width: 2.2.w,
                                          height: 2.2.w,
                                          margin:
                                              EdgeInsets.only(right: 2.5.w),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.headingPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 0.8.h),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: item.isUnread ? 4.7.w : 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.description,
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            fontSize: 11.5.sp,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                        SizedBox(height: 0.8.h),
                                        Text(
                                          item.timeAgo,
                                          style:
                                              AppTextStyles.caption.copyWith(
                                            fontSize: 11.sp,
                                            color: AppColors.textMuted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 1.h),
                    ],
                  );
                }),
                SizedBox(height: 3.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
