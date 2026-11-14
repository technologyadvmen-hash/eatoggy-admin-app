import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/device_token_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/models/splash_model.dart';

/// State representation for the Splash screen.
class SplashState {
  const SplashState({
    required this.isInitialized,
    required this.canNavigate,
    required this.data,
  });

  final bool isInitialized;
  final bool canNavigate;
  final SplashModel data;

  SplashState copyWith({
    bool? isInitialized,
    bool? canNavigate,
    SplashModel? data,
  }) {
    return SplashState(
      isInitialized: isInitialized ?? this.isInitialized,
      canNavigate: canNavigate ?? this.canNavigate,
      data: data ?? this.data,
    );
  }
}

/// Riverpod notifier managing Splash lifecycle, session check, and navigation trigger.
class SplashNotifier extends Notifier<SplashState> {
  Timer? _timer;

  @override
  SplashState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return const SplashState(
      isInitialized: true,
      canNavigate: false,
      data: SplashModel.dummy,
    );
  }

  /// Starts the splash delay and resolves route based on token & onboarding status.
  Future<void> initSplash() async {
    _timer?.cancel();

    String destination = AppRoutes.login;
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final token = prefs.getString(AppKeys.accessToken);
      final userJson = prefs.getString(AppKeys.user);

      if (token != null && token.trim().isNotEmpty && userJson != null && userJson.trim().isNotEmpty) {
        // Register device token in background
        unawaited(DeviceTokenService().registerDeviceToken());

        final user = jsonDecode(userJson) as Map<String, dynamic>;
        destination = SessionManager.resolveDestination(user);
      } else {
        destination = AppRoutes.login;
      }
    } catch (_) {
      destination = AppRoutes.login;
    }

    _timer = Timer(Duration(milliseconds: state.data.delayMilliseconds), () {
      state = state.copyWith(
        canNavigate: true,
        data: state.data.copyWith(nextRoute: destination),
      );
    });
  }
}

final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);

