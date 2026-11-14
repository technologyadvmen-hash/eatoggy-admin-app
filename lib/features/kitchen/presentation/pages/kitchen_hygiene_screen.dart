import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/kitchen_provider.dart';

class KitchenHygieneScreen extends ConsumerStatefulWidget {
  const KitchenHygieneScreen({super.key});

  @override
  ConsumerState<KitchenHygieneScreen> createState() =>
      _KitchenHygieneScreenState();
}

class _KitchenHygieneScreenState extends ConsumerState<KitchenHygieneScreen> {
  File? _mainPrepStation;
  File? _storageAndFridge;
  File? _dishwashingArea;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int sectionIndex) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      if (sectionIndex == 0) {
        _mainPrepStation = File(picked.path);
      } else if (sectionIndex == 1) {
        _storageAndFridge = File(picked.path);
      } else if (sectionIndex == 2) {
        _dishwashingArea = File(picked.path);
      }
    });
  }

  Future<void> _submitProof() async {
    if (_mainPrepStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo of the Main Cooking Area.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final success = await ref
          .read(kitchenProvider.notifier)
          .uploadHygieneProof(
            mainPrepStation: _mainPrepStation!,
            storageAndFridge: _storageAndFridge,
            dishwashingArea: _dishwashingArea,
          );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kitchen hygiene proof submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kitchenProvider);

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
          'Kitchen Hygiene Proof',
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: Center(
              child: Text(
                'Step 2 of 4',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Upload Kitchen Proof',
              style: AppTextStyles.heading.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 0.6.h),
            Text(
              'Upload real-time photos of your clean kitchen, prep area, and packaging station.',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 3.h),

            // Section 1: Main Cooking Area (Required)
            _buildUploadCard(
              title: 'Main Cooking & Gas Stove Area',
              subtitle: 'Clear photo showing stove, exhaust/chimney, and clean countertops.',
              file: _mainPrepStation,
              isRequired: true,
              onTap: () => _pickImage(0),
            ),
            SizedBox(height: 2.h),

            // Section 2: Storage & Fridge
            _buildUploadCard(
              title: 'Storage, Fridge & Raw Ingredients',
              subtitle: 'Well-arranged storage shelves, temperature-controlled fridge interior.',
              file: _storageAndFridge,
              isRequired: false,
              onTap: () => _pickImage(1),
            ),
            SizedBox(height: 2.h),

            // Section 3: Dishwashing & Cleaning
            _buildUploadCard(
              title: 'Dishwashing & Sanitization Area',
              subtitle: 'Clean sink, drying rack, and approved sanitization detergents.',
              file: _dishwashingArea,
              isRequired: false,
              onTap: () => _pickImage(2),
            ),
            SizedBox(height: 3.h),

            // Compliance checklist card
            Container(
              padding: EdgeInsets.all(4.5.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hygiene & Safety Standards',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  _buildComplianceItem('Daily temperature log maintained'),
                  SizedBox(height: 1.h),
                  _buildComplianceItem('Clean cooking apparel & hairnets worn'),
                  SizedBox(height: 1.h),
                  _buildComplianceItem('Regular pest control and waste clearance'),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // CTA Button
            Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: state.isHygieneUploading ? null : _submitProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state.isHygieneUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Submit Hygiene Proof',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required File? file,
    required bool isRequired,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.5.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              height: 1.3,
            ),
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 14.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF9F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: file != null ? AppColors.success : AppColors.border,
                  width: 1.2,
                ),
              ),
              child: file != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(file, fit: BoxFit.cover),
                          Container(
                            color: Colors.black.withValues(alpha: 0.25),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Tap to capture or upload photo',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceItem(String title) {
    return Row(
      children: [
        Container(
          width: 4.5.w,
          height: 4.5.w,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 14,
            ),
          ),
        ),
        SizedBox(width: 2.5.w),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
