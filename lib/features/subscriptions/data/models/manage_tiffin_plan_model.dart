class SubscriberItem {
  const SubscriberItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.endsInDays,
    required this.status,
    required this.avatarLetter,
  });

  final String id;
  final String name;
  final String phone;
  final int endsInDays;
  final String status;
  final String avatarLetter;

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}

class ManageTiffinPlanModel {
  const ManageTiffinPlanModel({
    required this.programId,
    required this.planTitle,
    required this.subtitle,
    required this.priceTitle,
    required this.statusText,
    required this.deliveryWindow,
    required this.mealSetup,
    required this.isPaused,
    required this.subscribersCount,
    required this.subscribers,
  });

  final String programId;
  final String planTitle;
  final String subtitle;
  final String priceTitle;
  final String statusText;
  final String deliveryWindow;
  final String mealSetup;
  final bool isPaused;
  final int subscribersCount;
  final List<SubscriberItem> subscribers;

  static const dummyMonthlyLunch = ManageTiffinPlanModel(
    programId: '1',
    planTitle: 'Monthly Lunch Plan',
    subtitle: 'Details & subscribers listing',
    priceTitle: '₹999/Month',
    statusText: 'ACTIVE',
    deliveryWindow: '12:00 PM - 1:00 PM',
    mealSetup: '2 Meals (Lunch Only)',
    isPaused: false,
    subscribersCount: 0,
    subscribers: [],
  );

  static const dummyWeeklyDinner = ManageTiffinPlanModel(
    programId: '2',
    planTitle: 'Weekly Dinner Plan',
    subtitle: 'Details & subscribers listing',
    priceTitle: '₹350/Week',
    statusText: 'ACTIVE',
    deliveryWindow: '7:30 PM - 8:30 PM',
    mealSetup: '1 Meal (Dinner Only)',
    isPaused: false,
    subscribersCount: 0,
    subscribers: [],
  );

  ManageTiffinPlanModel copyWith({
    String? programId,
    String? planTitle,
    String? subtitle,
    String? priceTitle,
    String? statusText,
    String? deliveryWindow,
    String? mealSetup,
    bool? isPaused,
    int? subscribersCount,
    List<SubscriberItem>? subscribers,
  }) {
    return ManageTiffinPlanModel(
      programId: programId ?? this.programId,
      planTitle: planTitle ?? this.planTitle,
      subtitle: subtitle ?? this.subtitle,
      priceTitle: priceTitle ?? this.priceTitle,
      statusText: statusText ?? this.statusText,
      deliveryWindow: deliveryWindow ?? this.deliveryWindow,
      mealSetup: mealSetup ?? this.mealSetup,
      isPaused: isPaused ?? this.isPaused,
      subscribersCount: subscribersCount ?? this.subscribersCount,
      subscribers: subscribers ?? this.subscribers,
    );
  }
}
