import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/handover_order_model.dart';
import '../../data/models/orders_page_model.dart';

class HandoverOrderState {
  const HandoverOrderState({
    required this.order,
  });

  final HandoverOrderModel order;

  HandoverOrderState copyWith({
    HandoverOrderModel? order,
  }) {
    return HandoverOrderState(
      order: order ?? this.order,
    );
  }
}

class HandoverOrderNotifier extends Notifier<HandoverOrderState> {
  @override
  HandoverOrderState build() {
    return const HandoverOrderState(
      order: HandoverOrderModel.dummy,
    );
  }

  void initializeForOrder(OrderItemDetail? orderDetail, {String partnerName = 'Delivery Partner'}) {
    final orderNum = orderDetail?.orderNumber ?? '';
    final id = orderDetail?.id ?? '';
    state = HandoverOrderState(
      order: HandoverOrderModel(
        orderId: id,
        orderNumber: orderNum,
        statusSteps: const ['Accepted', 'Preparing', 'Ready', 'Picked Up'],
        currentStepIndex: 3,
        title: 'Handed Over Successfully',
        description: orderNum.isNotEmpty
            ? 'Order #$orderNum has been collected by $partnerName.'
            : 'Order has been collected by $partnerName.',
        partnerName: partnerName,
        partnerVehicleNo: 'Assigned Fleet',
        partnerPhone: '',
      ),
    );
  }
}

final handoverOrderProvider =
    NotifierProvider<HandoverOrderNotifier, HandoverOrderState>(
  HandoverOrderNotifier.new,
);
