import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../wallet/data/models/wallet_model.dart';
import '../../../wallet/data/repositories/wallet_repository.dart';
import '../../data/models/transactions_model.dart';

class TransactionsState {
  final TransactionsModel model;
  final String selectedType;
  final String dateRangeLabel;
  final DateTime? startDate;
  final DateTime? endDate;
  final int visibleCount;
  final bool isLoading;
  final String? errorMessage;

  const TransactionsState({
    required this.model,
    this.selectedType = 'All Types',
    this.dateRangeLabel = '01 Oct - 31 Oct',
    this.startDate,
    this.endDate,
    this.visibleCount = 6,
    this.isLoading = false,
    this.errorMessage,
  });

  List<TransactionItemModel> get filteredTransactions {
    return model.allTransactions.where((item) {
      if (selectedType != 'All Types' && item.tag != selectedType) {
        return false;
      }
      if (startDate != null && endDate != null) {
        if (item.date.isBefore(startDate!) ||
            item.date.isAfter(endDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).take(visibleCount).toList();
  }

  int get totalMatchingCount {
    return model.allTransactions.where((item) {
      if (selectedType != 'All Types' && item.tag != selectedType) {
        return false;
      }
      if (startDate != null && endDate != null) {
        if (item.date.isBefore(startDate!) ||
            item.date.isAfter(endDate!.add(const Duration(days: 1)))) {
          return false;
        }
      }
      return true;
    }).length;
  }

  bool get canLoadMore => visibleCount < totalMatchingCount;

  TransactionsState copyWith({
    TransactionsModel? model,
    String? selectedType,
    String? dateRangeLabel,
    DateTime? startDate,
    DateTime? endDate,
    int? visibleCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TransactionsState(
      model: model ?? this.model,
      selectedType: selectedType ?? this.selectedType,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      visibleCount: visibleCount ?? this.visibleCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class TransactionsNotifier extends Notifier<TransactionsState> {
  final WalletRepository _walletRepository = WalletRepository();

  @override
  TransactionsState build() {
    Future.microtask(() => loadTransactionsData());
    return const TransactionsState(
      model: TransactionsModel(
        withdrawableBalance: '₹0.00',
        dateRangeLabel: 'Current Month',
        allTransactions: [],
      ),
      isLoading: true,
    );
  }

  /// Load live transactions and wallet balance
  Future<void> loadTransactionsData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _walletRepository.getWallet(),
        _walletRepository.getTransactions(page: 1, limit: 50),
      ]);

      final wallet = results[0] as WalletDetailsModel;
      final txItems = results[1] as List<WalletTransactionItem>;

      final mappedTx = txItems.map((tx) {
        final parsedDate =
            DateTime.tryParse(tx.date)?.toLocal() ?? DateTime.now();
        final (tag, category) = _mapCategory(tx.type, tx.isCredit);
        final prefix = tx.isCredit ? '+' : '-';
        return TransactionItemModel(
          id: tx.id,
          title: tx.title,
          tag: tag,
          subtitle: tx.subtitle,
          timestamp: _formatTimestamp(parsedDate),
          amount: '$prefix₹${tx.amount.toStringAsFixed(0)}',
          isCredit: tx.isCredit,
          category: category,
          date: parsedDate,
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        model: TransactionsModel(
          withdrawableBalance: '₹${wallet.currentBalance.toStringAsFixed(2)}',
          dateRangeLabel: state.dateRangeLabel,
          allTransactions: mappedTx,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshTransactions() async {
    await loadTransactionsData();
  }

  (String, TransactionCategory) _mapCategory(String type, bool isCredit) {
    final lower = type.toLowerCase();
    if (lower.contains('settle') || lower.contains('withdraw')) {
      return ('Settlement', TransactionCategory.settlement);
    }
    if (lower.contains('deduct') ||
        lower.contains('fee') ||
        lower.contains('commission') ||
        lower.contains('tax')) {
      return ('Deduction', TransactionCategory.deduction);
    }
    if (lower.contains('subscription') || lower.contains('tiffin')) {
      return ('Subscription', TransactionCategory.subscription);
    }
    return ('Food Order', TransactionCategory.foodOrder);
  }

  String _formatTimestamp(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month, ${hour.toString().padLeft(2, '0')}:$min $ampm';
  }

  void filterByType(String type) {
    state = state.copyWith(
      selectedType: type,
      visibleCount: 6,
    );
  }

  Future<void> selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: state.startDate != null && state.endDate != null
          ? DateTimeRange(start: state.startDate!, end: state.endDate!)
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: DateTime(now.year, now.month + 1, 0),
            ),
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
      final label =
          '${_formatDate(picked.start)} - ${_formatDate(picked.end)}';
      state = state.copyWith(
        startDate: picked.start,
        endDate: picked.end,
        dateRangeLabel: label,
        visibleCount: 6,
      );
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    return '$day $month';
  }

  bool loadMore() {
    if (state.canLoadMore) {
      state = state.copyWith(visibleCount: state.visibleCount + 4);
      return true;
    }
    return false;
  }
}

final transactionsProvider =
    NotifierProvider<TransactionsNotifier, TransactionsState>(
  TransactionsNotifier.new,
);
