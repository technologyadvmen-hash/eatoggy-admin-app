import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/subscriptions_plans_model.dart';
import '../../data/repositories/subscriptions_repository.dart';

class SubscriptionsPlansState {
  const SubscriptionsPlansState({
    required this.model,
    this.isLoading = false,
    this.errorMessage,
  });

  final SubscriptionsPlansModel model;
  final bool isLoading;
  final String? errorMessage;

  SubscriptionsPlansState copyWith({
    SubscriptionsPlansModel? model,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SubscriptionsPlansState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SubscriptionsPlansNotifier extends Notifier<SubscriptionsPlansState> {
  final SubscriptionsRepository _subscriptionsRepository =
      SubscriptionsRepository();

  @override
  SubscriptionsPlansState build() {
    _fetchLivePlans();
    return const SubscriptionsPlansState(
      model: SubscriptionsPlansModel.dummy,
    );
  }

  Future<void> _fetchLivePlans() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final rawPlans = await _subscriptionsRepository.getTiffinPlans();

      final mappedPrograms = rawPlans.map((plan) {
        final id = plan['_id']?.toString() ?? '';
        final name = plan['name']?.toString() ?? 'Tiffin Plan';
        final mealType = plan['mealType']?.toString() ?? 'LUNCH';
        final pricePerMeal = plan['pricePerMeal'] ?? 150;
        final totalPrice = plan['totalPrice'] ?? (pricePerMeal * 7);
        final duration = plan['planDurationDays'] ?? 7;
        final desc = plan['description']?.toString() ?? '';

        return TiffinProgramItem(
          id: id,
          title: name,
          price: '₹$pricePerMeal/meal • ₹$totalPrice',
          mealDetails: '$mealType • $duration Days • $desc',
          activeSubscribersCount: (plan['activeSubscribers'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final totalSubscribers = mappedPrograms.fold<int>(
        0,
        (sum, p) => sum + p.activeSubscribersCount,
      );

      final updatedModel = state.model.copyWith(
        programs: mappedPrograms,
        activeUsersText: '$totalSubscribers active users',
      );

      state = state.copyWith(
        model: updatedModel,
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on live tiffin plans fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshPlans() async {
    await _fetchLivePlans();
  }
}

final subscriptionsPlansProvider =
    NotifierProvider<SubscriptionsPlansNotifier, SubscriptionsPlansState>(
  SubscriptionsPlansNotifier.new,
);

