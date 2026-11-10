enum TransactionCategory {
  all,
  settlement,
  foodOrder,
  subscription,
  deduction,
}

class TransactionItemModel {
  final String id;
  final String title;
  final String tag;
  final String subtitle;
  final String timestamp;
  final String amount;
  final bool isCredit;
  final TransactionCategory category;
  final DateTime date;

  const TransactionItemModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.timestamp,
    required this.amount,
    required this.isCredit,
    required this.category,
    required this.date,
  });
}

class TransactionsModel {
  final String withdrawableBalance;
  final String dateRangeLabel;
  final List<TransactionItemModel> allTransactions;

  const TransactionsModel({
    required this.withdrawableBalance,
    required this.dateRangeLabel,
    required this.allTransactions,
  });

  static TransactionsModel get dummy => const TransactionsModel(
        withdrawableBalance: '₹0',
        dateRangeLabel: 'Recent',
        allTransactions: [],
      );
}
