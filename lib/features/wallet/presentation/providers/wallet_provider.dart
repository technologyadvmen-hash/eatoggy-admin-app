import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';
import '../widgets/transaction_tile.dart';

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.status,
    required this.type,
  });

  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final String date;
  final String status;
  final TransactionType type;
}

class WalletState {
  const WalletState({
    required this.availableBalance,
    required this.pendingSettlement,
    this.totalEarnings = 0.0,
    this.totalWithdrawals = 0.0,
    this.lastSettlementAmount = 0.0,
    required this.bankName,
    required this.bankAccountMasked,
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
  });

  final double availableBalance;
  final double pendingSettlement;
  final double totalEarnings;
  final double totalWithdrawals;
  final double lastSettlementAmount;
  final String bankName;
  final String bankAccountMasked;
  final List<WalletTransaction> transactions;
  final bool isLoading;
  final String? errorMessage;

  WalletState copyWith({
    double? availableBalance,
    double? pendingSettlement,
    double? totalEarnings,
    double? totalWithdrawals,
    double? lastSettlementAmount,
    String? bankName,
    String? bankAccountMasked,
    List<WalletTransaction>? transactions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WalletState(
      availableBalance: availableBalance ?? this.availableBalance,
      pendingSettlement: pendingSettlement ?? this.pendingSettlement,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalWithdrawals: totalWithdrawals ?? this.totalWithdrawals,
      lastSettlementAmount: lastSettlementAmount ?? this.lastSettlementAmount,
      bankName: bankName ?? this.bankName,
      bankAccountMasked: bankAccountMasked ?? this.bankAccountMasked,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  final WalletRepository _walletRepository = WalletRepository();

  @override
  WalletState build() {
    Future.microtask(() => loadWalletData());
    return const WalletState(
      availableBalance: 0.0,
      pendingSettlement: 0.0,
      totalEarnings: 0.0,
      totalWithdrawals: 0.0,
      lastSettlementAmount: 0.0,
      bankName: 'Bank Account',
      bankAccountMasked: '•••• •••• ••••',
      transactions: [],
      isLoading: true,
    );
  }

  /// Load live wallet details and transaction history from backend
  Future<void> loadWalletData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _walletRepository.getWallet(),
        _walletRepository.getTransactions(page: 1, limit: 20),
      ]);
      final wallet = results[0] as WalletDetailsModel;
      final txItems = results[1] as List<WalletTransactionItem>;

      final mappedTransactions = txItems.map((item) {
        return WalletTransaction(
          id: item.id,
          title: item.title,
          subtitle: item.subtitle,
          amount: '₹${item.amount.toStringAsFixed(2)}',
          isCredit: item.isCredit,
          date: _formatDate(item.date),
          status: item.status,
          type: _mapType(item.type, item.isCredit),
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        availableBalance: wallet.currentBalance,
        pendingSettlement: wallet.pendingAmount,
        totalEarnings: wallet.totalEarnings,
        totalWithdrawals: wallet.totalWithdrawals,
        lastSettlementAmount: wallet.lastSettlementAmount,
        transactions: mappedTransactions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshWallet() async {
    await loadWalletData();
  }

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty || rawDate == 'Recent') return 'Recent';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        final local = parsed.toLocal();
        final now = DateTime.now();
        final diff = now.difference(local);
        if (diff.inDays == 0 && now.day == local.day) {
          final hour = local.hour > 12
              ? local.hour - 12
              : (local.hour == 0 ? 12 : local.hour);
          final minute = local.minute.toString().padLeft(2, '0');
          final ampm = local.hour >= 12 ? 'PM' : 'AM';
          return 'Today, $hour:$minute $ampm';
        } else if (diff.inDays == 1 ||
            (diff.inDays == 0 && now.day != local.day)) {
          return 'Yesterday';
        } else {
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
          final hour = local.hour > 12
              ? local.hour - 12
              : (local.hour == 0 ? 12 : local.hour);
          final minute = local.minute.toString().padLeft(2, '0');
          final ampm = local.hour >= 12 ? 'PM' : 'AM';
          return '${local.day} ${months[local.month - 1]}, $hour:$minute $ampm';
        }
      }
    } catch (_) {}
    return rawDate;
  }

  TransactionType _mapType(String type, bool isCredit) {
    final lower = type.toLowerCase();
    if (lower.contains('withdraw')) return TransactionType.withdrawal;
    if (lower.contains('deduct') ||
        lower.contains('fee') ||
        lower.contains('commission')) {
      return TransactionType.deduction;
    }
    if (lower.contains('refund')) return TransactionType.refund;
    return isCredit ? TransactionType.payout : TransactionType.withdrawal;
  }

  bool requestWithdrawal(double amount) {
    if (amount <= 0 || amount > state.availableBalance) {
      return false;
    }

    final newTx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bank Transfer Withdrawal',
      subtitle: state.bankAccountMasked,
      amount: '₹${amount.toStringAsFixed(2)}',
      isCredit: false,
      date: 'Just now',
      status: 'Processing',
      type: TransactionType.withdrawal,
    );

    state = state.copyWith(
      availableBalance: state.availableBalance - amount,
      transactions: [newTx, ...state.transactions],
    );

    return true;
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
