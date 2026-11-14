class PeriodEarnings {
  const PeriodEarnings({
    required this.periodLabel,
    required this.totalEarnings,
    required this.trendText,
    required this.isTrendPositive,
    required this.foodOrdersAmount,
    required this.foodOrdersCount,
    required this.subscriptionsAmount,
    required this.subscriptionsCount,
    required this.packagingAmount,
    required this.packagingRate,
  });

  final String periodLabel;
  final String totalEarnings;
  final String trendText;
  final bool isTrendPositive;
  final String foodOrdersAmount;
  final String foodOrdersCount;
  final String subscriptionsAmount;
  final String subscriptionsCount;
  final String packagingAmount;
  final String packagingRate;
}

class DayTrendItem {
  const DayTrendItem({
    required this.dayLabel,
    required this.heightFactor,
    this.isHighlighted = false,
    required this.amount,
  });

  final String dayLabel;
  final double heightFactor;
  final bool isHighlighted;
  final String amount;
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.code,
    required this.type,
    required this.timeAgo,
    required this.amount,
    required this.isCredit,
  });

  final String id;
  final String code;
  final String type;
  final String timeAgo;
  final String amount;
  final bool isCredit;
}

class RevenueEarningsModel {
  const RevenueEarningsModel({
    required this.partnerName,
    required this.selectedPeriod,
    required this.periodsData,
    required this.weeklyTrend,
    required this.transactions,
  });

  final String partnerName;
  final String selectedPeriod;
  final Map<String, PeriodEarnings> periodsData;
  final List<DayTrendItem> weeklyTrend;
  final List<TransactionItem> transactions;

  PeriodEarnings get activeEarnings =>
      periodsData[selectedPeriod] ?? periodsData['This Month']!;

  RevenueEarningsModel copyWith({
    String? partnerName,
    String? selectedPeriod,
    Map<String, PeriodEarnings>? periodsData,
    List<DayTrendItem>? weeklyTrend,
    List<TransactionItem>? transactions,
  }) {
    return RevenueEarningsModel(
      partnerName: partnerName ?? this.partnerName,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      periodsData: periodsData ?? this.periodsData,
      weeklyTrend: weeklyTrend ?? this.weeklyTrend,
      transactions: transactions ?? this.transactions,
    );
  }

  static const dummy = RevenueEarningsModel(
    partnerName: 'Partner Restaurant',
    selectedPeriod: 'This Month',
    periodsData: {
      'Today': PeriodEarnings(
        periodLabel: 'TODAY',
        totalEarnings: '₹0',
        trendText: 'Live earnings',
        isTrendPositive: true,
        foodOrdersAmount: '₹0',
        foodOrdersCount: '0 orders',
        subscriptionsAmount: '₹0',
        subscriptionsCount: '0 plans',
        packagingAmount: '₹0',
        packagingRate: 'Flat rate',
      ),
      'This Week': PeriodEarnings(
        periodLabel: 'THIS WEEK',
        totalEarnings: '₹0',
        trendText: 'Live earnings',
        isTrendPositive: true,
        foodOrdersAmount: '₹0',
        foodOrdersCount: '0 orders',
        subscriptionsAmount: '₹0',
        subscriptionsCount: '0 plans',
        packagingAmount: '₹0',
        packagingRate: 'Flat rate',
      ),
      'This Month': PeriodEarnings(
        periodLabel: 'THIS MONTH',
        totalEarnings: '₹0',
        trendText: 'Live earnings',
        isTrendPositive: true,
        foodOrdersAmount: '₹0',
        foodOrdersCount: '0 orders',
        subscriptionsAmount: '₹0',
        subscriptionsCount: '0 plans',
        packagingAmount: '₹0',
        packagingRate: 'Flat rate',
      ),
      'Custom': PeriodEarnings(
        periodLabel: 'CUSTOM RANGE',
        totalEarnings: '₹0',
        trendText: 'Selected date range',
        isTrendPositive: true,
        foodOrdersAmount: '₹0',
        foodOrdersCount: '0 orders',
        subscriptionsAmount: '₹0',
        subscriptionsCount: '0 plans',
        packagingAmount: '₹0',
        packagingRate: 'Flat rate',
      ),
    },
    weeklyTrend: [
      DayTrendItem(dayLabel: 'M', heightFactor: 0.1, amount: '₹0'),
      DayTrendItem(dayLabel: 'T', heightFactor: 0.1, amount: '₹0'),
      DayTrendItem(dayLabel: 'W', heightFactor: 0.1, amount: '₹0'),
      DayTrendItem(dayLabel: 'T', heightFactor: 0.1, amount: '₹0'),
      DayTrendItem(dayLabel: 'F', heightFactor: 0.1, amount: '₹0'),
      DayTrendItem(
        dayLabel: 'S',
        heightFactor: 0.1,
        isHighlighted: true,
        amount: '₹0',
      ),
      DayTrendItem(dayLabel: 'S', heightFactor: 0.1, amount: '₹0'),
    ],
    transactions: [],
  );
}
