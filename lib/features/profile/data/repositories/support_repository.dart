import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/logger.dart';

class SupportRepository {
  final Dio _dio = ApiService.dio;

  /// Map UI categories to allowed backend enum values
  /// Backend enums: ACCOUNT, TECHNICAL, OTHER, PAYMENT, DELIVERY, SUBSCRIPTION
  static String mapCategoryToBackendEnum(String uiCategory) {
    final lower = uiCategory.toLowerCase();
    if (lower.contains('payout') || lower.contains('payment')) {
      return 'PAYMENT';
    } else if (lower.contains('delay') || lower.contains('delivery')) {
      return 'DELIVERY';
    } else if (lower.contains('technical') || lower.contains('glitch') || lower.contains('app')) {
      return 'TECHNICAL';
    } else if (lower.contains('subscription') || lower.contains('tiffin')) {
      return 'SUBSCRIPTION';
    } else if (lower.contains('account') || lower.contains('profile')) {
      return 'ACCOUNT';
    }
    return 'OTHER';
  }

  /// Fetch support tickets submitted by authenticated restaurant partner
  /// GET /api/support/tickets/restaurant/my
  Future<List<Map<String, dynamic>>> getMyTickets() async {
    try {
      final response = await _dio.get(ApiConstants.mySupportTickets);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final list = data['data'] as List<dynamic>? ?? [];
        appLog("✅ Fetched ${list.length} support tickets for restaurant");
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } on DioException catch (e) {
      appLog("❌ Error fetching my support tickets: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to fetch support tickets.';
    } catch (e) {
      appLog("❌ Unexpected error fetching my support tickets: $e");
      throw 'An error occurred while fetching support tickets.';
    }
  }

  /// Submit a partner support ticket
  /// POST /api/support/tickets
  Future<Map<String, dynamic>> createTicket({
    required String category,
    required String subject,
    required String description,
    String priority = 'MEDIUM',
  }) async {
    try {
      final backendCategory = mapCategoryToBackendEnum(category);
      final response = await _dio.post(
        ApiConstants.createSupportTicket,
        data: {
          'category': backendCategory,
          'subject': subject.isEmpty ? '$category Support Request' : subject,
          'description': description,
          'priority': priority.toUpperCase(),
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Support ticket created successfully: ${data['data']?['ticketNumber']}");
        return data;
      }
      return {'success': true};
    } on DioException catch (e) {
      appLog("❌ Error creating support ticket: ${e.response?.data ?? e.message}");
      throw e.response?.data?['message'] ?? 'Failed to submit support ticket.';
    } catch (e) {
      appLog("❌ Unexpected error creating support ticket: $e");
      throw 'An error occurred while submitting support ticket.';
    }
  }
}
