import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/logger.dart';

class AnalyticsRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch partner dashboard metrics: totalOrders, todayOrders, pendingOrders, revenue, walletBalance, etc.
  /// GET /api/restaurants/dashboard
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.restaurantDashboard);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final dashboardData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Restaurant Dashboard Metrics: ${dashboardData['metrics']}");
        return dashboardData;
      }
      return {};
    } on DioException catch (e) {
      appLog("❌ Error fetching restaurant dashboard: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to fetch restaurant dashboard.';
    } catch (e) {
      appLog("❌ Unexpected error fetching restaurant dashboard: $e");
      throw 'An error occurred while fetching restaurant dashboard.';
    }
  }

  /// Fetch restaurant-specific analytics: orders, revenue, commission, rating
  /// GET /api/restaurants/analytics/overview
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      final response = await _dio.get(ApiConstants.analyticsOverview);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final analyticsData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Analytics Overview: ${analyticsData['metrics']}");
        return analyticsData;
      }
      return {};
    } on DioException catch (e) {
      appLog("❌ Error fetching analytics overview: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to fetch analytics overview.';
    } catch (e) {
      appLog("❌ Unexpected error fetching analytics overview: $e");
      throw 'An error occurred while fetching analytics overview.';
    }
  }
}
