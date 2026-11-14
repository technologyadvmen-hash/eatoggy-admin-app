class WalletDetailsModel {
  final String walletId;
  final String restaurantId;
  final double currentBalance;
  final double totalEarnings;
  final double totalWithdrawals;
  final double pendingAmount;
  final double lastSettlementAmount;

  const WalletDetailsModel({
    required this.walletId,
    required this.restaurantId,
    required this.currentBalance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.pendingAmount,
    required this.lastSettlementAmount,
  });

  factory WalletDetailsModel.fromJson(Map<String, dynamic> json) {
    return WalletDetailsModel(
      walletId: json['walletId']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawals: (json['totalWithdrawals'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
      lastSettlementAmount:
          (json['lastSettlementAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory WalletDetailsModel.initial() => const WalletDetailsModel(
        walletId: '',
        restaurantId: '',
        currentBalance: 0.0,
        totalEarnings: 0.0,
        totalWithdrawals: 0.0,
        pendingAmount: 0.0,
        lastSettlementAmount: 0.0,
      );
}

class WalletTransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final bool isCredit;
  final String date;
  final String status;
  final String type;

  const WalletTransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.date,
    required this.status,
    required this.type,
  });

  factory WalletTransactionItem.fromJson(Map<String, dynamic> json) {
    final amt = (json['amount'] as num?)?.toDouble() ?? 0.0;
    final txType = (json['type'] ?? json['transactionType'] ?? 'payout')
        .toString()
        .toLowerCase();
    final isCredVal = json['isCredit'];
    final bool isCredit = isCredVal is bool
        ? isCredVal
        : (txType == 'credit' ||
            txType == 'payout' ||
            txType == 'order' ||
            txType == 'earnings');

    return WalletTransactionItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title']?.toString() ??
          (isCredit ? 'Order Payout' : 'Bank Transfer Withdrawal'),
      subtitle: json['description']?.toString() ??
          json['subtitle']?.toString() ??
          (isCredit ? 'Credited to balance' : 'Processed'),
      amount: amt,
      isCredit: isCredit,
      date: json['createdAt']?.toString() ??
          json['date']?.toString() ??
          'Recent',
      status: json['status']?.toString() ?? 'Settled',
      type: txType,
    );
  }
}
