class KitchenOrderItem {
  final String id;
  final String menuItemId;
  final String foodName;
  final String foodImage;
  final num unitPrice;
  final int quantity;
  final num itemTotal;
  final String foodType;

  const KitchenOrderItem({
    required this.id,
    required this.menuItemId,
    required this.foodName,
    required this.foodImage,
    required this.unitPrice,
    required this.quantity,
    required this.itemTotal,
    required this.foodType,
  });

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) {
    return KitchenOrderItem(
      id: json['_id']?.toString() ?? '',
      menuItemId: json['menuItemId']?.toString() ?? '',
      foodName: json['foodNameSnapshot']?.toString() ?? json['foodName']?.toString() ?? 'Food Item',
      foodImage: json['foodImageSnapshot']?.toString() ?? json['foodImage']?.toString() ?? '',
      unitPrice: json['unitPrice'] as num? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      itemTotal: json['itemTotal'] as num? ?? 0,
      foodType: json['foodType']?.toString() ?? 'VEG',
    );
  }
}

class KitchenOrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerMobile;
  final String customerEmail;
  final String address;
  final num grandTotal;
  final String orderStatus;
  final String priority;
  final String kitchenNotes;
  final String preparationNotes;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparingAt;
  final DateTime? readyAt;
  final List<KitchenOrderItem> items;

  const KitchenOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerMobile,
    required this.customerEmail,
    required this.address,
    required this.grandTotal,
    required this.orderStatus,
    required this.priority,
    required this.kitchenNotes,
    required this.preparationNotes,
    this.createdAt,
    this.acceptedAt,
    this.preparingAt,
    this.readyAt,
    required this.items,
  });

  factory KitchenOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'] as Map<String, dynamic>? ?? {};
    final addressMap = json['deliveryAddress'] as Map<String, dynamic>? ?? {};
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};

    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    final parsedItems = itemsRaw
        .map((e) => KitchenOrderItem.fromJson(e as Map<String, dynamic>))
        .toList();

    String formattedAddress = addressMap['addressLine1']?.toString() ?? '';
    if (addressMap['city'] != null && addressMap['city'].toString().isNotEmpty) {
      formattedAddress = formattedAddress.isNotEmpty
          ? '$formattedAddress, ${addressMap['city']}'
          : addressMap['city'].toString();
    }

    return KitchenOrderModel(
      id: json['_id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      customerName: addressMap['name']?.toString() ?? customer['name']?.toString() ?? 'Customer',
      customerMobile: addressMap['mobile']?.toString() ?? customer['mobile']?.toString() ?? '',
      customerEmail: customer['email']?.toString() ?? '',
      address: formattedAddress,
      grandTotal: pricing['grandTotal'] as num? ?? 0,
      orderStatus: json['orderStatus']?.toString().toUpperCase() ?? 'PLACED',
      priority: json['priority']?.toString() ?? 'NORMAL',
      kitchenNotes: json['kitchenNotes']?.toString() ?? '',
      preparationNotes: json['preparationNotes']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.tryParse(json['acceptedAt'].toString()) : null,
      preparingAt: json['preparingAt'] != null ? DateTime.tryParse(json['preparingAt'].toString()) : null,
      readyAt: json['readyAt'] != null ? DateTime.tryParse(json['readyAt'].toString()) : null,
      items: parsedItems,
    );
  }

  /// Helper to convert backend status string to UI friendly label
  String get uiStatus {
    switch (orderStatus) {
      case 'PLACED':
        return 'New';
      case 'ACCEPTED':
        return 'New';
      case 'PREPARING':
        return 'Preparing';
      case 'READY':
        return 'Ready';
      case 'DELIVERED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }

  /// Formatted relative time
  String get timeAgo {
    if (createdAt == null) return 'Just now';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// List of item description strings (e.g. "2x Butter Chicken")
  List<String> get itemsDescriptionList {
    return items.map((i) => '${i.quantity}x ${i.foodName}').toList();
  }
}
