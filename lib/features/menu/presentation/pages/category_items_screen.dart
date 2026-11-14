import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/category_items_provider.dart';

class CategoryItemsScreen extends ConsumerWidget {
  const CategoryItemsScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryItemsProvider(categoryId));
    final model = state.model;
    final items = model.items;

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
            'Add New Item',
            style: AppTextStyles.buttonMedium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            context.push(AppRoutes.addMenuItem);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          model.categoryName,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 17.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          model.itemsCountSubtitle,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.addCategory, extra: model.categoryName);
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
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),
              if (items.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.4.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toggle All Items (Online Status)',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: state.toggleAll,
                          onChanged: (val) {
                            ref
                                .read(categoryItemsStatusProvider.notifier)
                                .setAllStatus(
                                  model.categoryId,
                                  items.map((i) => i.id).toList(),
                                  val,
                                );
                          },
                          activeTrackColor: AppColors.success,
                          activeThumbColor: Colors.white,
                          inactiveTrackColor: AppColors.border,
                          inactiveThumbColor: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),
              ],
              if (items.isEmpty)
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
                        Icons.lunch_dining_rounded,
                        size: 40.sp,
                        color: AppColors.textMuted.withValues(alpha: 0.6),
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'No Items in this Category',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.6.h),
                      Text(
                        'Tap "+ Add New Item" below to add food items to this category.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 1.8.h),
                  child: Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF9F5),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFFFBF9F5),
                                    child: Center(
                                      child: Icon(
                                        Icons.restaurant_rounded,
                                        color: AppColors.textMuted,
                                        size: 18.sp,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.5.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 3.5.w,
                                    height: 3.5.w,
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: item.isVeg
                                            ? AppColors.veg
                                            : AppColors.nonVeg,
                                        width: 1.2,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: item.isVeg
                                              ? AppColors.veg
                                              : AppColors.nonVeg,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.8.h),
                              Text(
                                item.price,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: item.isAvailable,
                            onChanged: (val) {
                              ref
                                  .read(categoryItemsStatusProvider.notifier)
                                  .setItemStatus(
                                    model.categoryId,
                                    item.id,
                                    val,
                                  );
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
                            context.push(AppRoutes.addMenuItem, extra: item);
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
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
