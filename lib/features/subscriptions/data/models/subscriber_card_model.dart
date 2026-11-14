class DeliveryHistoryItem {
  const DeliveryHistoryItem({
    required this.dateText,
    required this.statusText,
    required this.isDelivered, // true -> 'Delivered', false -> 'Missed / Paused'
  });

  final String dateText;
  final String statusText;
  final bool isDelivered;
}

class SubscriberCardModel {
  const SubscriberCardModel({
    required this.customerId,
    required this.customerName,
    required this.subtitle,
    required this.planTitle,
    required this.statusText,
    required this.durationText,
    required this.daysRemainingText,
    required this.deliveryAddress,
    required this.specialInstructions,
    required this.partnerPhoneNumber,
    required this.isPaused,
    required this.history,
  });

  final String customerId;
  final String customerName;
  final String subtitle;
  final String planTitle;
  final String statusText;
  final String durationText;
  final String daysRemainingText;
  final String deliveryAddress;
  final String specialInstructions;
  final String partnerPhoneNumber;
  final bool isPaused;
  final List<DeliveryHistoryItem> history;

  static const empty = SubscriberCardModel(
    customerId: '',
    customerName: '',
    subtitle: 'Subscriber card details',
    planTitle: 'Tiffin Plan',
    statusText: 'ACTIVE',
    durationText: '',
    daysRemainingText: '',
    deliveryAddress: '',
    specialInstructions: '',
    partnerPhoneNumber: '',
    isPaused: false,
    history: [],
  );

  SubscriberCardModel copyWith({
    String? customerId,
    String? customerName,
    String? subtitle,
    String? planTitle,
    String? statusText,
    String? durationText,
    String? daysRemainingText,
    String deliveryAddress = '',
    String? specialInstructions,
    String? partnerPhoneNumber,
    bool? isPaused,
    List<DeliveryHistoryItem>? history,
  }) {
    return SubscriberCardModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      subtitle: subtitle ?? this.subtitle,
      planTitle: planTitle ?? this.planTitle,
      statusText: statusText ?? this.statusText,
      durationText: durationText ?? this.durationText,
      daysRemainingText: daysRemainingText ?? this.daysRemainingText,
      deliveryAddress: deliveryAddress.isNotEmpty ? deliveryAddress : this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      partnerPhoneNumber: partnerPhoneNumber ?? this.partnerPhoneNumber,
      isPaused: isPaused ?? this.isPaused,
      history: history ?? this.history,
    );
  }
}
