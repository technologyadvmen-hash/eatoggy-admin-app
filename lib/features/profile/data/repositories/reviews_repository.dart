import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/logger.dart';

class ReviewsRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch diner reviews and average ratings for authenticated restaurant partner
  /// GET /api/restaurants/reviews
  Future<Map<String, dynamic>> getReviews() async {
    try {
      final response = await _dio.get(ApiConstants.reviews);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final reviewData = data['data'] as Map<String, dynamic>? ?? {};
        appLog("✅ Fetched reviews: total=${reviewData['totalReviews']}, avgRating=${reviewData['avgRating']}");
        return reviewData;
      }
      return {};
    } on DioException catch (e) {
      appLog("❌ Error fetching reviews: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to fetch reviews.';
    } catch (e) {
      appLog("❌ Unexpected error fetching reviews: $e");
      throw 'An error occurred while fetching reviews.';
    }
  }

  /// Post an official partner reply to a diner review
  /// POST /api/restaurants/reviews/:id/reply
  Future<Map<String, dynamic>> replyToReview({
    required String reviewId,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.replyToReview(reviewId),
        data: {
          'comment': comment,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Reply submitted for review $reviewId");
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      appLog("❌ Error replying to review: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to submit reply.';
    } catch (e) {
      appLog("❌ Unexpected error replying to review: $e");
      throw 'An error occurred while submitting reply.';
    }
  }
}
