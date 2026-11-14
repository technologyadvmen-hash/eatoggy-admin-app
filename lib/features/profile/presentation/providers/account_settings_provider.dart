import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/account_settings_model.dart';
import '../../data/models/restaurant_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class AccountSettingsState {
  const AccountSettingsState({
    required this.model,
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  final AccountSettingsModel model;
  final RestaurantProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;

  AccountSettingsState copyWith({
    AccountSettingsModel? model,
    RestaurantProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AccountSettingsState(
      model: model ?? this.model,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AccountSettingsNotifier extends Notifier<AccountSettingsState> {
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  AccountSettingsState build() {
    _loadCachedUser();
    Future.microtask(() => loadProfile());
    return const AccountSettingsState(
      model: AccountSettingsModel.defaultModel,
      isLoading: true,
    );
  }

  Future<void> _loadCachedUser() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final userJson = prefs.getString(AppKeys.user);
      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        final restName = user['restaurantName']?.toString() ?? '';
        final owner = user['ownerName']?.toString() ?? '';
        final type = user['restaurantType']?.toString() ?? '';
        if (restName.isNotEmpty || owner.isNotEmpty) {
          state = state.copyWith(
            model: state.model.copyWith(
              bistroName: restName.isNotEmpty ? restName : state.model.bistroName,
              chefName: owner.isNotEmpty ? owner : state.model.chefName,
              role: type.isNotEmpty ? type : state.model.role,
            ),
          );
        }
      }
    } catch (_) {}
  }

  /// Load live restaurant profile from GET /api/restaurants/profile
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _profileRepository.getRestaurantProfile();

      final updatedModel = state.model.copyWith(
        bistroName: profile.restaurantName.isNotEmpty ? profile.restaurantName : state.model.bistroName,
        chefName: profile.ownerName.isNotEmpty ? profile.ownerName : state.model.chefName,
        role: profile.restaurantType.isNotEmpty ? profile.restaurantType : state.model.role,
        isActive: profile.isOnline,
        statusText: profile.isOnline ? 'Active Partner' : 'Offline',
      );

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        model: updatedModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void togglePartnerStatus() {
    final currentStatus = state.model.isActive;
    state = state.copyWith(
      model: state.model.copyWith(
        isActive: !currentStatus,
        statusText: !currentStatus ? 'Active Partner' : 'Inactive Partner',
      ),
    );
  }

  void toggleNotifications() {
    final current = state.model.notificationsEnabled;
    state = state.copyWith(
      model: state.model.copyWith(
        notificationsEnabled: !current,
      ),
    );
  }

  void clearNewFeedbackBadge() {
    state = state.copyWith(
      model: state.model.copyWith(hasNewFeedback: false),
    );
  }
}

final accountSettingsProvider =
    NotifierProvider<AccountSettingsNotifier, AccountSettingsState>(
  AccountSettingsNotifier.new,
);
