import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';

class SubscriptionsRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch all created tiffin/subscription plans for authenticated restaurant
  /// GET /api/restaurants/tiffin-plans
  Future<List<Map<String, dynamic>>> getTiffinPlans() async {
    try {
      final response = await _dio.get(ApiConstants.tiffinPlans);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final plansRaw = data['data']?['plans'] as List<dynamic>? ?? [];
        final plans = plansRaw.map((e) => e as Map<String, dynamic>).toList();
        appLog("✅ Fetched ${plans.length} tiffin plans");
        return plans;
      }
      return [];
    } on DioException catch (e) {
      appLog("❌ Get Tiffin Plans Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Tiffin Plans General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while fetching tiffin plans.';
    }
  }

  /// Create a new tiffin/subscription plan
  /// POST /api/restaurants/tiffin-plans
  Future<Map<String, dynamic>> createTiffinPlan({
    required String name,
    required String description,
    required String mealType,
    required num pricePerMeal,
    int planDurationDays = 7,
    List<String>? availableDays,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'description': description.trim(),
        'mealType': mealType.toUpperCase(),
        'pricePerMeal': pricePerMeal,
        'planDurationDays': planDurationDays,
        'availableDays': availableDays ??
            [
              'MONDAY',
              'TUESDAY',
              'WEDNESDAY',
              'THURSDAY',
              'FRIDAY',
              'SATURDAY',
              'SUNDAY'
            ],
        'items': items ??
            [
              {'name': 'Daily Standard Meal', 'quantity': 1}
            ],
      };

      final response = await _dio.post(
        ApiConstants.tiffinPlans,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Created Tiffin Plan: ${data['data']?['plan']?['name']}");
        return data;
      }

      throw data['message'] ?? 'Failed to create tiffin plan';
    } on DioException catch (e) {
      appLog("❌ Create Tiffin Plan Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Create Tiffin Plan General Error: $e");
      if (e is String) rethrow;
      throw 'An error occurred while creating tiffin plan.';
    }
  }
}
