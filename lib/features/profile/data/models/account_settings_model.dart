class AccountSettingsModel {
  const AccountSettingsModel({
    required this.bistroName,
    required this.chefName,
    required this.role,
    required this.statusText,
    required this.isActive,
    required this.avatarUrl,
    required this.avgRating,
    required this.reviewCount,
    required this.hasNewFeedback,
    required this.weeklyEarnings,
    required this.kitchenProfileSummary,
    required this.notificationsEnabled,
  });

  final String bistroName;
  final String chefName;
  final String role;
  final String statusText;
  final bool isActive;
  final String avatarUrl;
  final String avgRating;
  final int reviewCount;
  final bool hasNewFeedback;
  final String weeklyEarnings;
  final String kitchenProfileSummary;
  final bool notificationsEnabled;

  AccountSettingsModel copyWith({
    String? bistroName,
    String? chefName,
    String? role,
    String? statusText,
    bool? isActive,
    String? avatarUrl,
    String? avgRating,
    int? reviewCount,
    bool? hasNewFeedback,
    String? weeklyEarnings,
    String? kitchenProfileSummary,
    bool? notificationsEnabled,
  }) {
    return AccountSettingsModel(
      bistroName: bistroName ?? this.bistroName,
      chefName: chefName ?? this.chefName,
      role: role ?? this.role,
      statusText: statusText ?? this.statusText,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avgRating: avgRating ?? this.avgRating,
      reviewCount: reviewCount ?? this.reviewCount,
      hasNewFeedback: hasNewFeedback ?? this.hasNewFeedback,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      kitchenProfileSummary:
          kitchenProfileSummary ?? this.kitchenProfileSummary,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static const defaultModel = AccountSettingsModel(
    bistroName: 'Restaurant Partner',
    chefName: 'Partner Owner',
    role: 'Cloud Kitchen',
    statusText: 'Active Partner',
    isActive: true,
    avatarUrl: '',
    avgRating: '5.0',
    reviewCount: 0,
    hasNewFeedback: false,
    weeklyEarnings: '₹0',
    kitchenProfileSummary: 'Menu setup, custom hours, holidays',
    notificationsEnabled: true,
  );
}
