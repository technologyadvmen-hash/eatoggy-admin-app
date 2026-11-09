import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/notifications_model.dart';

class NotificationsRepository {
  final Dio _dio = ApiService.dio;

  /// Fetch restaurant notification alerts
  /// GET /api/restaurants/notifications?page=1&limit=20
  Future<NotificationsPageModel> getNotifications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null && status.isNotEmpty) 'status': status,
      };
      final response = await _dio.get(
        ApiConstants.notifications,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final payload = data['data'] as Map<String, dynamic>? ?? {};
        final rawList = payload['notifications'] as List<dynamic>? ?? [];
        final unreadCount = (payload['unreadCount'] as num?)?.toInt() ?? 0;

        appLog("✅ Fetched ${rawList.length} notifications, unread: $unreadCount");

        final items = rawList
            .map((e) => NotificationItem.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();

        if (items.isEmpty) {
          // If no notifications exist yet on backend, provide empty model
          return NotificationsPageModel.fromNotificationsList(
            [],
            unreadCount: 0,
          );
        }

        return NotificationsPageModel.fromNotificationsList(
          items,
          unreadCount: unreadCount,
        );
      }

      return NotificationsPageModel.fromNotificationsList([], unreadCount: 0);
    } on DioException catch (e) {
      appLog("❌ Get Notifications Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Get Notifications General Error: $e");
      throw 'An error occurred while fetching notifications.';
    }
  }

  /// Register FCM device token for order alerts and bell chime
  /// POST /api/restaurants/notifications/device-token
  Future<bool> registerDeviceToken({
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerDeviceToken,
        data: {
          'fcmToken': fcmToken,
          'platform': platform,
          'devicePlatform': platform.toUpperCase(),
          'appVersion': '1.0.0',
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ FCM device token registered successfully with backend");
        return true;
      }
      return false;
    } on DioException catch (e) {
      appLog("❌ Register Device Token Error: ${e.response?.data ?? e.message}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Register Device Token General Error: $e");
      throw 'An error occurred while registering device token.';
    }
  }

  /// Mark notifications as read in backend database
  /// PATCH /api/restaurants/notifications/mark-read
  Future<bool> markNotificationsRead({List<String>? notificationIds}) async {
    try {
      final response = await _dio.patch(
        ApiConstants.markNotificationsRead,
        data: {
          'notificationIds': notificationIds ?? [],
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Notifications marked as read on backend");
        return true;
      }
      return false;
    } catch (e) {
      appLog("⚠️ Backend mark-read route not yet deployed: $e");
      return false;
    }
  }
}
