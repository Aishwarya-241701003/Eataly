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
}
