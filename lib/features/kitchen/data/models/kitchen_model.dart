class KitchenScreenModel {
  const KitchenScreenModel({
    required this.appName,
    required this.isOnline,
    required this.onlineStatusTitle,
    required this.onlineStatusSubtitle,
    required this.totalHours,
    required this.activeQueue,
    required this.autoAcceptSubscription,
    required this.dailyClosingTime,
    required this.afternoonBreakSlot,
  });

  final String appName;
  final bool isOnline;
  final String onlineStatusTitle;
  final String onlineStatusSubtitle;
  final String totalHours;
  final String activeQueue;
  final bool autoAcceptSubscription;
  final String dailyClosingTime;
  final String afternoonBreakSlot;

  static const dummy = KitchenScreenModel(
    appName: 'EATOGGY',
    isOnline: true,
    onlineStatusTitle: 'Kitchen is Currently Online',
    onlineStatusSubtitle: 'Ready for incoming orders',
    totalHours: '--',
    activeQueue: '0 Orders',
    autoAcceptSubscription: true,
    dailyClosingTime: '11:00 PM',
    afternoonBreakSlot: 'None',
  );

  KitchenScreenModel copyWith({
    String? appName,
    bool? isOnline,
    String? onlineStatusTitle,
    String? onlineStatusSubtitle,
    String? totalHours,
    String? activeQueue,
    bool? autoAcceptSubscription,
    String? dailyClosingTime,
    String? afternoonBreakSlot,
  }) {
    return KitchenScreenModel(
      appName: appName ?? this.appName,
      isOnline: isOnline ?? this.isOnline,
      onlineStatusTitle: onlineStatusTitle ?? this.onlineStatusTitle,
      onlineStatusSubtitle: onlineStatusSubtitle ?? this.onlineStatusSubtitle,
      totalHours: totalHours ?? this.totalHours,
      activeQueue: activeQueue ?? this.activeQueue,
      autoAcceptSubscription:
          autoAcceptSubscription ?? this.autoAcceptSubscription,
      dailyClosingTime: dailyClosingTime ?? this.dailyClosingTime,
      afternoonBreakSlot: afternoonBreakSlot ?? this.afternoonBreakSlot,
    );
  }
}

