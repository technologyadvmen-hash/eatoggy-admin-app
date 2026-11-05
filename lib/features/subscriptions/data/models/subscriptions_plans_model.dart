class TiffinProgramItem {
  const TiffinProgramItem({
    required this.id,
    required this.title,
    required this.price,
    required this.mealDetails,
    required this.activeSubscribersCount,
  });

  final String id;
  final String title;
  final String price;
  final String mealDetails;
  final int activeSubscribersCount;
}

class DispatchLoadItem {
  const DispatchLoadItem({
    required this.header,
    required this.countText,
    required this.subtitle,
  });

  final String header;
  final String countText;
  final String subtitle;
}

class SubscriptionsPlansModel {
  const SubscriptionsPlansModel({
    required this.title,
    required this.subtitle,
    required this.monthlyEarningsTitle,
    required this.monthlyEarningsAmount,
    required this.activeUsersText,
    required this.programsSectionTitle,
    required this.programs,
    required this.dispatchSectionTitle,
    required this.dispatchLoads,
  });

  final String title;
  final String subtitle;
  final String monthlyEarningsTitle;
  final String monthlyEarningsAmount;
  final String activeUsersText;
  final String programsSectionTitle;
  final List<TiffinProgramItem> programs;
  final String dispatchSectionTitle;
  final List<DispatchLoadItem> dispatchLoads;

  static const dummy = SubscriptionsPlansModel(
    title: 'Subscription Plans',
    subtitle: 'Active custom meal programs',
    monthlyEarningsTitle: 'MONTHLY EARNINGS ESTIMATE',
    monthlyEarningsAmount: '₹0',
    activeUsersText: '0 active users',
    programsSectionTitle: 'Active Tiffin Programs',
    programs: [],
    dispatchSectionTitle: 'Dispatch Load',
    dispatchLoads: [],
  );

  SubscriptionsPlansModel copyWith({
    String? title,
    String? subtitle,
    String? monthlyEarningsTitle,
    String? monthlyEarningsAmount,
    String? activeUsersText,
    String? programsSectionTitle,
    List<TiffinProgramItem>? programs,
    String? dispatchSectionTitle,
    List<DispatchLoadItem>? dispatchLoads,
  }) {
    return SubscriptionsPlansModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      monthlyEarningsTitle: monthlyEarningsTitle ?? this.monthlyEarningsTitle,
      monthlyEarningsAmount: monthlyEarningsAmount ?? this.monthlyEarningsAmount,
      activeUsersText: activeUsersText ?? this.activeUsersText,
      programsSectionTitle: programsSectionTitle ?? this.programsSectionTitle,
      programs: programs ?? this.programs,
      dispatchSectionTitle: dispatchSectionTitle ?? this.dispatchSectionTitle,
      dispatchLoads: dispatchLoads ?? this.dispatchLoads,
    );
  }
}

