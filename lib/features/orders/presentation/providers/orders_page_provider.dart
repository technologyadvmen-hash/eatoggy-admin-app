import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../kitchen/data/repositories/kitchen_repository.dart';
import '../../data/models/orders_page_model.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersPageState {
  const OrdersPageState({
    required this.data,
    this.activeFilter = 'new',
    this.ordersList = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final OrdersPageModel data;
  final String activeFilter;
  final List<OrderItemDetail> ordersList;
  final bool isLoading;
  final String? errorMessage;

  List<OrdersFilterTab> get filterTabsWithCounts {
    final newCount = ordersList.where((o) => o.status == 'New').length;
    final preparingCount = ordersList.where((o) => o.status == 'Preparing').length;
    final readyCount = ordersList.where((o) => o.status == 'Ready').length;
    final completedCount = ordersList.where((o) => o.status == 'Completed').length;
    final allCount = ordersList.length;

    return [
      OrdersFilterTab(id: 'all', label: 'All', badgeCount: allCount),
      OrdersFilterTab(id: 'new', label: 'New', badgeCount: newCount),
      OrdersFilterTab(id: 'preparing', label: 'Preparing', badgeCount: preparingCount),
      OrdersFilterTab(id: 'ready', label: 'Ready', badgeCount: readyCount),
      OrdersFilterTab(id: 'completed', label: 'Completed', badgeCount: completedCount),
    ];
  }

  List<OrderItemDetail> get filteredOrders {
    if (activeFilter == 'all') return ordersList;
    if (activeFilter == 'new') {
      return ordersList.where((o) => o.status == 'New').toList();
    }
    if (activeFilter == 'preparing') {
      return ordersList.where((o) => o.status == 'Preparing').toList();
    }
    if (activeFilter == 'ready') {
      return ordersList.where((o) => o.status == 'Ready').toList();
    }
    if (activeFilter == 'completed') {
      return ordersList.where((o) => o.status == 'Completed').toList();
    }
    return ordersList;
  }

  OrdersPageState copyWith({
    OrdersPageModel? data,
    String? activeFilter,
    List<OrderItemDetail>? ordersList,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OrdersPageState(
      data: data ?? this.data,
      activeFilter: activeFilter ?? this.activeFilter,
      ordersList: ordersList ?? this.ordersList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class OrdersPageNotifier extends Notifier<OrdersPageState> {
  final KitchenRepository _kitchenRepository = KitchenRepository();
  final OrdersRepository _ordersRepository = OrdersRepository();

  @override
  OrdersPageState build() {
    _fetchLiveKitchenOrders();
    return const OrdersPageState(
      data: OrdersPageModel.dummy,
      activeFilter: 'all',
      ordersList: [],
      isLoading: true,
    );
  }

  /// Fetch live orders from GET /api/restaurants/kitchen/orders
  Future<void> _fetchLiveKitchenOrders() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final liveOrders = await _kitchenRepository.getKitchenOrders();

      final mappedList = liveOrders.map((kOrder) {
        return OrderItemDetail(
          id: kOrder.id,
          orderNumber: kOrder.orderNumber.isNotEmpty
              ? kOrder.orderNumber
              : 'ORD-${kOrder.id.substring(kOrder.id.length >= 6 ? kOrder.id.length - 6 : 0).toUpperCase()}',
          timeAgo: kOrder.timeAgo,
          amount: '₹${kOrder.grandTotal.toInt()}',
          customerName: kOrder.customerName,
          itemsList: kOrder.itemsDescriptionList.isNotEmpty
              ? kOrder.itemsDescriptionList
              : ['Custom Order Meal'],
          status: kOrder.uiStatus,
          customerMobile: kOrder.customerMobile,
          customerAddress: kOrder.address,
          specialInstructions: kOrder.kitchenNotes.isNotEmpty
              ? kOrder.kitchenNotes
              : kOrder.preparationNotes,
        );
      }).toList();

      state = state.copyWith(
        ordersList: mappedList,
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on live kitchen orders fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Public reload method for pull-to-refresh
  Future<void> refreshOrders() async {
    await _fetchLiveKitchenOrders();
  }

  void selectFilter(String filterId) {
    state = state.copyWith(activeFilter: filterId);
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final updatedList = state.ordersList.map((order) {
      if (order.id == orderId) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();

    state = state.copyWith(ordersList: updatedList);
  }

  /// Accept incoming order: calls POST /api/restaurants/orders/:id/accept
  Future<bool> acceptOrder(String orderId, {int estimatedPrepTime = 20}) async {
    updateOrderStatus(orderId, 'Preparing');
    try {
      await _ordersRepository.acceptOrder(
        orderId: orderId,
        estimatedPrepTime: estimatedPrepTime,
      );
      return true;
    } catch (e) {
      appLog("Notice on acceptOrder endpoint: $e");
      // Secondary fallback to status progression
      try {
        await _kitchenRepository.updateKitchenOrderStatus(
          orderId: orderId,
          status: 'ACCEPTED',
          note: 'Order accepted by kitchen',
        );
      } catch (_) {}
      return false;
    }
  }

  /// Start preparing: sends PATCH status: PREPARING to backend
  Future<void> markPreparing(String orderId) async {
    updateOrderStatus(orderId, 'Preparing');
    try {
      await _kitchenRepository.updateKitchenOrderStatus(
        orderId: orderId,
        status: 'PREPARING',
        note: 'Kitchen started cooking',
      );
    } catch (e) {
      appLog("Error syncing PREPARING status: $e");
    }
  }

  /// Mark order ready for pickup: sends PATCH status: READY to backend
  Future<void> markReady(String orderId) async {
    updateOrderStatus(orderId, 'Ready');
    try {
      await _kitchenRepository.updateKitchenOrderStatus(
        orderId: orderId,
        status: 'READY',
        note: 'Food cooked and packed',
      );
    } catch (e) {
      appLog("Error syncing READY status: $e");
    }
  }

  void markCompleted(String orderId) {
    updateOrderStatus(orderId, 'Completed');
  }

  /// Reject incoming order: calls POST /api/restaurants/orders/:id/reject and removes from list
  Future<bool> rejectOrder(
    String orderId, {
    String reasonCode = 'OUT_OF_STOCK',
    String reasonNote = 'Item not available',
  }) async {
    final updatedList = state.ordersList.where((o) => o.id != orderId).toList();
    state = state.copyWith(ordersList: updatedList);
    try {
      await _ordersRepository.rejectOrder(
        orderId: orderId,
        reasonCode: reasonCode,
        reasonNote: reasonNote,
      );
      return true;
    } catch (e) {
      appLog("Notice on rejectOrder endpoint: $e");
      return false;
    }
  }
}

final ordersPageProvider =
    NotifierProvider<OrdersPageNotifier, OrdersPageState>(
  OrdersPageNotifier.new,
);

