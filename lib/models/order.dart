import 'cart_item.dart';

enum OrderStatus {
  pending, // Accepted
  preparing, // Cooking / Packaging
  ready, // Ready for pickup
  completed, // Collected
  cancelled,
}

enum TrackingStage {
  accepted,
  cooking,
  packaging,
  ready,
  collected,
}

class Order {
  final String orderId;
  final List<CartItem> items;
  String pickupSlot;
  final String tokenNumber;
  final DateTime orderTime;
  OrderStatus status;
  // Intelligent & Tracking fields
  int queueAhead;
  int estimatedReadyMins;
  bool isSynced;
  int trackingStep; // 0: Accepted, 1: Cooking, 2: Packaging, 3: Ready, 4: Collected
  String canteenName;
  String? notes;

  Order({
    required this.orderId,
    required this.items,
    required this.pickupSlot,
    required this.tokenNumber,
    required this.orderTime,
    this.status = OrderStatus.pending,
    this.queueAhead = 2,
    this.estimatedReadyMins = 4,
    this.isSynced = true,
    this.trackingStep = 1,
    this.canteenName = "Rec Cafe",
    this.notes,
  });

  double get totalAmount {
    return items.fold(
      0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  bool get canModify => trackingStep <= 1 && status != OrderStatus.cancelled && status != OrderStatus.completed;

  String get trackingStageLabel {
    switch (trackingStep) {
      case 0:
        return "Accepted";
      case 1:
        return "Cooking";
      case 2:
        return "Packaging";
      case 3:
        return "Ready";
      case 4:
        return "Collected";
      default:
        return "Preparing";
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toMap()).toList(),
      'pickupSlot': pickupSlot,
      'tokenNumber': tokenNumber,
      'orderTime': orderTime.toIso8601String(),
      'status': status.name,
      'queueAhead': queueAhead,
      'estimatedReadyMins': estimatedReadyMins,
      'isSynced': isSynced,
      'trackingStep': trackingStep,
      'canteenName': canteenName,
      if (notes != null) 'notes': notes,
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
      queueAhead: map['queueAhead'] ?? 2,
      estimatedReadyMins: map['estimatedReadyMins'] ?? 4,
      isSynced: map['isSynced'] ?? true,
      trackingStep: map['trackingStep'] ?? (map['status'] == 'completed' ? 4 : (map['status'] == 'ready' ? 3 : 1)),
      canteenName: map['canteenName'] ?? 'Rec Cafe',
      notes: map['notes'],
    );
  }
}
