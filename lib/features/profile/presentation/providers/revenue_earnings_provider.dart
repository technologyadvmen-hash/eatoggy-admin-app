import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/revenue_earnings_model.dart';
import '../../data/repositories/earnings_repository.dart';

class RevenueEarningsState {
  const RevenueEarningsState({
    required this.model,
    this.selectedPeriod = 'This Month',
    this.totalPaid = 0,
    this.totalPending = 0,
    this.totalRevenue = 0,
    this.netEarnings = 0,
    this.platformCommission = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final RevenueEarningsModel model;
  final String selectedPeriod;
  final num totalPaid;
  final num totalPending;
  final num totalRevenue;
  final num netEarnings;
  final num platformCommission;
  final bool isLoading;
  final String? errorMessage;

  PeriodEarnings get activeEarnings =>
      model.periodsData[selectedPeriod] ??
      model.periodsData['This Month']!;

  RevenueEarningsState copyWith({
    RevenueEarningsModel? model,
    String? selectedPeriod,
    num? totalPaid,
    num? totalPending,
    num? totalRevenue,
    num? netEarnings,
    num? platformCommission,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RevenueEarningsState(
      model: model ?? this.model,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      totalPaid: totalPaid ?? this.totalPaid,
      totalPending: totalPending ?? this.totalPending,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      netEarnings: netEarnings ?? this.netEarnings,
      platformCommission: platformCommission ?? this.platformCommission,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RevenueEarningsNotifier extends Notifier<RevenueEarningsState> {
  final EarningsRepository _earningsRepository = EarningsRepository();

  @override
  RevenueEarningsState build() {
    _fetchLiveEarnings();
    return const RevenueEarningsState(
      model: RevenueEarningsModel.dummy,
      selectedPeriod: 'This Month',
    );
  }

  Future<void> _fetchLiveEarnings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // 1. Fetch settlements & payouts from GET /api/restaurants/earnings
      final earningsData = await _earningsRepository.getEarnings();
      final totalPaid = earningsData['totalPaid'] as num? ?? 0;
      final totalPending = earningsData['totalPending'] as num? ?? 0;

      // 2. Fetch overview metrics from GET /api/restaurants/analytics/overview
      final analyticsData = await _earningsRepository.getAnalyticsOverview();
      final metrics = analyticsData['metrics'] as Map<String, dynamic>? ?? {};
      final totalRev = metrics['totalRevenue'] as num? ?? 0;
      final netEarn = metrics['netEarnings'] as num? ?? 0;
      final commission = metrics['platformCommission'] as num? ?? 0;
      final totalOrders = metrics['totalOrders'] as num? ?? 0;

      // Update model with live earnings
      final currentPeriodData =
          Map<String, PeriodEarnings>.from(state.model.periodsData);
      final thisMonth = currentPeriodData['This Month'];
      if (thisMonth != null) {
        currentPeriodData['This Month'] = PeriodEarnings(
          periodLabel: thisMonth.periodLabel,
          totalEarnings: '₹${netEarn > 0 ? netEarn : totalRev}',
          trendText: thisMonth.trendText,
          isTrendPositive: thisMonth.isTrendPositive,
          foodOrdersAmount: '₹$totalRev',
          foodOrdersCount: '$totalOrders Orders',
          subscriptionsAmount: thisMonth.subscriptionsAmount,
          subscriptionsCount: thisMonth.subscriptionsCount,
          packagingAmount: '₹$commission',
          packagingRate: 'Commission',
        );
      }

      state = state.copyWith(
        totalPaid: totalPaid,
        totalPending: totalPending,
        totalRevenue: totalRev,
        netEarnings: netEarn,
        platformCommission: commission,
        model: state.model.copyWith(periodsData: currentPeriodData),
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on live earnings fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshEarnings() async {
    await _fetchLiveEarnings();
  }

  void selectPeriod(String period) {
    state = state.copyWith(
      selectedPeriod: period,
      model: state.model.copyWith(selectedPeriod: period),
    );
  }

  Future<void> selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.headingPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectPeriod('Custom');
    }
  }
}

final revenueEarningsProvider =
    NotifierProvider<RevenueEarningsNotifier, RevenueEarningsState>(
  RevenueEarningsNotifier.new,
);

