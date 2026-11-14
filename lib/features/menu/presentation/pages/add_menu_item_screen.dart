import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/add_menu_item_model.dart';
import '../../data/models/category_items_model.dart';
import '../providers/add_menu_item_provider.dart';

class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({
    super.key,
    this.isEdit = false,
    this.editItem,
  });

  final bool isEdit;
  final CategoryFoodItem? editItem;

  @override
  ConsumerState<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends ConsumerState<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final defaultModel =
        widget.isEdit ? AddMenuItemModel.dummyEdit : AddMenuItemModel.dummyNew;

    String initialName = defaultModel.itemName;
    String initialPrice = defaultModel.price;

    if (widget.editItem != null) {
      initialName = widget.editItem!.name;
      initialPrice = widget.editItem!.price.replaceAll(RegExp(r'[^0-9]'), '');
    }

    _nameController = TextEditingController(text: initialName);
    _priceController = TextEditingController(text: initialPrice);
    _prepTimeController = TextEditingController(text: defaultModel.prepTime);
    _descriptionController =
        TextEditingController(text: defaultModel.description);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addMenuItemProvider.notifier).initialize(
            isEdit: widget.isEdit,
            item: widget.editItem,
          );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showImagePickerBottomSheet(BuildContext context, AddMenuItemNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upload Kitchen Photo',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textMuted,
                        size: 18.sp,
                      ),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                      size: 17.sp,
                    ),
                  ),
                  title: Text(
                    'Take Photo with Camera',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Capture dish directly from kitchen',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    notifier.pickImage(ImageSource.camera);
                  },
                ),
                const Divider(color: AppColors.divider, height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 11.w,
                    height: 11.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                      size: 17.sp,
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Pick existing photo from your storage',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    notifier.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSizeVariantDialog(
      BuildContext context, AddMenuItemNotifier notifier) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Add Size Variant',
          style: AppTextStyles.heading.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Regular / Large',
                hintStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Price (₹) e.g. 150',
                hintStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.captionMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty &&
                  priceCtrl.text.trim().isNotEmpty) {
                notifier.addSizeVariant(
                    titleCtrl.text.trim(), priceCtrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'Add',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddonDialog(BuildContext context, AddMenuItemNotifier notifier) {
    final titleCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Add Add-on',
          style: AppTextStyles.heading.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Extra Butter',
                hintStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Price (₹) e.g. 25',
                hintStyle:
                    AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.captionMedium
                  .copyWith(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty &&
                  priceCtrl.text.trim().isNotEmpty) {
                notifier.addAddon(titleCtrl.text.trim(), priceCtrl.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: Text(
              'Add',
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSaveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Item updated successfully!'
                : 'Item saved successfully!',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMenuItemProvider);
    final notifier = ref.read(addMenuItemProvider.notifier);
    final model = state.model;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Form(
                  key: _formKey,
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
                      Text(
                        'Item Image',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      GestureDetector(
                        onTap: () => _showImagePickerBottomSheet(context, notifier),
                        child: Container(
                          width: double.infinity,
                          height: 15.h,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: state.imagePath != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(state.imagePath!),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 3.w,
                                        top: 1.h,
                                        child: GestureDetector(
                                          onTap: () => notifier.removeImage(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 14.sp,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Column(
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
                                        SizedBox(height: 1.2.h),
                                        Text(
                                          state.hasImage
                                              ? 'Kitchen photo attached (Tap to change)'
                                              : 'Tap to upload kitchen photo',
                                          style: AppTextStyles.caption.copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Text(
                        'Item Name',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Kadai Paneer',
                            hintStyle: AppTextStyles.caption.copyWith(
                              fontSize: 13.5.sp,
                              color: AppColors.textMuted,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter item name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Text(
                        'Description',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'e.g. Fresh cottage cheese cooked with onions, tomatoes and bell peppers in a traditional kadai...',
                            hintStyle: AppTextStyles.caption.copyWith(
                              fontSize: 13.sp,
                              color: AppColors.textMuted,
                              height: 1.4,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Text(
                        'Category',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Builder(
                            builder: (context) {
                              final categoriesList = model.categories.isNotEmpty
                                  ? model.categories
                                  : (state.selectedCategory.isNotEmpty
                                      ? [state.selectedCategory]
                                      : ['General']);
                              final selectedValue = categoriesList.contains(state.selectedCategory)
                                  ? state.selectedCategory
                                  : categoriesList.first;
                              return DropdownButton<String>(
                                value: selectedValue,
                                isExpanded: true,
                                dropdownColor: AppColors.surface,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primary,
                                  size: 18.sp,
                                ),
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                items: categoriesList.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat,
                                    child: Text(cat),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    notifier.selectCategory(val);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Price (₹)',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1,
                                    ),
                                    boxShadow: AppColors.cardShadow,
                                  ),
                                  child: TextFormField(
                                    controller: _priceController,
                                    keyboardType: TextInputType.number,
                                    style: AppTextStyles.body.copyWith(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '220',
                                      hintStyle: AppTextStyles.caption.copyWith(
                                        fontSize: 13.5.sp,
                                        color: AppColors.textMuted,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 1.5.h,
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Enter price';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 3.5.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Veg / Non-Veg',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Container(
                                  height: 5.6.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.5.w),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        state.isVeg ? 'VEG' : 'NON-VEG',
                                        style: AppTextStyles.captionMedium
                                            .copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          color: state.isVeg
                                              ? AppColors.veg
                                              : AppColors.nonVeg,
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: state.isVeg,
                                          onChanged: (val) {
                                            notifier.toggleVeg(val);
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
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.2.h),
                      Text(
                        'Preparation Time (Mins)',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: TextFormField(
                          controller: _prepTimeController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: '15',
                            hintStyle: AppTextStyles.caption.copyWith(
                              fontSize: 13.5.sp,
                              color: AppColors.textMuted,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Size Variants',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                _showAddSizeVariantDialog(context, notifier),
                            child: Text(
                              '+ Add Size',
                              style: AppTextStyles.captionMedium.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              state.sizeVariants.isNotEmpty
                                  ? state.sizeVariants
                                      .map((e) => e.title)
                                      .join(' / ')
                                  : model.sizeVariantsSummary,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              state.sizeVariants.isNotEmpty
                                  ? state.sizeVariants
                                      .map((e) => e.price)
                                      .join(' / ')
                                  : model.sizeVariantsPrice,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add-ons',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAddonDialog(context, notifier),
                            child: Text(
                              '+ Add More',
                              style: AppTextStyles.captionMedium.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      ...state.addons.map(
                        (addon) => Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 1.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.4.h,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                addon.title,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                addon.price,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 0.8.h,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mark as Available instantly',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: state.isAvailable,
                                onChanged: (val) {
                                  notifier.toggleAvailable(val);
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
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 2.h),
              child: Container(
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
                  onPressed: _onSaveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Item Details',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
