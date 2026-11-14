import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/subscriber_card_model.dart';
import '../../data/models/tiffin_deliveries_model.dart';

class SubscriberCardState {
  const SubscriberCardState({
    required this.model,
    required this.isPaused,
  });

  final SubscriberCardModel model;
  final bool isPaused;

  SubscriberCardState copyWith({
    SubscriberCardModel? model,
    bool? isPaused,
  }) {
    return SubscriberCardState(
      model: model ?? this.model,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class SubscriberCardNotifier extends Notifier<SubscriberCardState> {
  @override
  SubscriberCardState build() {
    return const SubscriberCardState(
      model: SubscriberCardModel.empty,
      isPaused: false,
    );
  }

  void initializeForCustomer(DeliveryMealItem item) {
    final customized = SubscriberCardModel(
      customerId: item.id,
      customerName: item.customerName.isNotEmpty ? item.customerName : 'Subscriber',
      subtitle: 'Subscriber card details',
      planTitle: '${item.mealType} Tiffin Plan',
      statusText: item.status,
      durationText: 'Active Subscription',
      daysRemainingText: '--',
      deliveryAddress: 'Customer Delivery Address',
      specialInstructions: item.itemsText.isNotEmpty ? item.itemsText : 'Standard delivery',
      partnerPhoneNumber: '',
      isPaused: false,
      history: const [],
    );

    state = SubscriberCardState(
      model: customized,
      isPaused: false,
    );
  }

  void togglePausePlan() {
    final nextPaused = !state.isPaused;
    state = state.copyWith(
      isPaused: nextPaused,
      model: state.model.copyWith(
        isPaused: nextPaused,
        statusText: nextPaused ? 'PAUSED' : 'ACTIVE',
      ),
    );
  }

  Future<void> callPartner() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: state.model.partnerPhoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (_) {}
  }
}

final subscriberCardProvider =
    NotifierProvider<SubscriberCardNotifier, SubscriberCardState>(
  SubscriberCardNotifier.new,
);
