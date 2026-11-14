import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/customer_reviews_model.dart';
import '../providers/respond_to_review_provider.dart';

class RespondToReviewScreen extends ConsumerStatefulWidget {
  const RespondToReviewScreen({
    super.key,
    required this.review,
  });

  final CustomerReviewModel review;

  @override
  ConsumerState<RespondToReviewScreen> createState() =>
      _RespondToReviewScreenState();
}

class _RespondToReviewScreenState extends ConsumerState<RespondToReviewScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(respondToReviewProvider.notifier)
          .initializeForReview(widget.review);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final reply = _controller.text.trim();
    if (reply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a response before submitting.'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await ref
        .read(respondToReviewProvider.notifier)
        .submitReply(widget.review.id, reply);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reply submitted for ${widget.review.name}!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(respondToReviewProvider);
    final notifier = ref.read(respondToReviewProvider.notifier);
    final review = widget.review;
    final suggested = state.model.suggestedResponses;
    final firstName = review.name.split(' ').first;

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
                          'Respond to Review',
                          style: AppTextStyles.headingPrimary.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          'Build trust with public replies',
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
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: review.isCritical
                        ? AppColors.error.withValues(alpha: 0.3)
                        : AppColors.border,
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
                        Text(
                          review.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.headingPrimary,
                          ),
                        ),
                        Text(
                          review.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.8.h),
                    Row(
                      children: List.generate(5, (index) {
                        if (index < review.rating) {
                          return Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 16.sp,
                          );
                        }
                        return Icon(
                          Icons.star_outline_rounded,
                          color: AppColors.border,
                          size: 16.sp,
                        );
                      }),
                    ),
                    SizedBox(height: 1.2.h),
                    Text(
                      review.comment,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13.sp,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.5.h),
              Text(
                'Your Response',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.5.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: AppColors.cardShadow,
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  maxLength: 500,
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
                  onChanged: (val) {
                    notifier.updateReplyText(val);
                  },
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your reply to $firstName...',
                    hintStyle: AppTextStyles.body.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0.8.h, bottom: 2.h),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.characterCount}/500',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Text(
                'Suggested Responses',
                style: AppTextStyles.headingPrimary.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 1.2.h),
              ...suggested.map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    _controller.text = suggestion;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: suggestion.length),
                    );
                    notifier.applySuggestedResponse(suggestion);
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 1.2.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.6.h,
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
                    child: Text(
                      suggestion,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.headingPrimary,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 1.5.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Note: Your response will be public and visible to all customers on the app.',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                height: 6.2.h,
                child: ElevatedButton(
                  onPressed: state.isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: state.isSubmitting
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              'Submit Response',
                              style: AppTextStyles.buttonMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
