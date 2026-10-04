import 'package:flutter/material.dart';

/// Represents a centralized Campus Food Distribution Station where items
/// ordered across different canteens are gathered and consolidated.
class DistributionStation {
  final String id;
  final String name;
  final String code;
  final String location;
  final String landmark;
  final int totalBays;
  final int occupiedBays;
  final String queueStatus; // Low, Moderate, Heavy
  final int activeRunners;
  final Color themeColor;

  const DistributionStation({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.landmark,
    required this.totalBays,
    required this.occupiedBays,
    required this.queueStatus,
    required this.activeRunners,
    this.themeColor = const Color(0xFF1E3A8A),
  });

  int get availableBays => (totalBays - occupiedBays).clamp(0, totalBays);
  double get occupancyRate => totalBays == 0 ? 0.0 : occupiedBays / totalBays;
}

/// An individual food item in a multi-canteen order tracking its runner journey
class ConsolidatedItem {
  final String foodName;
  final String canteenName;
  final int quantity;
  String status; // 'Preparing in Kitchen', 'In Transit via Runner', 'Arrived at Counter Bay'
  final String? runnerName;

  ConsolidatedItem({
    required this.foodName,
    required this.canteenName,
    required this.quantity,
    this.status = 'Preparing in Kitchen',
    this.runnerName,
  });

  bool get isAtCounter => status == 'Arrived at Counter Bay';
  bool get isInTransit => status == 'In Transit via Runner';
  bool get isKitchen => status == 'Preparing in Kitchen';
}

/// Multi-canteen consolidated order stationed at a campus distribution hub
class ConsolidatedOrder {
  final String orderId;
  final String tokenNumber;
  final String studentName;
  final String studentRoll;
  final String studentPhone;
  final String stationId;
  final String stationName;
  final String bayNumber;
  final String pickupSlot;
  final DateTime orderTime;
  final List<ConsolidatedItem> items;
  bool isHandedOver;

  ConsolidatedOrder({
    required this.orderId,
    required this.tokenNumber,
    required this.studentName,
    required this.studentRoll,
    required this.studentPhone,
    required this.stationId,
    required this.stationName,
    required this.bayNumber,
    required this.pickupSlot,
    required this.orderTime,
    required this.items,
    this.isHandedOver = false,
  });

  bool get isAllItemsAtCounter => items.every((i) => i.isAtCounter);

  int get arrivedItemCount => items.where((i) => i.isAtCounter).length;

  int get totalItemCount => items.length;

  double get consolidationProgress =>
      totalItemCount == 0 ? 0.0 : arrivedItemCount / totalItemCount;

  String get consolidationStatus {
    if (isHandedOver) return 'Handed Over to Student';
    if (isAllItemsAtCounter) return 'Ready for Pickup at $bayNumber';
    return 'Consolidating ($arrivedItemCount/$totalItemCount Arrived)';
  }

  Set<String> get uniqueCanteens => items.map((i) => i.canteenName).toSet();
}
