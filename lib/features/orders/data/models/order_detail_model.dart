class OrderItem {
  const OrderItem({
    required this.qty,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String qty;
  final String title;
  final String subtitle;
  final String price;
}

class OrderDetailModel {
  const OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.items,
    required this.itemTotal,
    required this.gst,
    required this.packagingCharges,
    required this.deliveryFee,
    required this.grandTotal,
    this.prepTimeOptions = const [15, 25, 35, 45],
    this.defaultPrepTime = 25,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final List<OrderItem> items;
  final String itemTotal;
  final String gst;
  final String packagingCharges;
  final String deliveryFee;
  final String grandTotal;
  final List<int> prepTimeOptions;
  final int defaultPrepTime;

  static const dummy = OrderDetailModel(
    id: '',
    orderNumber: 'ORD',
    status: 'New Order',
    customerName: 'Customer',
    customerAddress: 'Customer Address',
    customerPhone: '',
    items: [],
    itemTotal: '₹0',
    gst: '₹0',
    packagingCharges: '₹0',
    deliveryFee: '₹0',
    grandTotal: '₹0',
  );
}
