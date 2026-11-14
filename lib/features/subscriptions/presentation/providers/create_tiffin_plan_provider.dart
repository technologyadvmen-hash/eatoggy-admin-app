import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/create_tiffin_plan_model.dart';
import '../../data/repositories/subscriptions_repository.dart';
import 'subscriptions_plans_provider.dart';

class CreateTiffinPlanState {
  const CreateTiffinPlanState({
    required this.model,
    required this.selectedCycleType,
    required this.mealsPerDay,
    required this.rotatingWeeklyMenu,
    this.isPublishing = false,
  });

  final CreateTiffinPlanModel model;
  final String selectedCycleType;
  final int mealsPerDay;
  final bool rotatingWeeklyMenu;
  final bool isPublishing;

  CreateTiffinPlanState copyWith({
    CreateTiffinPlanModel? model,
    String? selectedCycleType,
    int? mealsPerDay,
    bool? rotatingWeeklyMenu,
    bool? isPublishing,
  }) {
    return CreateTiffinPlanState(
      model: model ?? this.model,
      selectedCycleType: selectedCycleType ?? this.selectedCycleType,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
      rotatingWeeklyMenu: rotatingWeeklyMenu ?? this.rotatingWeeklyMenu,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }
}

class CreateTiffinPlanNotifier extends Notifier<CreateTiffinPlanState> {
  final SubscriptionsRepository _subscriptionsRepository =
      SubscriptionsRepository();

  @override
  CreateTiffinPlanState build() {
    final defaultModel = CreateTiffinPlanModel.dummy;
    return CreateTiffinPlanState(
      model: defaultModel,
      selectedCycleType: defaultModel.selectedCycleType,
      mealsPerDay: defaultModel.mealsPerDay,
      rotatingWeeklyMenu: defaultModel.rotatingWeeklyMenu,
    );
  }

  void selectCycleType(String cycle) {
    state = state.copyWith(selectedCycleType: cycle);
  }

  void selectMealsPerDay(int count) {
    state = state.copyWith(mealsPerDay: count);
  }

  void toggleRotatingWeeklyMenu(bool val) {
    state = state.copyWith(rotatingWeeklyMenu: val);
  }

  /// Create a new tiffin plan (POST /api/restaurants/tiffin-plans)
  Future<bool> createPlan({
    required String name,
    required String description,
    required num pricePerMeal,
    String mealType = 'LUNCH',
    int planDurationDays = 7,
    List<String>? availableDays,
    List<Map<String, dynamic>>? items,
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    state = state.copyWith(isPublishing: true);
    try {
      await _subscriptionsRepository.createTiffinPlan(
        name: name,
        description: description,
        mealType: mealType,
        pricePerMeal: pricePerMeal,
        planDurationDays: planDurationDays,
        availableDays: availableDays,
        items: items,
      );

      state = state.copyWith(isPublishing: false);
      ref.read(subscriptionsPlansProvider.notifier).refreshPlans();
      onSuccess();
      return true;
    } catch (e) {
      state = state.copyWith(isPublishing: false);
      onError(e.toString());
      return false;
    }
  }
}

final createTiffinPlanProvider =
    NotifierProvider<CreateTiffinPlanNotifier, CreateTiffinPlanState>(
  CreateTiffinPlanNotifier.new,
);

