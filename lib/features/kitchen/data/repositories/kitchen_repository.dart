import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/kitchen_order_model.dart';

class KitchenRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch live kitchen production queue for authenticated restaurant partner
  /// GET /api/restaurants/kitchen/orders
  Future<List<KitchenOrderModel>> getKitchenOrders() async {
    try {
      final response = await _dio.get(ApiConstants.kitchenOrders);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final rawList = data['data'] as List<dynamic>? ?? [];
        final orders = rawList
            .map((e) => KitchenOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        appLog("✅ Fetched ${orders.length} kitchen production queue orders");
        return orders;
      }

      appLog("⚠️ Unexpected kitchen orders response format: $data");
      return [];
    } on DioException catch (e) {
      appLog("❌ Kitchen Orders Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Kitchen Orders General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while fetching kitchen orders.';
    }
  }

  /// Update kitchen order status
  /// PATCH /api/restaurants/kitchen/orders/:orderId/status
  /// Allowed progression: ACCEPTED -> PREPARING -> READY
  Future<Map<String, dynamic>> updateKitchenOrderStatus({
    required String orderId,
    required String status,
    String? note,
    int? prepTimeEstimatedMinutes,
  }) async {
    try {
      final payload = <String, dynamic>{
        'status': status.toUpperCase(),
        if (note != null && note.isNotEmpty) ...{
          'note': note,
          'notes': note,
        },
        'prepTimeEstimatedMinutes': ?prepTimeEstimatedMinutes,
      };

      final response = await _dio.patch(
        ApiConstants.updateOrderStatus(orderId),
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Kitchen Order #$orderId updated to $status");
        return data;
      }

      throw data['message'] ?? 'Failed to update order status';
    } on DioException catch (e) {
      appLog("❌ Update Order Status Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Update Order Status General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while updating order status.';
    }
  }

  /// Upload Kitchen Hygiene proof (main prep station, storage, dishwashing)
  /// POST /api/restaurant-onboarding/kitchen-hygiene
  Future<Map<String, dynamic>> uploadKitchenHygieneProof({
    required File mainPrepStation,
    File? storageAndFridge,
    File? dishwashingArea,
  }) async {
    try {
      final mainFileName =
          mainPrepStation.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'mainPrepStation': await MultipartFile.fromFile(
          mainPrepStation.path,
          filename: mainFileName,
        ),
        if (storageAndFridge != null)
          'storageAndFridge': await MultipartFile.fromFile(
            storageAndFridge.path,
            filename: storageAndFridge.path.split(Platform.pathSeparator).last,
          ),
        if (dishwashingArea != null)
          'dishwashingArea': await MultipartFile.fromFile(
            dishwashingArea.path,
            filename: dishwashingArea.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.kitchenHygiene,
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Kitchen Hygiene Proof uploaded successfully");
        return data;
      }

      throw data['message'] ?? 'Failed to upload kitchen hygiene proof';
    } on DioException catch (e) {
      appLog("❌ Kitchen Hygiene Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Kitchen Hygiene General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while uploading kitchen hygiene proof.';
    }
  }
}
