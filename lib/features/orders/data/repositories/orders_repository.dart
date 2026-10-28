import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';

class OrdersRepository {
  final Dio _dio = ApiService.dio;

  /// Accept incoming order with estimated prep time in minutes
  /// POST /api/restaurants/orders/:orderId/accept
  Future<Map<String, dynamic>> acceptOrder({
    required String orderId,
    int estimatedPrepTime = 20,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.acceptOrder(orderId),
        data: {
          'estimatedPrepTime': estimatedPrepTime,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Order Accepted successfully: ${data['message']}");
        return data;
      }
      return {'success': true, 'message': 'Order accepted successfully'};
    } on DioException catch (e) {
      appLog("❌ Accept Order Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Accept Order General Error: $e");
      throw 'An error occurred while accepting order.';
    }
  }

  /// Reject incoming order with reason code and optional note
  /// POST /api/restaurants/orders/:orderId/reject
  Future<Map<String, dynamic>> rejectOrder({
    required String orderId,
    String reasonCode = 'OUT_OF_STOCK',
    String reasonNote = 'Item not available',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.rejectOrder(orderId),
        data: {
          'reasonCode': reasonCode,
          'reasonNote': reasonNote,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Order Rejected successfully: ${data['message']}");
        return data;
      }
      return {'success': true, 'message': 'Order rejected successfully'};
    } on DioException catch (e) {
      appLog("❌ Reject Order Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Reject Order General Error: $e");
      throw 'An error occurred while rejecting order.';
    }
  }
}
