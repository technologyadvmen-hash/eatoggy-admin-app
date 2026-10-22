import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../dashboard/presentation/providers/main_shell_provider.dart';
import '../../orders/presentation/providers/orders_page_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);
    final data = state.data;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: notifier.refreshOverview,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 8.w,
                            height: 8.w,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.5.w),
                        Text(
                          data.appName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          state.isOnline ? 'ONLINE' : 'OFFLINE',
                          style: AppTextStyles.captionMedium.copyWith(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: state.isOnline
                                ? AppColors.success
                                : AppColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 1.5.w),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: state.isOnline,
                            onChanged: (val) => notifier.toggleOnline(val),
                            activeTrackColor: const Color(0xFF22C55E),
                            activeThumbColor: Colors.white,
                            inactiveTrackColor: AppColors.border,
                            inactiveThumbColor: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 1.5.w),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.notifications),
                          child: Container(
                            width: 9.w,
                            height: 9.w,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.0,
                              ),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.textSecondary,
                                  size: 17.sp,
                                ),
                                if (data.unreadNotifications > 0)
                                  Positioned(
                                    top: 1,
                                    right: 1,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 14,
                                        minHeight: 14,
                                      ),
                                      child: Text(
                                        '${data.unreadNotifications}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.2.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TODAY ORDERS',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Text(
                              '${data.todayOrdersCount}',
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Row(
                              children: [
                                const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  data.todayOrdersTrend,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 7.h,
                        color: AppColors.divider,
                      ),
                      SizedBox(width: 4.5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REVENUE',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Text(
                              data.todayRevenue,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.6.h),
                            Row(
                              children: [
                                Text(
                                  '${data.pendingCount} Pending',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '${data.doneCount} Done',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.5.h),
                Text(
                  'Quick Actions',
                  style: AppTextStyles.subhead.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        title: 'New Orders',
                        iconWidget: CustomPaint(
                          size: Size(20.sp, 20.sp),
                          painter: _OrdersIconPainter(color: AppColors.primary),
                        ),
                        badgeCount: data.newOrdersBadge,
                        onTap: () {
                          ref
                              .read(ordersPageProvider.notifier)
                              .selectFilter('new');
                          ref.read(mainShellProvider.notifier).changeTab(1);
                        },
                      ),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        title: 'Active Orders',
                        iconWidget: CustomPaint(
                          size: Size(20.sp, 20.sp),
                          painter:
                              _TrendingIconPainter(color: AppColors.primary),
                        ),
                        onTap: () {
                          ref
                              .read(ordersPageProvider.notifier)
                              .selectFilter('preparing');
                          ref.read(mainShellProvider.notifier).changeTab(1);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        title: 'Menu Manager',
                        iconWidget: CustomPaint(
                          size: Size(20.sp, 20.sp),
                          painter: _MenuIconPainter(color: AppColors.primary),
                        ),
                        onTap: () {
                          ref.read(mainShellProvider.notifier).changeTab(3);
                        },
                      ),
                    ),
                    SizedBox(width: 3.5.w),
                    Expanded(
                      child: _buildQuickActionCard(
                        context,
                        title: 'Subscriptions',
                        iconWidget: CustomPaint(
                          size: Size(20.sp, 20.sp),
                          painter:
                              _SubscriptionIconPainter(color: AppColors.primary),
                        ),
                        onTap: () => context.push(AppRoutes.subscriptionPlans),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Orders',
                      style: AppTextStyles.subhead.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(ordersPageProvider.notifier).selectFilter('all');
                        ref.read(mainShellProvider.notifier).changeTab(1);
                      },
                      child: Text(
                        'View All',
                        style: AppTextStyles.captionPrimary.copyWith(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                if (data.recentOrders.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 34.sp,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 1.2.h),
                        Text(
                          'No Recent Orders',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'New customer orders will appear here in real-time',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...data.recentOrders.map(
                    (order) => _buildOrderTile(context, order),
                  ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required Widget iconWidget,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                iconWidget,
                if (badgeCount > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(BuildContext context, dynamic order) {
    Color badgeColor;
    Color badgeBgColor;
    if (order.status == 'New') {
      badgeColor = AppColors.primary;
      badgeBgColor = AppColors.primaryLight;
    } else if (order.status == 'Preparing') {
      badgeColor = AppColors.warning;
      badgeBgColor = AppColors.warningLight;
    } else {
      badgeColor = AppColors.success;
      badgeBgColor = AppColors.successLight;
    }

    return GestureDetector(
      onTap: () => context.push(AppRoutes.orderDetail, extra: order.orderId),
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderId,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  '${order.customerName} • ${order.itemsCount} items',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.amount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      order.timeAgo,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11.5.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 3.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.6.h),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersIconPainter extends CustomPainter {
  _OrdersIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.15, h * 0.28);
    path.lineTo(w * 0.75, h * 0.28);

    path.moveTo(w * 0.15, h * 0.52);
    path.lineTo(w * 0.75, h * 0.52);

    path.moveTo(w * 0.15, h * 0.76);
    path.lineTo(w * 0.48, h * 0.76);

    path.moveTo(w * 0.54, h * 0.72);
    path.lineTo(w * 0.64, h * 0.82);
    path.lineTo(w * 0.84, h * 0.58);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrdersIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _TrendingIconPainter extends CustomPainter {
  _TrendingIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.18, h * 0.72);
    path.lineTo(w * 0.44, h * 0.46);
    path.lineTo(w * 0.58, h * 0.60);
    path.lineTo(w * 0.82, h * 0.28);

    path.moveTo(w * 0.60, h * 0.28);
    path.lineTo(w * 0.82, h * 0.28);
    path.lineTo(w * 0.82, h * 0.50);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrendingIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MenuIconPainter extends CustomPainter {
  _MenuIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final knifePath = Path();
    knifePath.moveTo(w * 0.25, h * 0.75);
    knifePath.lineTo(w * 0.75, h * 0.25);
    knifePath.moveTo(w * 0.75, h * 0.25);
    knifePath.cubicTo(w * 0.65, h * 0.15, w * 0.50, h * 0.20, w * 0.40, h * 0.35);

    final forkPath = Path();
    forkPath.moveTo(w * 0.75, h * 0.75);
    forkPath.lineTo(w * 0.38, h * 0.38);

    final tinesPath = Path();
    tinesPath.moveTo(w * 0.20, h * 0.45);
    tinesPath.lineTo(w * 0.38, h * 0.27);
    tinesPath.moveTo(w * 0.27, h * 0.38);
    tinesPath.lineTo(w * 0.45, h * 0.20);
    tinesPath.moveTo(w * 0.34, h * 0.31);
    tinesPath.lineTo(w * 0.52, h * 0.13);

    canvas.drawPath(knifePath, paint);
    canvas.drawPath(forkPath, paint);
    canvas.drawPath(tinesPath, paint);
  }

  @override
  bool shouldRepaint(covariant _MenuIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SubscriptionIconPainter extends CustomPainter {
  _SubscriptionIconPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final boxPath = Path();
    boxPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.25, w * 0.64, h * 0.60),
        const Radius.circular(4),
      ),
    );

    boxPath.moveTo(w * 0.35, h * 0.14);
    boxPath.lineTo(w * 0.35, h * 0.25);
    boxPath.moveTo(w * 0.65, h * 0.14);
    boxPath.lineTo(w * 0.65, h * 0.25);

    final arrowPath = Path();
    arrowPath.moveTo(w * 0.36, h * 0.52);
    arrowPath.lineTo(w * 0.64, h * 0.52);
    arrowPath.lineTo(w * 0.56, h * 0.44);

    arrowPath.moveTo(w * 0.64, h * 0.64);
    arrowPath.lineTo(w * 0.36, h * 0.64);
    arrowPath.lineTo(w * 0.44, h * 0.72);

    canvas.drawPath(boxPath, paint);
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SubscriptionIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
