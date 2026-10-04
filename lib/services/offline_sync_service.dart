import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/food.dart';
import '../models/order.dart';

enum SyncState {
  synced,
  syncing,
  offline,
}

class LoadBalanceRecommendation {
  final String foodName;
  final String currentCanteen;
  final int currentWaitMins;
  final String recommendedCanteen;
  final int recommendedWaitMins;
  final int timeSavedMins;

  LoadBalanceRecommendation({
    required this.foodName,
    required this.currentCanteen,
    required this.currentWaitMins,
    required this.recommendedCanteen,
    required this.recommendedWaitMins,
    required this.timeSavedMins,
  });
}

class OfflineSyncService extends ChangeNotifier {
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;

  OfflineSyncService._internal() {
    _startSimulatedPeriodicSync();
  }

  bool _isOnline = true;
  SyncState _syncState = SyncState.synced;
  final List<Order> _pendingOfflineOrders = [];

  bool get isOnline => _isOnline;
  SyncState get syncState => _syncState;
  int get pendingSyncCount => _pendingOfflineOrders.length;

  void toggleOnlineStatus(bool online) {
    _isOnline = online;
    if (!_isOnline) {
      _syncState = SyncState.offline;
    } else {
      triggerBackgroundSync();
    }
    notifyListeners();
  }

  void queueOfflineOrder(Order order) {
    order.isSynced = false;
    _pendingOfflineOrders.add(order);
    _syncState = SyncState.offline;
    notifyListeners();

    if (_isOnline) {
      triggerBackgroundSync();
    }
  }

