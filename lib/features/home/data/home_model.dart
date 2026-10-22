class RecentOrderItem {
  const RecentOrderItem({
    required this.orderId,
    required this.customerName,
    required this.itemsCount,
    required this.amount,
    required this.timeAgo,
    required this.status,
  });

  final String orderId;
  final String customerName;
  final int itemsCount;
  final String amount;
  final String timeAgo;
  final String status;
}

class HomeModel {
  const HomeModel({
    required this.appName,
    required this.unreadNotifications,
    required this.todayOrdersCount,
    required this.todayOrdersTrend,
    required this.todayRevenue,
    required this.pendingCount,
    required this.doneCount,
    required this.newOrdersBadge,
    required this.recentOrders,
    this.walletBalance = 0.0,
    this.avgRating = 4.5,
    this.totalReviews = 0,
    this.activeMenuItems = 0,
  });

  final String appName;
  final int unreadNotifications;
  final int todayOrdersCount;
  final String todayOrdersTrend;
  final String todayRevenue;
  final int pendingCount;
  final int doneCount;
  final int newOrdersBadge;
  final List<RecentOrderItem> recentOrders;
  final double walletBalance;
  final double avgRating;
  final int totalReviews;
  final int activeMenuItems;

  HomeModel copyWith({
    String? appName,
    int? unreadNotifications,
    int? todayOrdersCount,
    String? todayOrdersTrend,
    String? todayRevenue,
    int? pendingCount,
    int? doneCount,
    int? newOrdersBadge,
    List<RecentOrderItem>? recentOrders,
    double? walletBalance,
    double? avgRating,
    int? totalReviews,
    int? activeMenuItems,
  }) {
    return HomeModel(
      appName: appName ?? this.appName,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      todayOrdersTrend: todayOrdersTrend ?? this.todayOrdersTrend,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      pendingCount: pendingCount ?? this.pendingCount,
      doneCount: doneCount ?? this.doneCount,
      newOrdersBadge: newOrdersBadge ?? this.newOrdersBadge,
      recentOrders: recentOrders ?? this.recentOrders,
      walletBalance: walletBalance ?? this.walletBalance,
      avgRating: avgRating ?? this.avgRating,
      totalReviews: totalReviews ?? this.totalReviews,
      activeMenuItems: activeMenuItems ?? this.activeMenuItems,
    );
  }

  static const dummy = HomeModel(
    appName: 'EATOGGY',
    unreadNotifications: 0,
    todayOrdersCount: 0,
    todayOrdersTrend: 'Live kitchen sync',
    todayRevenue: '₹0',
    pendingCount: 0,
    doneCount: 0,
    newOrdersBadge: 0,
    walletBalance: 0.0,
    avgRating: 0.0,
    totalReviews: 0,
    activeMenuItems: 0,
    recentOrders: [],
  );
}
