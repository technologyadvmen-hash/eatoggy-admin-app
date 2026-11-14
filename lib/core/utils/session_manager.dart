import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_keys.dart';
import '../router/app_router.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class SessionManager {
  static bool _isLoggingOut = false;

  /// Checks if a valid user session (JWT token) currently exists in persistent storage.
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final token = prefs.getString(AppKeys.accessToken);
      return token != null && token.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Single source of truth for routing users based on their onboarding & approval status.
  static String resolveDestination(Map<String, dynamic>? user) {
    if (user == null || user.isEmpty) {
      return AppRoutes.login;
    }

    final onboardingStatus =
        user['onboardingStatus']?.toString().toUpperCase() ?? '';
    final currentStep = user['currentStep']?.toString().toUpperCase() ?? '';

    appLog('🧭 Resolving flow: status=$onboardingStatus, step=$currentStep');

    if (onboardingStatus == 'APPROVED') {
      return AppRoutes.dashboard;
    } else if (currentStep == 'BUSINESS_DOCS') {
      return AppRoutes.verifyDocuments;
    } else if (currentStep == 'IDENTITY_BANK') {
      return AppRoutes.identityBank;
    } else if (currentStep == 'KITCHEN_HYGIENE') {
      return AppRoutes.reviewApplication;
    } else if (onboardingStatus == 'PENDING_REVIEW' ||
        currentStep == 'PENDING_REVIEW' ||
        currentStep == 'COMPLETED') {
      return AppRoutes.applicationSubmitted;
    } else {
      return AppRoutes.businessProfile;
    }
  }

  /// Gracefully logs out the partner, clears all credentials & user data from storage,
  /// and navigates cleanly to the Login screen, wiping the navigation stack.
  static Future<void> logout([BuildContext? context]) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    appLog("🚪 User-initiated logout: clearing all credentials & session state");

    try {
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.remove(AppKeys.accessToken);
      await prefs.remove(AppKeys.refreshToken);
      await prefs.remove(AppKeys.user);
      await prefs.clear();
      appLog("✅ SharedPreferences cleared successfully");
    } catch (e) {
      appLog("❌ Error clearing preferences on logout: $e");
    } finally {
      _isLoggingOut = false;
    }

    if (context != null && context.mounted) {
      context.go(AppRoutes.login);
    } else {
      appRouter.go(AppRoutes.login);
    }
  }

  /// Forced logout for expired or revoked tokens (e.g. 401 Unauthorized from backend).
  static Future<void> forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    appLog("🚨 Force logout triggered (expired or unauthorized session)");

    try {
      final prefs = await SharedPreferencesService.getInstance();
      await prefs.remove(AppKeys.accessToken);
      await prefs.remove(AppKeys.refreshToken);
      await prefs.remove(AppKeys.user);
      await prefs.clear();
      appLog("✅ SharedPreferences wiped on force logout");
    } catch (e) {
      appLog("❌ Error clearing prefs on force logout: $e");
    } finally {
      _isLoggingOut = false;
    }

    appRouter.go(AppRoutes.login);
  }
}
