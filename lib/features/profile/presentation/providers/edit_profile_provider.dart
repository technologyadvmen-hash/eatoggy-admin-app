import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/edit_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class EditProfileState {
  final EditProfileModel model;
  final bool isSaving;

  const EditProfileState({
    required this.model,
    this.isSaving = false,
  });

  EditProfileState copyWith({
    EditProfileModel? model,
    bool? isSaving,
  }) {
    return EditProfileState(
      model: model ?? this.model,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class EditProfileNotifier extends Notifier<EditProfileState> {
  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  EditProfileState build() {
    _loadProfile();
    return EditProfileState(
      model: EditProfileModel.dummy,
    );
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final userJson = prefs.getString(AppKeys.user);
      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        final restName = user['restaurantName']?.toString() ?? '';
        final mobile = user['mobile']?.toString() ?? '';
        state = state.copyWith(
          model: state.model.copyWith(
            kitchenName: restName.isNotEmpty ? restName : state.model.kitchenName,
            phoneNumber: mobile.isNotEmpty ? mobile : state.model.phoneNumber,
          ),
        );
      }

      final profile = await _profileRepository.getRestaurantProfile();
      state = state.copyWith(
        model: state.model.copyWith(
          kitchenName: profile.restaurantName.isNotEmpty ? profile.restaurantName : state.model.kitchenName,
          phoneNumber: profile.mobile.isNotEmpty ? profile.mobile : state.model.phoneNumber,
          cuisines: profile.cuisines.isNotEmpty ? profile.cuisines : state.model.cuisines,
        ),
      );
    } catch (_) {}
  }

  void updateKitchenName(String name) {
    state = state.copyWith(
      model: state.model.copyWith(kitchenName: name),
    );
  }

  void updateBio(String bio) {
    state = state.copyWith(
      model: state.model.copyWith(bio: bio),
    );
  }

  void addCuisine(String cuisine) {
    if (!state.model.cuisines.contains(cuisine)) {
      final updated = List<String>.from(state.model.cuisines)..add(cuisine);
      state = state.copyWith(
        model: state.model.copyWith(cuisines: updated),
      );
    }
  }

  void removeCuisine(String cuisine) {
    final updated = List<String>.from(state.model.cuisines)..remove(cuisine);
    state = state.copyWith(
      model: state.model.copyWith(cuisines: updated),
    );
  }

  void updateOpenTime(String time) {
    state = state.copyWith(
      model: state.model.copyWith(openTime: time),
    );
  }

  void updateCloseTime(String time) {
    state = state.copyWith(
      model: state.model.copyWith(closeTime: time),
    );
  }

  void updateMinOrderValue(String value) {
    state = state.copyWith(
      model: state.model.copyWith(minOrderValue: value),
    );
  }

  void updatePrepTime(String prepTime) {
    state = state.copyWith(
      model: state.model.copyWith(prepTime: prepTime),
    );
  }

  void updateAvatarImage(String imagePath) {
    state = state.copyWith(
      model: state.model.copyWith(avatarImagePath: imagePath),
    );
  }

  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(isSaving: false);
  }
}

final editProfileProvider =
    NotifierProvider<EditProfileNotifier, EditProfileState>(
  EditProfileNotifier.new,
);
