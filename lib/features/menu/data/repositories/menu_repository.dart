import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';

class MenuRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch all menu categories for authenticated restaurant
  /// GET /api/restaurants/menu/categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.menuCategories);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['data'] as List<dynamic>? ?? [];
        appLog("✅ Fetched ${list.length} categories from backend");
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      appLog("❌ Error fetching categories: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Unexpected error fetching categories: $e");
      throw 'Failed to load categories.';
    }
  }

  /// Create a new menu category
  /// POST /api/restaurants/menu/categories
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String emoji = '🍢',
    int displayOrder = 1,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.menuCategories,
        data: {
          'name': name.trim(),
          'emoji': emoji,
          'displayOrder': displayOrder,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Category created successfully: ${data['data']?['name']}");
        return data;
      }
      return {'success': true, 'message': 'Category created successfully'};
    } on DioException catch (e) {
      appLog("❌ Create Category Error: ${e.response?.data ?? e.message}");
      final serverMsg = e.response?.data?['message'];
      if (serverMsg != null) {
        throw serverMsg;
      }
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Create Category General Error: $e");
      throw e.toString();
    }
  }
}
