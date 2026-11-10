import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/restaurant_profile_model.dart';

class ProfileRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch full restaurant profile and operational status
  /// GET /api/restaurants/profile
  Future<RestaurantProfileModel> getRestaurantProfile() async {
    try {
      final response = await _dio.get(ApiConstants.restaurantProfile);
      final data = response.data;

      if (data is Map<String, dynamic> && data['success'] == true) {
        final profileData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched Restaurant Profile: ${profileData['restaurantName']} (${profileData['ownerName']})");
        return RestaurantProfileModel.fromJson(profileData);
      }
      return RestaurantProfileModel.dummy();
    } on DioException catch (e) {
      appLog("❌ Get Profile Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Profile General Error: $e");
      throw 'An error occurred while fetching restaurant profile.';
    }
  }
}
