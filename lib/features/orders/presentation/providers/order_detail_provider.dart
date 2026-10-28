import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_detail_model.dart';
import '../../data/models/orders_page_model.dart';
import 'orders_page_provider.dart';

class OrderDetailState {
  const OrderDetailState({
    required this.orderDetail,
    this.selectedPrepTime = 25,
  });

  final OrderDetailModel orderDetail;
  final int selectedPrepTime;

  OrderDetailState copyWith({
    OrderDetailModel? orderDetail,
    int? selectedPrepTime,
  }) {
    return OrderDetailState(
      orderDetail: orderDetail ?? this.orderDetail,
      selectedPrepTime: selectedPrepTime ?? this.selectedPrepTime,
    );
  }
}

class OrderPrepTimeNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setPrepTime(String orderId, int minutes) {
    state = {...state, orderId: minutes};
  }
}

final orderPrepTimeProvider = NotifierProvider<OrderPrepTimeNotifier, Map<String, int>>(
  OrderPrepTimeNotifier.new,
);

final orderDetailProvider = Provider.family<OrderDetailState, String>((ref, orderId) {
  final parentOrders = ref.watch(ordersPageProvider).ordersList;
  final prepTimes = ref.watch(orderPrepTimeProvider);
  final selectedPrepTime = prepTimes[orderId] ?? 25;

  final OrderItemDetail matchingOrder = parentOrders.firstWhere(
    (o) => o.id == orderId || o.orderNumber == orderId,
    orElse: () => OrderItemDetail(
      id: orderId,
      orderNumber: orderId.isNotEmpty ? orderId : 'ORD',
      timeAgo: 'Just now',
      amount: '₹0',
      customerName: 'Customer',
      itemsList: const [],
      status: 'New',
    ),
  );

  final detailItems = matchingOrder.itemsList.map((itemStr) {
    final parts = itemStr.split('x ');
    final qty = parts.length > 1 ? '${parts[0]}x' : '1x';
    final title = parts.length > 1 ? parts.sublist(1).join('x ') : itemStr;
    return OrderItem(qty: qty, title: title, subtitle: '', price: '');
  }).toList();

  final detail = OrderDetailModel(
    id: matchingOrder.id,
    orderNumber: matchingOrder.orderNumber,
    status: matchingOrder.status == 'New' ? 'New Order' : matchingOrder.status,
    customerName: matchingOrder.customerName.isNotEmpty ? matchingOrder.customerName : 'Customer',
    customerAddress: matchingOrder.customerAddress.isNotEmpty
        ? matchingOrder.customerAddress
        : 'Customer Delivery Address',
    customerPhone: matchingOrder.customerMobile,
    items: detailItems.isNotEmpty
        ? detailItems
        : [const OrderItem(qty: '1x', title: 'Meal Order', subtitle: '', price: '')],
    itemTotal: matchingOrder.amount,
    gst: '₹0',
    packagingCharges: '₹0',
    deliveryFee: '₹0',
    grandTotal: matchingOrder.amount,
  );

  return OrderDetailState(
    orderDetail: detail,
    selectedPrepTime: selectedPrepTime,
  );
});
