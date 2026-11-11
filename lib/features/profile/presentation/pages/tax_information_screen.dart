import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/business_tools_provider.dart';

class TaxInformationScreen extends ConsumerWidget {
  const TaxInformationScreen({super.key});

  void _showEditGstinDialog(BuildContext context, WidgetRef ref, String initial) {
    final controller = TextEditingController(text: initial);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: Text(
            'Edit GSTIN',
            style: AppTextStyles.h2.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.headingPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter 15-digit GSTIN',
              hintStyle: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
              ),
              filled: true,
              fillColor: AppColors.surfaceAlt,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
              ),
              onPressed: () {
                final text = controller.text.trim().toUpperCase();
                if (text.isNotEmpty) {
                  ref
                      .read(taxInformationProvider.notifier)
                      .updateGstin(text);
                }
                Navigator.pop(ctx);
              },
              child: Text(
                'Save',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.headingPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                  size: 15.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taxInformationProvider);
    final notifier = ref.read(taxInformationProvider.notifier);
    final model = state.model;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
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
                          'Tax Information',
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Goods and Services Tax compliance',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.primary,
                                size: 18.sp,
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              'GSTIN Registration',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.headingPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 12.sp,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Active',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.8.h),
                    Text(
                      model.gstin,
                      style: AppTextStyles.headingPrimary.copyWith(
                        fontSize: 17.sp,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.headingPrimary,
                      ),
                    ),
                    SizedBox(height: 0.6.h),
                    Text(
                      model.legalBusinessName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Registration Details',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
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
                child: Column(
                  children: [
                    _buildDetailRow(
                      label: 'LEGAL BUSINESS NAME',
                      value: model.legalBusinessName,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildDetailRow(
                      label: 'GSTIN NUMBER',
                      value: model.gstin,
                      onEdit: () =>
                          _showEditGstinDialog(context, ref, model.gstin),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildDetailRow(
                      label: 'PAN NUMBER',
                      value: model.panNumber,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildDetailRow(
                      label: 'TAXPAYER TYPE',
                      value: model.taxpayerType,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildDetailRow(
                      label: 'REGISTERED PLACE OF BUSINESS',
                      value: model.registeredAddress,
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildDetailRow(
                      label: 'STATE JURISDICTION',
                      value: model.stateJurisdiction,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GST Certificate downloaded to device.'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Download GST Certificate',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
              GestureDetector(
                onTap: () async {
                  await notifier.save();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tax information updated successfully!'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 6.2.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          state.isSaving ? 'Saving...' : 'Save Tax Details',
                          style: AppTextStyles.buttonMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
