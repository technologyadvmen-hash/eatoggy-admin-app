import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/help_support_provider.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  late TextEditingController _searchController;
  late TextEditingController _issueController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _issueController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  void _showCategoryPicker(
    BuildContext context,
    List<String> categories,
    String selected,
    void Function(String) onSelect,
  ) {
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
                  'Select Issue Category',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.5.h),
                ...categories.map((cat) {
                  final isSelected = cat == selected;
                  return GestureDetector(
                    onTap: () {
                      onSelect(cat);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.4.h,
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
                            cat,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
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

  void _showLiveChatDialog(BuildContext context) {
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
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.primary,
                    size: 28.sp,
                  ),
                ),
                SizedBox(height: 1.8.h),
                Text(
                  'Connecting to Partner Support',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  'Average wait time is under 2 minutes.\nA support specialist will join shortly.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 2.5.h),
                Container(
                  width: double.infinity,
                  height: 5.5.h,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Start Chat',
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

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calling $phone...')),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Composing email to $email...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(helpSupportProvider);
    final notifier = ref.read(helpSupportProvider.notifier);
    final model = state.model;
    final faqs = state.filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: notifier.refreshTickets,
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
                            'Help and Support',
                            style: AppTextStyles.headingPrimary.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'EATOGGY partner assistance',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => notifier.updateSearchQuery(val),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search help topics...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                        size: 18.sp,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 1.5.h,
                        horizontal: 3.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Frequently Asked Questions',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.5.h),
                if (faqs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    alignment: Alignment.center,
                    child: Text(
                      'No FAQ topics match your search.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...faqs.map((faq) {
                    final isExpanded = state.expandedFaqId == faq.id;
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.2.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: InkWell(
                        onTap: () => notifier.toggleFaq(faq.id),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.headingPrimary,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    color: AppColors.primary,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                SizedBox(height: 1.h),
                                Text(
                                  faq.answer,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                SizedBox(height: 2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
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
                      Text(
                        'Direct Contact Support',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.headingPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _makeCall(model.phoneNumber),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.phone_outlined,
                                      color: AppColors.primary,
                                      size: 18.sp,
                                    ),
                                    SizedBox(height: 0.8.h),
                                    Text(
                                      'Call Us',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.headingPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      model.phoneNumber,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: InkWell(
                              onTap: () => _sendEmail(model.email),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.mail_outline_rounded,
                                      color: AppColors.primary,
                                      size: 18.sp,
                                    ),
                                    SizedBox(height: 0.8.h),
                                    Text(
                                      'Email Us',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.headingPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      model.email,
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.5.h),
                      GestureDetector(
                        onTap: () => _showLiveChatDialog(context),
                        child: Container(
                          width: double.infinity,
                          height: 5.5.h,
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
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Chat Live With Us',
                                  style: AppTextStyles.buttonMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Report an Issue',
                  style: AppTextStyles.headingPrimary.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 1.5.h),
                InkWell(
                  onTap: () {
                    _showCategoryPicker(
                      context,
                      model.issueCategories,
                      state.selectedCategory,
                      (cat) => notifier.selectCategory(cat),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
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
                          'Category: ${state.selectedCategory}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.headingPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: TextField(
                    controller: _issueController,
                    maxLines: 4,
                    onChanged: (val) => notifier.updateIssueDescription(val),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe your issue briefly here...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(4.w),
                    ),
                  ),
                ),
                SizedBox(height: 1.8.h),
                InkWell(
                  onTap: () async {
                    if (_issueController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please describe your issue first.'),
                          backgroundColor: AppColors.error,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    notifier.updateIssueDescription(_issueController.text);
                    final success = await notifier.submitTicket();
                    if (success && context.mounted) {
                      _issueController.clear();
                      final ticketId = ref.read(helpSupportProvider).lastCreatedTicketNumber ?? 'Submitted';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Support ticket submitted! Ticket ID: $ticketId',
                          ),
                          backgroundColor: AppColors.success,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 5.5.h,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.2,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            color: AppColors.primary,
                            size: 16.sp,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            state.isSubmitting
                                ? 'Submitting...'
                                : 'Submit Support Ticket',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (model.myTickets.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Support Tickets (${model.myTickets.length})',
                        style: AppTextStyles.headingPrimary.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.primary,
                          size: 16.sp,
                        ),
                        onPressed: notifier.refreshTickets,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.2.h),
                  ...model.myTickets.map((tkt) {
                    final isOpen = tkt.status.toUpperCase() == 'OPEN';
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 1.5.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
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
                              Text(
                                tkt.ticketNumber,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.5.w,
                                  vertical: 0.4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isOpen
                                      ? AppColors.warningBg
                                      : AppColors.successBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isOpen
                                        ? AppColors.warning.withValues(alpha: 0.2)
                                        : AppColors.success.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Text(
                                  tkt.status.toUpperCase(),
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isOpen
                                        ? AppColors.warning
                                        : AppColors.success,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 0.8.h),
                          Text(
                            tkt.subject,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.headingPrimary,
                              fontSize: 12.5.sp,
                            ),
                          ),
                          if (tkt.description.isNotEmpty) ...[
                            SizedBox(height: 0.4.h),
                            Text(
                              tkt.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5.sp,
                              ),
                            ),
                          ],
                          SizedBox(height: 1.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Category: ${tkt.category}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                              Text(
                                'Priority: ${tkt.priority}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10.5.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                SizedBox(height: 2.h),
                Center(
                  child: Text(
                    model.operatingHoursText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