  Future<void> triggerBackgroundSync() async {
    if (_pendingOfflineOrders.isEmpty) {
      _syncState = SyncState.synced;
      notifyListeners();
      return;
    }

    _syncState = SyncState.syncing;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1400));

    for (final order in _pendingOfflineOrders) {
      order.isSynced = true;
    }
    _pendingOfflineOrders.clear();
    _syncState = SyncState.synced;
    notifyListeners();
  }

  void _startSimulatedPeriodicSync() {
    Timer.periodic(const Duration(seconds: 45), (_) {
      if (_isOnline && _pendingOfflineOrders.isNotEmpty) {
        triggerBackgroundSync();
      }
    });
  }

  // ------------------------------------------------------------
  // SMART KITCHEN LOAD BALANCER ALGORITHM
  // ------------------------------------------------------------
  LoadBalanceRecommendation? findLoadBalancerAlternative({
    required String foodName,
    required String currentCanteen,
    required List<Food> allFoods,
    required List<Map<String, dynamic>> allCanteens,
  }) {
    final lowerName = foodName.toLowerCase();
    String normalizedKeyword = lowerName;
    if (lowerName.contains('burger')) normalizedKeyword = 'burger';
    if (lowerName.contains('noodle')) normalizedKeyword = 'noodle';
    if (lowerName.contains('briyani') || lowerName.contains('biryani')) normalizedKeyword = 'briyani';
    if (lowerName.contains('coffee') || lowerName.contains('tea')) normalizedKeyword = 'coffee';
    if (lowerName.contains('maggi')) normalizedKeyword = 'maggi';
    if (lowerName.contains('dosa')) normalizedKeyword = 'dosa';

    int currentWait = 14;
    for (final c in allCanteens) {
      if (c['name'].toString().toLowerCase() == currentCanteen.toLowerCase()) {
        final waitStr = c['queueWait']?.toString() ?? '14';
        final parsed = int.tryParse(RegExp(r'\d+').firstMatch(waitStr)?.group(0) ?? '14') ?? 14;
        currentWait = parsed;
        break;
      }
    }

    for (final c in allCanteens) {
      final canteenName = c['name'].toString();
      if (canteenName.toLowerCase() == currentCanteen.toLowerCase()) continue;

      final waitStr = c['queueWait']?.toString() ?? '8';
      final otherWait = int.tryParse(RegExp(r'\d+').firstMatch(waitStr)?.group(0) ?? '8') ?? 8;

      if (otherWait < currentWait) {
        final hasSimilarFood = allFoods.any((f) {
          final fCanteen = (f.canteen ?? '').toLowerCase();
          return fCanteen.contains(canteenName.toLowerCase()) &&
              f.name.toLowerCase().contains(normalizedKeyword);
        });

        if (hasSimilarFood) {
          return LoadBalanceRecommendation(
            foodName: foodName,
            currentCanteen: currentCanteen,
            currentWaitMins: currentWait,
            recommendedCanteen: canteenName,
            recommendedWaitMins: otherWait,
            timeSavedMins: currentWait - otherWait,
          );
        }
      }
    }

    return null;
  }

  // ------------------------------------------------------------
  // DYNAMIC SLOT & CONFLICT RESOLUTION
  // ------------------------------------------------------------
  final Map<String, int> _slotOccupancy = {
    '12:00 PM': 11,
    '12:15 PM': 14,
    '12:30 PM': 20, // FULL (Conflict slot)
    '12:45 PM': 9,
    '1:00 PM': 15,
    '1:15 PM': 8,
    '1:30 PM': 6,
    '1:45 PM': 4,
  };

  bool isSlotFull(String slot) {
    return (_slotOccupancy[slot] ?? 0) >= 20;
  }

  int getSlotOrders(String slot) {
    return _slotOccupancy[slot] ?? 5;
  }

  String suggestAlternateSlot(String fullSlot) {
    final slots = [
      '12:00 PM',
      '12:15 PM',
      '12:30 PM',
      '12:45 PM',
      '1:00 PM',
      '1:15 PM',
      '1:30 PM',
      '1:45 PM',
    ];
    final idx = slots.indexOf(fullSlot);
    if (idx >= 0 && idx + 1 < slots.length) {
      return slots[idx + 1];
    }
    return '12:45 PM';
  }

  // ------------------------------------------------------------
  // DEMAND & FOOD WASTE PREDICTION DATA
  // ------------------------------------------------------------
  Map<String, dynamic> getSmartPredictions() {
    return {
      'hourlyDemand': [
        {'time': '12:00 PM', 'expected': 34, 'confidence': '94%'},
        {'time': '12:30 PM', 'expected': 82, 'confidence': '96%'}, // Peak
        {'time': '1:00 PM', 'expected': 58, 'confidence': '91%'},
        {'time': '1:30 PM', 'expected': 27, 'confidence': '88%'},
      ],
      'foodWasteSuggestions': [
        {
          'dish': 'Crispy Veg Burgers',
          'suggested': 15,
          'excessAvoided': 15,
          'reason': 'Historical lunch sales show 15 remaining are enough. Do NOT prepare 30.',
        },
        {
          'dish': 'Paneer Biryani',
          'suggested': 20,
          'excessAvoided': 10,
          'reason': 'Demand plateauing after 1:15 PM.',
        },
      ],
      'lowStockAlerts': [
        {'item': 'Burger Buns / Bread', 'remaining': 18, 'expected': 45, 'urgency': 'High'},
        {'item': 'Fresh Paneer (Kg)', 'remaining': 3, 'expected': 10, 'urgency': 'Medium'},
        {'item': 'Cold Coffee Milk (Ltr)', 'remaining': 8, 'expected': 25, 'urgency': 'High'},
      ],
      'batchCookingGroups': [
        {'dish': 'Veg Burger', 'batchCount': 3, 'canteen': 'Rec Cafe', 'estTime': '6 mins'},
        {'dish': 'Masala Dosa', 'batchCount': 4, 'canteen': 'Rec Cafe', 'estTime': '7 mins'},
        {'dish': 'Paneer Noodles', 'batchCount': 2, 'canteen': 'Wok On', 'estTime': '5 mins'},
      ],
    };
  }
}
