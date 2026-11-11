import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/business_tools_provider.dart';

class BankAccountDetailsScreen extends ConsumerWidget {
  const BankAccountDetailsScreen({super.key});

  void _showEditFieldDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required void Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: Text(
            'Edit $title',
            style: AppTextStyles.h2.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.headingPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $title',
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
              onPressed: () => Navigator.pop(dialogCtx),
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
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  onSave(text);
                }
                Navigator.pop(dialogCtx);
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

  Widget _buildRow({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
            Container(
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bankAccountProvider);
    final notifier = ref.read(bankAccountProvider.notifier);
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
                          'Bank Account Details',
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Payout settlement account details',
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
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B18), Color(0xFF2C2723)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_rounded,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              model.bankName,
                              style: AppTextStyles.h2.copyWith(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
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
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.success,
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
                                'Verified',
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
                    SizedBox(height: 3.h),
                    Text(
                      model.maskedAccountNumber,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 17.sp,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BENEFICIARY',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              model.beneficiaryName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'IFSC CODE',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 0.3.h),
                            Text(
                              model.ifscCode,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Account Information',
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
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildRow(
                      context: context,
                      label: 'BANK NAME',
                      value: model.bankName,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'Bank Name',
                          initialValue: model.bankName,
                          onSave: (val) =>
                              notifier.updateDetails(bankName: val),
                        );
                      },
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildRow(
                      context: context,
                      label: 'ACCOUNT NUMBER',
                      value: model.accountNumber,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'Account Number',
                          initialValue: model.accountNumber,
                          onSave: (val) =>
                              notifier.updateDetails(accountNumber: val),
                        );
                      },
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildRow(
                      context: context,
                      label: 'IFSC CODE',
                      value: model.ifscCode,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'IFSC Code',
                          initialValue: model.ifscCode,
                          onSave: (val) =>
                              notifier.updateDetails(ifscCode: val),
                        );
                      },
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildRow(
                      context: context,
                      label: 'ACCOUNT HOLDER NAME',
                      value: model.beneficiaryName,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'Account Holder Name',
                          initialValue: model.beneficiaryName,
                          onSave: (val) =>
                              notifier.updateDetails(beneficiaryName: val),
                        );
                      },
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildRow(
                      context: context,
                      label: 'ACCOUNT TYPE',
                      value: model.accountType,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'Account Type',
                          initialValue: model.accountType,
                          onSave: (val) =>
                              notifier.updateDetails(accountType: val),
                        );
                      },
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildRow(
                      context: context,
                      label: 'BRANCH',
                      value: model.branch,
                      onEdit: () {
                        _showEditFieldDialog(
                          context: context,
                          title: 'Branch',
                          initialValue: model.branch,
                          onSave: (val) =>
                              notifier.updateDetails(branch: val),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              GestureDetector(
                onTap: () async {
                  await notifier.save();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Bank account details saved successfully!'),
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
                          state.isSaving ? 'Saving...' : 'Save Bank Details',
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
