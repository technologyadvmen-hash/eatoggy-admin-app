import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/business_tools_provider.dart';

class ThermalPrinterScreen extends ConsumerWidget {
  const ThermalPrinterScreen({super.key});

  void _showTestReceiptModal(BuildContext context) {
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
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5D5A4), width: 1),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '*** TEST RECEIPT ***',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'EATOGGY PARTNER KITCHEN\nReceipt Printer Test Page\nTest Receipt #001',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.5.sp,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(color: Colors.black45, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1x Test Menu Item', style: TextStyle(fontFamily: 'monospace', fontSize: 10.sp, color: Colors.black)),
                          Text('₹100', style: TextStyle(fontFamily: 'monospace', fontSize: 10.sp, color: Colors.black)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1x Packaging Charge', style: TextStyle(fontFamily: 'monospace', fontSize: 10.sp, color: Colors.black)),
                          Text('₹15', style: TextStyle(fontFamily: 'monospace', fontSize: 10.sp, color: Colors.black)),
                        ],
                      ),
                      const Divider(color: Colors.black45, height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL PAID', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11.sp, color: Colors.black)),
                          Text('₹115', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 11.sp, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: 0.8.h),
                      Text(
                        'Thermal Print: OK • 80mm',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 9.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  height: 5.5.h,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test print sent to printer!'),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(
                      'Send to Printer',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleRow({
    required String title,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.headingPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
            inactiveTrackColor: AppColors.border,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(thermalPrinterProvider);
    final notifier = ref.read(thermalPrinterProvider.notifier);
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
                          'Thermal Printer Setup',
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Receipts and kitchen order tickets (KOT)',
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
                                Icons.print_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.selectedPrinter.name,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.headingPrimary,
                                  ),
                                ),
                                Text(
                                  '${model.selectedPrinter.type} • ${model.selectedPrinter.address}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10.5.sp,
                                  ),
                                ),
                              ],
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
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 1.5.w),
                              Text(
                                'Connected',
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
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Available Devices',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              Container(
                width: double.infinity,
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
                  children: model.availablePrinters.map((device) {
                    final isSelected =
                        device.name == model.selectedPrinter.name;
                    return InkWell(
                      onTap: () => notifier.selectPrinter(device),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.6.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  device.type.contains('WiFi')
                                      ? Icons.wifi_rounded
                                      : Icons.bluetooth_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 3.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.headingPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${device.type} • ${device.address}',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10.5.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
                  }).toList(),
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Paper Width',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              Row(
                children: ['58mm', '80mm'].map((size) {
                  final isSelected = model.paperSize == size;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => notifier.setPaperSize(size),
                      child: Container(
                        margin: EdgeInsets.only(
                          right: size == '58mm' ? 2.w : 0,
                          left: size == '80mm' ? 2.w : 0,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.4.h),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
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
                            '$size Standard',
                            style: AppTextStyles.bodyMedium.copyWith(
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
                  );
                }).toList(),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Printing Preferences',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              Container(
                width: double.infinity,
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
                    _buildToggleRow(
                      title: 'Auto-print New Orders',
                      value: model.autoPrintOrder,
                      onToggle: () => notifier.toggleAutoPrintOrder(),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildToggleRow(
                      title: 'Auto-print KOT on Accept',
                      value: model.autoPrintKot,
                      onToggle: () => notifier.toggleAutoPrintKot(),
                    ),
                    const Divider(color: AppColors.divider, height: 1),
                    _buildToggleRow(
                      title: 'Print Customer Phone & Address',
                      value: model.printCustomerDetails,
                      onToggle: () => notifier.togglePrintCustomerDetails(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              GestureDetector(
                onTap: () async {
                  await notifier.testPrint();
                  if (context.mounted) {
                    _showTestReceiptModal(context);
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
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          state.isTesting
                              ? 'Sending Test Print...'
                              : 'Test Print Receipt',
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
