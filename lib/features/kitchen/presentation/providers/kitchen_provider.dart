import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/kitchen_model.dart';
import '../../data/models/kitchen_order_model.dart';
import '../../data/repositories/kitchen_repository.dart';

class KitchenState {
  const KitchenState({
    required this.model,
    this.isOnline = true,
    this.autoAcceptSubscription = true,
    this.orders = const [],
    this.isLoading = false,
    this.isHygieneUploading = false,
    this.hygieneSuccess = false,
  });

  final KitchenScreenModel model;
  final bool isOnline;
  final bool autoAcceptSubscription;
  final List<KitchenOrderModel> orders;
  final bool isLoading;
  final bool isHygieneUploading;
  final bool hygieneSuccess;

  KitchenState copyWith({
    KitchenScreenModel? model,
    bool? isOnline,
    bool? autoAcceptSubscription,
    List<KitchenOrderModel>? orders,
    bool? isLoading,
    bool? isHygieneUploading,
    bool? hygieneSuccess,
  }) {
    return KitchenState(
      model: model ?? this.model,
      isOnline: isOnline ?? this.isOnline,
      autoAcceptSubscription:
          autoAcceptSubscription ?? this.autoAcceptSubscription,
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isHygieneUploading: isHygieneUploading ?? this.isHygieneUploading,
      hygieneSuccess: hygieneSuccess ?? this.hygieneSuccess,
    );
  }
}

class KitchenNotifier extends Notifier<KitchenState> {
  final KitchenRepository _kitchenRepository = KitchenRepository();

  @override
  KitchenState build() {
    _loadLiveKitchenData();
    return const KitchenState(
      model: KitchenScreenModel.dummy,
      isOnline: true,
      autoAcceptSubscription: true,
    );
  }

  Future<void> _loadLiveKitchenData() async {
    try {
      state = state.copyWith(isLoading: true);
      final orders = await _kitchenRepository.getKitchenOrders();
      final activeCount = orders.where((o) =>
          o.orderStatus != 'DELIVERED' && o.orderStatus != 'CANCELLED').length;

      final updatedModel = state.model.copyWith(
        activeQueue: '$activeCount Orders',
      );

      state = state.copyWith(
        model: updatedModel,
        orders: orders,
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on kitchen queue load: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshQueue() async {
    await _loadLiveKitchenData();
  }

  /// Upload Kitchen Hygiene proof (POST /api/restaurant-onboarding/kitchen-hygiene)
  Future<bool> uploadHygieneProof({
    required File mainPrepStation,
    File? storageAndFridge,
    File? dishwashingArea,
  }) async {
    state = state.copyWith(isHygieneUploading: true);
    try {
      final res = await _kitchenRepository.uploadKitchenHygieneProof(
        mainPrepStation: mainPrepStation,
        storageAndFridge: storageAndFridge,
        dishwashingArea: dishwashingArea,
      );
      state = state.copyWith(
        isHygieneUploading: false,
        hygieneSuccess: res['success'] == true,
      );
      return res['success'] == true;
    } catch (e) {
      state = state.copyWith(isHygieneUploading: false);
      rethrow;
    }
  }

  void toggleOnline(bool val) {
    state = state.copyWith(isOnline: val);
  }

  void toggleAutoAccept(bool val) {
    state = state.copyWith(autoAcceptSubscription: val);
  }

  void setOffline() {
    state = state.copyWith(isOnline: false);
  }
}

final kitchenProvider = NotifierProvider<KitchenNotifier, KitchenState>(
  KitchenNotifier.new,
);

