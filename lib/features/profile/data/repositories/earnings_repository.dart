import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';

class EarningsRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch earnings summary and settlement statements for restaurant partner
  /// GET /api/restaurants/earnings
  Future<Map<String, dynamic>> getEarnings() async {
    try {
      final response = await _dio.get(ApiConstants.earnings);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final earningsData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Earnings summary: totalPaid=${earningsData['totalPaid']}, totalPending=${earningsData['totalPending']}");
        return earningsData;
      }
      return {};
    } on DioException catch (e) {
      appLog("❌ Get Earnings Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Earnings General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while fetching earnings.';
    }
  }

  /// Fetch restaurant-specific analytics (orders, revenue, commission)
  /// GET /api/restaurants/analytics/overview
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      final response = await _dio.get(ApiConstants.analyticsOverview);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final analyticsData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Analytics Overview: totalOrders=${analyticsData['metrics']?['totalOrders']}");
        return analyticsData;
      }
      return {};
    } on DioException catch (e) {
      appLog("❌ Get Analytics Overview Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Analytics Overview General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while fetching analytics overview.';
    }
  }
}
