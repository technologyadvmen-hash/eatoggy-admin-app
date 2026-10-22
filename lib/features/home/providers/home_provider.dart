import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../kitchen/data/repositories/kitchen_repository.dart';
import '../data/home_model.dart';
import '../data/repositories/analytics_repository.dart';

class HomeState {
  const HomeState({
    required this.data,
    this.isOnline = true,
    this.isLoading = false,
  });

  final HomeModel data;
  final bool isOnline;
  final bool isLoading;

  HomeState copyWith({
    HomeModel? data,
    bool? isOnline,
    bool? isLoading,
  }) {
    return HomeState(
      data: data ?? this.data,
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  final KitchenRepository _kitchenRepository = KitchenRepository();

  @override
  HomeState build() {
    _fetchLiveDashboard();
    return const HomeState(
      data: HomeModel.dummy,
      isOnline: true,
    );
  }

  /// Fetch partner dashboard metrics (GET /api/restaurants/dashboard)
  Future<void> _fetchLiveDashboard() async {
    try {
      state = state.copyWith(isLoading: true);

      // 1. Fetch live metrics
      final rawData = await _analyticsRepository.getDashboard();
      int totalOrders = 0;
      int todayOrders = 0;
      int deliveredOrders = 0;
      int pendingOrders = 0;
      dynamic todayRevenue = '0';
      double walletBalance = 0.0;
      double avgRating = 0.0;
      int totalReviews = 0;
      int activeMenuItems = 0;

      if (rawData.isNotEmpty && rawData['metrics'] is Map) {
        final metrics = rawData['metrics'] as Map<String, dynamic>;
        totalOrders = (metrics['totalOrders'] as num?)?.toInt() ?? 0;
        todayOrders = (metrics['todayOrders'] as num?)?.toInt() ?? totalOrders;
        deliveredOrders = (metrics['deliveredOrders'] as num?)?.toInt() ?? 0;
        pendingOrders = (metrics['pendingOrders'] as num?)?.toInt() ?? 0;
        todayRevenue = metrics['todayRevenue'] ?? metrics['totalRevenue'] ?? 0;
        walletBalance = (metrics['walletBalance'] as num?)?.toDouble() ?? 0.0;
        avgRating = (metrics['avgRating'] as num?)?.toDouble() ?? 0.0;
        totalReviews = (metrics['totalReviews'] as num?)?.toInt() ?? 0;
        activeMenuItems = (metrics['activeMenuItems'] as num?)?.toInt() ?? 0;
      } else {
        final overviewData = await _analyticsRepository.getAnalyticsOverview();
        if (overviewData.isNotEmpty && overviewData['metrics'] is Map) {
          final metrics = overviewData['metrics'] as Map<String, dynamic>;
          totalOrders = (metrics['totalOrders'] as num?)?.toInt() ?? 0;
          todayOrders = totalOrders;
          deliveredOrders = (metrics['deliveredOrders'] as num?)?.toInt() ?? 0;
          todayRevenue = metrics['totalRevenue'] ?? 0;
        }
      }

      // 2. Fetch live recent orders
      List<RecentOrderItem> mappedRecentOrders = [];
      int newOrdersCount = 0;
      try {
        final kitchenOrders = await _kitchenRepository.getKitchenOrders();
        newOrdersCount = kitchenOrders.where((o) => o.orderStatus == 'ACCEPTED').length;
        mappedRecentOrders = kitchenOrders.take(5).map((o) {
          final shortId = o.orderNumber.isNotEmpty
              ? o.orderNumber
              : (o.id.length >= 6 ? '#${o.id.substring(o.id.length - 6).toUpperCase()}' : '#${o.id}');
          return RecentOrderItem(
            orderId: shortId,
            customerName: o.customerName.isNotEmpty ? o.customerName : 'Customer',
            itemsCount: o.items.length,
            amount: '₹${o.grandTotal.toInt()}',
            timeAgo: o.timeAgo,
            status: o.orderStatus,
          );
        }).toList();
      } catch (_) {}

      final updated = state.data.copyWith(
        todayOrdersCount: todayOrders,
        todayRevenue: '₹$todayRevenue',
        doneCount: deliveredOrders,
        pendingCount: pendingOrders,
        newOrdersBadge: newOrdersCount,
        walletBalance: walletBalance,
        avgRating: avgRating,
        totalReviews: totalReviews,
        activeMenuItems: activeMenuItems,
        recentOrders: mappedRecentOrders,
      );

      state = state.copyWith(
        data: updated,
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on live dashboard fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshOverview() async {
    await _fetchLiveDashboard();
  }

  void toggleOnline(bool value) {
    state = state.copyWith(isOnline: value);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
