class DeliveryMealItem {
  const DeliveryMealItem({
    required this.id,
    required this.customerName,
    required this.status,
    required this.itemsText,
    required this.slotText,
    required this.mealType, // 'Lunch' or 'Dinner'
  });

  final String id;
  final String customerName;
  final String status; // 'OUT FOR DELIVERY', 'PACKED', 'PREPARING'
  final String itemsText;
  final String slotText;
  final String mealType;
}

class TiffinDeliveriesModel {
  const TiffinDeliveriesModel({
    required this.title,
    required this.subtitle,
    required this.selectedDateText,
    required this.packedCount,
    required this.totalCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.deliveries,
  });

  final String title;
  final String subtitle;
  final String selectedDateText;
  final int packedCount;
  final int totalCount;
  final int lunchCount;
  final int dinnerCount;
  final List<DeliveryMealItem> deliveries;

  static const dummy = TiffinDeliveriesModel(
    title: 'Tiffin Deliveries',
    subtitle: 'Manage dispatched tiffin meals',
    selectedDateText: 'Today',
    packedCount: 0,
    totalCount: 0,
    lunchCount: 0,
    dinnerCount: 0,
    deliveries: [],
  );

  TiffinDeliveriesModel copyWith({
    String? title,
    String? subtitle,
    String? selectedDateText,
    int? packedCount,
    int? totalCount,
    int? lunchCount,
    int? dinnerCount,
    List<DeliveryMealItem>? deliveries,
  }) {
    return TiffinDeliveriesModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      selectedDateText: selectedDateText ?? this.selectedDateText,
      packedCount: packedCount ?? this.packedCount,
      totalCount: totalCount ?? this.totalCount,
      lunchCount: lunchCount ?? this.lunchCount,
      dinnerCount: dinnerCount ?? this.dinnerCount,
      deliveries: deliveries ?? this.deliveries,
    );
  }
}
