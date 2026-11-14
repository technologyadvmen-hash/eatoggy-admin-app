import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/menu_management_provider.dart';

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menuManagementProvider);
    final notifier = ref.read(menuManagementProvider.notifier);
    final model = state.model;
    final categories = state.filteredCategories;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          icon: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 20.sp,
          ),
          label: Text(
            'Add Category',
            style: AppTextStyles.buttonMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            context.push(AppRoutes.addCategory);
          },
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: notifier.refreshCategories,
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
                      onTap: () {
                        if (Navigator.of(context).canPop()) {
                          context.pop();
                        }
                      },
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
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
                            model.title,
                            style: AppTextStyles.heading.copyWith(
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
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),
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
                      hintText: model.searchHint,
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
                SizedBox(height: 2.5.h),
                if (state.isLoading && categories.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: const CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (categories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 38.sp,
                          color: AppColors.textMuted.withValues(alpha: 0.6),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          state.searchQuery.isNotEmpty
                              ? 'No Matching Categories'
                              : 'No Menu Categories Yet',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.6.h),
                        Text(
                          state.searchQuery.isNotEmpty
                              ? 'Try searching with a different term'
                              : 'Tap "+ Add Category" below to create your first category',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...categories.map(
                    (category) => Padding(
                      padding: EdgeInsets.only(bottom: 1.8.h),
                      child: GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.categoryItems, extra: category.id);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.5.w,
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 13.w,
                                height: 13.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBF9F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Center(
                                  child: Text(
                                    category.iconEmoji,
                                    style: TextStyle(fontSize: 18.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.5.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category.title,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 0.4.h),
                                    Text(
                                      category.itemCountText,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 12.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: 0.85,
                                child: Switch(
                                  value: category.isEnabled,
                                  onChanged: (val) {
                                    notifier.toggleCategory(category.id, val);
                                  },
                                  activeTrackColor: AppColors.success,
                                  activeThumbColor: Colors.white,
                                  inactiveTrackColor: AppColors.border,
                                  inactiveThumbColor: AppColors.textMuted,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              GestureDetector(
                                onTap: () {
                                  context.push(AppRoutes.addCategory, extra: category);
                                },
                                child: Container(
                                  width: 9.w,
                                  height: 9.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.edit_outlined,
                                      color: AppColors.primary,
                                      size: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

