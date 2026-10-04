import 'cart_item.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  completed,
  cancelled,
}

class Order {
  final String orderId;
  final List<CartItem> items;
  final String pickupSlot;
  final String tokenNumber;
  final DateTime orderTime;
  OrderStatus status;

  Order({
    required this.orderId,
    required this.items,
    required this.pickupSlot,
    required this.tokenNumber,
    required this.orderTime,
    this.status = OrderStatus.pending,
  });

  double get totalAmount {
    return items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toMap()).toList(),
      'pickupSlot': pickupSlot,
      'tokenNumber': tokenNumber,
      'orderTime': orderTime.toIso8601String(),
      'status': status.name,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => CartItem.fromMap(Map<String, dynamic>.from(i)))
          .toList(),
      pickupSlot: map['pickupSlot'] ?? '',
      tokenNumber: map['tokenNumber'] ?? '',
      orderTime: map['orderTime'] != null
          ? DateTime.tryParse(map['orderTime']) ?? DateTime.now()
          : DateTime.now(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
    );
  }
}
