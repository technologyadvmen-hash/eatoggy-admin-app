import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/kitchen_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class KitchenProfileState {
  final KitchenProfileModel model;
  final bool isSaving;
  final bool isLoading;

  const KitchenProfileState({
    required this.model,
    this.isSaving = false,
    this.isLoading = false,
  });

  KitchenProfileState copyWith({
    KitchenProfileModel? model,
    bool? isSaving,
    bool? isLoading,
  }) {
    return KitchenProfileState(
      model: model ?? this.model,
      isSaving: isSaving ?? this.isSaving,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class KitchenProfileNotifier extends Notifier<KitchenProfileState> {
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  KitchenProfileState build() {
    _loadCachedUser();
    Future.microtask(() => loadKitchenProfile());
    return KitchenProfileState(
      model: KitchenProfileModel.dummy,
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
        final addr = user['address']?.toString() ?? user['fullAddress']?.toString() ?? '';
        state = state.copyWith(
          model: state.model.copyWith(
            kitchenName: restName.isNotEmpty ? restName : state.model.kitchenName,
            ownerName: owner.isNotEmpty ? owner : state.model.ownerName,
            businessType: type.isNotEmpty ? type : state.model.businessType,
            address: addr.isNotEmpty ? addr : state.model.address,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> loadKitchenProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = await _profileRepository.getRestaurantProfile();
      state = state.copyWith(
        isLoading: false,
        model: state.model.copyWith(
          kitchenName: profile.restaurantName.isNotEmpty ? profile.restaurantName : state.model.kitchenName,
          ownerName: profile.ownerName.isNotEmpty ? profile.ownerName : state.model.ownerName,
          businessType: profile.restaurantType.isNotEmpty ? profile.restaurantType : state.model.businessType,
          cuisines: profile.cuisinesString.isNotEmpty
              ? profile.cuisinesString
              : state.model.cuisines,
          address: profile.formattedAddress.isNotEmpty
              ? profile.formattedAddress
              : state.model.address,
        ),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshProfile() async {
    await loadKitchenProfile();
  }

  void updateOwnerName(String name) {
    state = state.copyWith(
      model: state.model.copyWith(ownerName: name),
    );
  }

  void updateBusinessType(String type) {
    state = state.copyWith(
      model: state.model.copyWith(businessType: type),
    );
  }

  void updateCuisines(String cuisines) {
    state = state.copyWith(
      model: state.model.copyWith(cuisines: cuisines),
    );
  }

  void updateAddress(String address) {
    state = state.copyWith(
      model: state.model.copyWith(address: address),
    );
  }

  void updateOperatingHours(String hours) {
    state = state.copyWith(
      model: state.model.copyWith(operatingHours: hours),
    );
  }

  void updateKitchenName(String name) {
    state = state.copyWith(
      model: state.model.copyWith(kitchenName: name),
    );
  }

  void updateBannerImage(String path) {
    state = state.copyWith(
      model: state.model.copyWith(bannerImagePath: path),
    );
  }

  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isSaving: false);
  }
}

final kitchenProfileProvider =
    NotifierProvider<KitchenProfileNotifier, KitchenProfileState>(
  KitchenProfileNotifier.new,
);
