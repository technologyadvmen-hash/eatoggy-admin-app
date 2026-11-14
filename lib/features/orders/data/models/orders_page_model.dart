class OrderItemDetail {
  const OrderItemDetail({
    required this.id,
    required this.orderNumber,
    required this.timeAgo,
    required this.amount,
    required this.customerName,
    required this.itemsList,
    required this.status,
    this.customerMobile = '',
    this.customerAddress = '',
    this.specialInstructions = '',
  });

  final String id;
  final String orderNumber;
  final String timeAgo;
  final String amount;
  final String customerName;
  final List<String> itemsList;
  final String status;
  final String customerMobile;
  final String customerAddress;
  final String specialInstructions;

  OrderItemDetail copyWith({
    String? id,
    String? orderNumber,
    String? timeAgo,
    String? amount,
    String? customerName,
    List<String>? itemsList,
    String? status,
    String? customerMobile,
    String? customerAddress,
    String? specialInstructions,
  }) {
    return OrderItemDetail(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      timeAgo: timeAgo ?? this.timeAgo,
      amount: amount ?? this.amount,
      customerName: customerName ?? this.customerName,
      itemsList: itemsList ?? this.itemsList,
      status: status ?? this.status,
      customerMobile: customerMobile ?? this.customerMobile,
      customerAddress: customerAddress ?? this.customerAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}


class OrdersFilterTab {
  const OrdersFilterTab({
    required this.id,
    required this.label,
    this.badgeCount = 0,
  });

  final String id;
  final String label;
  final int badgeCount;
}

class OrdersPageModel {
  const OrdersPageModel({
    required this.title,
    required this.filterTabs,
    required this.orders,
  });

  final String title;
  final List<OrdersFilterTab> filterTabs;
  final List<OrderItemDetail> orders;

  static const dummy = OrdersPageModel(
    title: 'Orders',
    filterTabs: [
      OrdersFilterTab(id: 'all', label: 'All', badgeCount: 0),
      OrdersFilterTab(id: 'new', label: 'New', badgeCount: 0),
      OrdersFilterTab(id: 'preparing', label: 'Preparing', badgeCount: 0),
      OrdersFilterTab(id: 'ready', label: 'Ready', badgeCount: 0),
      OrdersFilterTab(id: 'completed', label: 'Completed', badgeCount: 0),
    ],
    orders: [],
  );
}
