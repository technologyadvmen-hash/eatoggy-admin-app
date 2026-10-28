import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderModel {
  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.time,
    this.address = 'Sector 62, Noida, Uttar Pradesh',
    this.prepTime = '20 mins',
    this.instructions = 'Please make less spicy and send extra green chutney.',
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final List<String> items;
  final String totalAmount;
  final String status;
  final String time;
  final String address;
  final String prepTime;
  final String instructions;

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<String>? items,
    String? totalAmount,
    String? status,
    String? time,
    String? address,
    String? prepTime,
    String? instructions,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      time: time ?? this.time,
      address: address ?? this.address,
      prepTime: prepTime ?? this.prepTime,
      instructions: instructions ?? this.instructions,
    );
  }
}

class OrdersNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    return const [];
  }

  void acceptOrder(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: 'Preparing', time: 'Just accepted')
        else
          order,
    ];
  }

  void rejectOrder(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: 'Cancelled', time: 'Just rejected')
        else
          order,
    ];
  }

  void markOrderReady(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: 'Ready', time: 'Ready for pickup')
        else
          order,
    ];
  }

  void completeOrder(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: 'Completed', time: 'Just completed')
        else
          order,
    ];
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);

final newOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders
      .where((o) =>
          o.status.toLowerCase() == 'new' || o.status.toLowerCase() == 'pending')
      .toList();
});

final preparingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders
      .where((o) =>
          o.status.toLowerCase() == 'preparing' ||
          o.status.toLowerCase() == 'ready' ||
          o.status.toLowerCase() == 'active')
      .toList();
});

final pastOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders
      .where((o) =>
          o.status.toLowerCase() == 'completed' ||
          o.status.toLowerCase() == 'delivered' ||
          o.status.toLowerCase() == 'cancelled')
      .toList();
});

final activeOrdersCountProvider = Provider<int>((ref) {
  final newCount = ref.watch(newOrdersProvider).length;
  final prepCount = ref.watch(preparingOrdersProvider).length;
  return newCount + prepCount;
});
