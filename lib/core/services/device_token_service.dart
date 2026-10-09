import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import '../services/storage_service.dart';
import '../../features/notifications/data/repositories/notifications_repository.dart';

class DeviceTokenService {
  static final DeviceTokenService _instance = DeviceTokenService._internal();
  factory DeviceTokenService() => _instance;
  DeviceTokenService._internal();

  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();

  static const String _keyFcmToken = 'fcm_device_token';
  static const String _keyTokenRegistered = 'fcm_token_registered';

  /// Register FCM device token with Eatoggy backend
  Future<bool> registerDeviceToken({String? customToken, bool force = false}) async {
    try {
      final prefs = await SharedPreferencesService.getInstance();

      final isAlreadyRegistered = prefs.getBool(_keyTokenRegistered) ?? false;
      if (isAlreadyRegistered && !force && customToken == null) {
        appLog("ℹ️ Device token already registered with backend.");
        return true;
      }

      String token = customToken ?? prefs.getString(_keyFcmToken) ?? '';
      if (token.isEmpty) {
        // Generate a persistent unique device token
        token = 'eatoggy_device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(_keyFcmToken, token);
      }

      final platform = kIsWeb
          ? 'web'
          : Platform.isIOS
              ? 'ios'
              : 'android';

      appLog("📲 Registering device token to backend: $token ($platform)");

      final success = await _notificationsRepository.registerDeviceToken(
        fcmToken: token,
        platform: platform,
      );

      if (success) {
        await prefs.setBool(_keyTokenRegistered, true);
        appLog("✅ Device token successfully synchronized with backend.");
      }
      return success;
    } catch (e) {
      appLog("❌ DeviceTokenService registration error: $e");
      return false;
    }
  }
}
