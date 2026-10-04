import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/distribution_station.dart';
import '../models/expected_demand.dart';
import 'offline_sync_service.dart';

class FirestoreService extends ChangeNotifier {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      return null;
    }
  }

  FirestoreService._internal() {
    _initData();
    _initFirestoreListeners();
  }

  final List<Food> _foods = [];
  final List<Map<String, dynamic>> _canteens = [];
  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  final Set<String> _favourites = {'1', '2'};

  // High Demand Alert state
  bool _isHighDemandActive = false;
  String _highDemandAlert =
      'High rush hour detected across campus canteens. Kitchen prep times are currently ~20-25 mins. Pickup at common Distribution Stations recommended.';

  // Distribution Stations & Consolidated Multi-Canteen Orders
  final List<DistributionStation> _distributionStations = [];
  final List<ConsolidatedOrder> _consolidatedOrders = [];

  // Demand Forecast Slots for Kitchen Admins
  final List<DemandSlot> _demandSlots = [];

  bool get isHighDemandActive => _isHighDemandActive;
  String get highDemandAlert => _highDemandAlert;

  List<DistributionStation> get distributionStations =>
      List.unmodifiable(_distributionStations);
  List<ConsolidatedOrder> get consolidatedOrders =>
      List.unmodifiable(_consolidatedOrders);
  List<DemandSlot> get demandSlots => List.unmodifiable(_demandSlots);

  void toggleHighDemand(bool active, {String? customMessage}) {
    _isHighDemandActive = active;
    if (customMessage != null && customMessage.trim().isNotEmpty) {
      _highDemandAlert = customMessage.trim();
    }
    notifyListeners();
  }

  void updateConsolidatedItemStatus(
      String orderId, String foodName, String newStatus) {
    final orderIndex =
        _consolidatedOrders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex >= 0) {
      final itemIndex = _consolidatedOrders[orderIndex]
          .items
          .indexWhere((i) => i.foodName == foodName);
      if (itemIndex >= 0) {
        _consolidatedOrders[orderIndex].items[itemIndex].status = newStatus;
        notifyListeners();
      }
    }
  }

  void markConsolidatedOrderHandedOver(String orderId) {
    final orderIndex =
        _consolidatedOrders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex >= 0) {
      _consolidatedOrders[orderIndex].isHandedOver = true;
      notifyListeners();
    }
  }

  void updateDishPrepQuantity(String slotId, String dishName, int delta) {
    final slotIndex = _demandSlots.indexWhere((s) => s.id == slotId);
    if (slotIndex >= 0) {
      final dishIndex = _demandSlots[slotIndex]
          .dishes
          .indexWhere((d) => d.dishName == dishName);
      if (dishIndex >= 0) {
        final current = _demandSlots[slotIndex].dishes[dishIndex].preppedQuantity;
        final max = _demandSlots[slotIndex].dishes[dishIndex].forecastedQuantity;
        final updated = (current + delta).clamp(0, max + 20);
        _demandSlots[slotIndex].dishes[dishIndex].preppedQuantity = updated;
        notifyListeners();
      }
    }
  }

  void triggerRushAlertForSlot(String slotId, bool triggered) {
    final slotIndex = _demandSlots.indexWhere((s) => s.id == slotId);
    if (slotIndex >= 0) {
      _demandSlots[slotIndex].isRushAlertTriggered = triggered;
      if (triggered) {
        _isHighDemandActive = true;
        _highDemandAlert =
            'Surge Alert: ${_demandSlots[slotIndex].title} rush in effect. Orders are experiencing high kitchen queue volume.';
      }
      notifyListeners();
    }
  }

  List<Food> get foods => List.unmodifiable(_foods);
  List<Map<String, dynamic>> get canteens => List.unmodifiable(_canteens);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  Set<String> get favourites => Set.unmodifiable(_favourites);

  int get cartCount => _cart.fold(0, (total, item) => total + item.quantity);

  double get cartTotal => _cart.fold(0.0, (total, item) => total + item.totalPrice);

  bool isFavourite(String foodId) => _favourites.contains(foodId);

  void toggleFavourite(String foodId) {
    if (_favourites.contains(foodId)) {
      _favourites.remove(foodId);
    } else {
      _favourites.add(foodId);
    }
    notifyListeners();
  }

  void addToCart(Food food, {int quantity = 1}) {
    final index = _cart.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(CartItem(food: food, quantity: quantity));
    }
    notifyListeners();
  }

  int getFoodQuantity(String foodId) {
    final index = _cart.indexWhere((item) => item.food.id == foodId);
    return index >= 0 ? _cart[index].quantity : 0;
  }

  void removeFromCart(String foodId) {
    _cart.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void updateQuantity(String foodId, int delta) {
    final index = _cart.indexWhere((item) => item.food.id == foodId);
    if (index >= 0) {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  List<Food> get trendingFoods {
    return _foods.where((f) => f.isTrending || f.isPopular).take(6).toList();
  }

  List<Food> get personalizedRecommendations {
    // Smart suggestions: You usually order Cold Coffee / Dosa
    return _foods.where((f) =>
      f.name.toLowerCase().contains('coffee') ||
      f.name.toLowerCase().contains('burger') ||
      f.name.toLowerCase().contains('dosa') ||
      f.name.toLowerCase().contains('wrap')
    ).take(4).toList();
  }

  Map<String, dynamic> getCanteenLiveStatus(String canteenName) {
    final lower = canteenName.toLowerCase();
    int queue = 8;
    int wait = 6;
    String crowd = 'Low';
    String icon = '🟢';
    String confidence = '92%';

    if (lower.contains('hotspot') || lower.contains('court')) {
      queue = 18;
      wait = 20;
      crowd = 'Heavy';
      icon = '🔴';
      confidence = '95%';
    } else if (lower.contains('hut') || lower.contains('wokon')) {
      queue = 12;
      wait = 11;
      crowd = 'Medium';
      icon = '🟡';
      confidence = '90%';
    } else {
      queue = 6;
      wait = 5;
      crowd = 'Low';
      icon = '🟢';
      confidence = '92%';
    }

    return {
      'queueOrders': queue,
      'waitMins': wait,
      'crowd': crowd,
      'crowdIcon': icon,
      'confidence': confidence,
    };
  }

  Order placeOrder({
    required String pickupSlot,
    String? canteenName,
    String paymentMethod = "Campus Card",
    String? notes,
  }) {
    final token = "Token #${41 + _orders.length}";
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final isOnline = OfflineSyncService().isOnline;

    final newOrder = Order(
      orderId: orderId,
      items: List.from(_cart),
      pickupSlot: pickupSlot,
      tokenNumber: token,
      orderTime: DateTime.now(),
      status: OrderStatus.pending,
      queueAhead: (_orders.where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.pending).length).clamp(1, 10),
      estimatedReadyMins: 4,
      isSynced: isOnline,
      trackingStep: 0, // Accepted
      canteenName: canteenName ?? (_cart.isNotEmpty ? (_cart.first.food.canteen ?? 'Rec Cafe') : 'Rec Cafe'),
      notes: notes,
    );

    _orders.insert(0, newOrder);
    clearCart();
    notifyListeners();

    if (!isOnline) {
      OfflineSyncService().queueOfflineOrder(newOrder);
    } else {
      _saveOrderToFirestore(newOrder, canteenName: canteenName, paymentMethod: paymentMethod, notes: notes);
    }

    return newOrder;
  }

  void modifyOrderSlot(String orderId, String newSlot) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0 && _orders[index].canModify) {
      _orders[index].pickupSlot = newSlot;
      notifyListeners();
      try {
        _db?.collection('orders').doc(orderId).update({'pickupSlot': newSlot});
      } catch (e) {
        debugPrint('Firestore update slot error: $e');
      }
    }
  }

  void modifyOrderNotes(String orderId, String newNotes) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0 && _orders[index].canModify) {
      _orders[index].notes = newNotes;
      notifyListeners();
      try {
        _db?.collection('orders').doc(orderId).update({'notes': newNotes});
      } catch (e) {
        debugPrint('Firestore update notes error: $e');
      }
    }
  }

  void advanceOrderTracking(String orderId) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      final current = _orders[index].trackingStep;
      if (current < 4) {
        _orders[index].trackingStep = current + 1;
        if (_orders[index].trackingStep == 1) {
          _orders[index].status = OrderStatus.preparing;
          _orders[index].queueAhead = 1;
          _orders[index].estimatedReadyMins = 3;
        } else if (_orders[index].trackingStep == 2) {
          _orders[index].status = OrderStatus.preparing;
          _orders[index].queueAhead = 0;
          _orders[index].estimatedReadyMins = 1;
        } else if (_orders[index].trackingStep == 3) {
          _orders[index].status = OrderStatus.ready;
          _orders[index].estimatedReadyMins = 0;
        } else if (_orders[index].trackingStep == 4) {
          _orders[index].status = OrderStatus.completed;
        }
        notifyListeners();
        updateOrderStatus(orderId, _orders[index].status);
      }
    }
  }

  Future<void> _saveOrderToFirestore(
    Order order, {
    String? canteenName,
    String paymentMethod = "Campus Card",
    String? notes,
  }) async {
    try {
      final db = _db;
      if (db == null) return;
      final data = order.toMap();
      if (canteenName != null) data['canteenName'] = canteenName;
      data['paymentMethod'] = paymentMethod;
      if (notes != null) data['notes'] = notes;
      await db.collection('orders').doc(order.orderId).set(data);
    } catch (e) {
      debugPrint('Firestore save order error: $e');
    }
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
      _cancelOrderInFirestore(orderId);
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      _orders[index].status = status;
      notifyListeners();
      try {
        _db?.collection('orders').doc(orderId).update({'status': status.name});
      } catch (e) {
        debugPrint('Firestore update order status error: $e');
      }
    }
  }

  Future<void> _cancelOrderInFirestore(String orderId) async {
    try {
      final db = _db;
      if (db == null) return;
      await db.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
      });
    } catch (e) {
      debugPrint('Firestore cancel order error: $e');
    }
  }

  void reorder(Order order) {
    for (final item in order.items) {
      addToCart(item.food, quantity: item.quantity);
    }
  }

  List<Food> getFoodsByCanteen(String canteenName) {
    return _foods.where((f) => f.description.contains(canteenName) || f.category.isNotEmpty).toList();
  }

  // Real-Time Firestore Sync
  void _initFirestoreListeners() {
    try {
      final db = _db;
      if (db == null) return;

      // Sync canteens from Firestore
      db.collection('canteens').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _canteens.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              data['id'] = doc.id;
              _canteens.add(data);
            }
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Firestore canteens listener error: $e');
        },
      );

      // Sync foods from Firestore
      db.collection('foods').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _foods.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              data['id'] = doc.id;
              _foods.add(Food.fromMap(data));
            }
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Firestore foods listener error: $e');
        },
      );

      // Sync orders from Firestore
      db.collection('orders').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            _orders.clear();
            for (final doc in snapshot.docs) {
              final data = doc.data();
              data['orderId'] = doc.id;
              _orders.add(Order.fromMap(data));
            }
            _orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('Firestore orders listener error: $e');
        },
      );
    } catch (e) {
      debugPrint('Firestore listener setup error: $e');
    }
  }

  /// Seeds default canteens and foods into Cloud Firestore
  Future<void> seedInitialData({bool force = false}) async {
    try {
      final db = _db;
      if (db == null) {
        debugPrint('Firestore not available for seeding');
        return;
      }

      final canteensSnap = await db.collection('canteens').limit(1).get();
      if (canteensSnap.docs.isEmpty || force) {
        final batch = db.batch();
        for (final canteen in _canteens) {
          final id = canteen['id'] as String;
          final docRef = db.collection('canteens').doc(id);
          batch.set(docRef, canteen);
        }
        await batch.commit();
        debugPrint('Seeded ${_canteens.length} canteens to Firestore');
      }

      final foodsSnap = await db.collection('foods').limit(1).get();
      if (foodsSnap.docs.isEmpty || force) {
        final batch = db.batch();
        for (final food in _foods) {
          final docRef = db.collection('foods').doc(food.id);
          batch.set(docRef, food.toMap());
        }
        await batch.commit();
        debugPrint('Seeded ${_foods.length} foods to Firestore');
      }
    } catch (e) {
      debugPrint('Error seeding Firestore data: $e');
    }
  }

  void _initData() {
    _canteens.addAll([
      {
        'id': 'c1',
        'name': 'Rec Cafe',
        'location': 'Admin Block Ground Floor',
        'queueStatus': 'Low',
        'queueWait': '5 mins wait',
        'rating': '4.8',
        'image': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
      },
      {
        'id': 'c2',
        'name': 'Hut Cafe',
        'location': 'Near Mech & Civil Block',
        'queueStatus': 'Medium',
        'queueWait': '12 mins wait',
        'rating': '4.6',
        'image': 'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=800',
      },
      {
        'id': 'c3',
        'name': 'Yippe',
        'location': 'Food Court - Stall 3',
        'queueStatus': 'Low',
        'queueWait': '7 mins wait',
        'rating': '4.7',
        'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
      },
      {
        'id': 'c4',
        'name': 'Hotspot',
        'location': 'Central Library Annex',
        'queueStatus': 'High',
        'queueWait': '20 mins wait',
        'rating': '4.7',
        'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
      },
      {
        'id': 'c5',
        'name': 'Wokon',
        'location': 'Main Canteen Court',
        'queueStatus': 'Medium',
        'queueWait': '10 mins wait',
        'rating': '4.5',
        'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
      },
      {
        'id': 'c6',
        'name': 'Cafe Coffee Day',
        'location': 'Student Activity Center',
        'queueStatus': 'Low',
        'queueWait': '4 mins wait',
        'rating': '4.9',
        'image': 'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=800',
      },
      {
        'id': 'c7',
        'name': '6Sense',
        'location': 'Indoor Sports Complex',
        'queueStatus': 'Low',
        'queueWait': '6 mins wait',
        'rating': '4.6',
        'image': 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
      },
    ]);

    _foods.addAll([
      // Rec Cafe (dosa, sambar rice, veg briyani, smoodh, cavins)
      Food(
        id: 'rec_1',
        name: 'Dosa',
        description: 'Crispy golden South Indian crepe served with flavorful sambar & chutney',
        category: 'South Indian',
        price: 40,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 7,
        canteen: 'Rec Cafe',
      ),
      Food(
        id: 'rec_2',
        name: 'Sambar Rice',
        description: 'Traditional aromatic hot sambar sadham prepared with ghee and crisp appalam',
        category: 'Meals',
        price: 60,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 5,
        canteen: 'Rec Cafe',
      ),
      Food(
        id: 'rec_3',
        name: 'Veg Briyani',
        description: 'Fragrant basmati rice layered with garden vegetables and aromatic spices with raita',
        category: 'Meals',
        price: 90,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 10,
        canteen: 'Rec Cafe',
      ),
      Food(
        id: 'rec_4',
        name: 'Smoodh',
        description: 'Silky smooth rich chocolate milk shake cooler',
        category: 'Drinks',
        price: 20,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 2,
        canteen: 'Rec Cafe',
      ),
      Food(
        id: 'rec_5',
        name: 'Cavins',
        description: 'Rich creamy flavored dairy shake (Vanilla / Chocolate)',
        category: 'Drinks',
        price: 40,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 2,
        canteen: 'Rec Cafe',
      ),

      // Wokon (veg noodles, paneer noodles, gobi fried rice)
      Food(
        id: 'wok_1',
        name: 'Veg Noodles',
        description: 'Wok tossed noodles with crunchy cabbage, bell peppers and oriental sauces',
        category: 'Chinese',
        price: 90,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 10,
        canteen: 'Wokon',
      ),
      Food(
        id: 'wok_2',
        name: 'Paneer Noodles',
        description: 'Stir fried noodles loaded with marinated spiced paneer cubes and scallions',
        category: 'Chinese',
        price: 120,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 12,
        canteen: 'Wokon',
      ),
      Food(
        id: 'wok_3',
        name: 'Gobi Fried Rice',
        description: 'Flavorful wok fried rice tossed with crispy golden cauliflower florets',
        category: 'Chinese',
        price: 110,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 12,
        canteen: 'Wokon',
      ),

      // 6Sense (pani puri, bhel puri, sev puri, samosa)
      Food(
        id: 'sen_1',
        name: 'Pani Puri',
        description: 'Crisp puris stuffed with spiced potatoes and dipped in tangy mint pani',
        category: 'Chaat',
        price: 40,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 5,
        canteen: '6Sense',
      ),
      Food(
        id: 'sen_2',
        name: 'Bhel Puri',
        description: 'Puffed rice, crispy sev, diced onions and sweet tangy chutneys',
        category: 'Chaat',
        price: 45,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 5,
        canteen: '6Sense',
      ),
      Food(
        id: 'sen_3',
        name: 'Sev Puri',
        description: 'Flat crispy papdi layered with potato mash, sweet tamarind and nylon sev',
        category: 'Chaat',
        price: 50,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 6,
        canteen: '6Sense',
      ),
      Food(
        id: 'sen_4',
        name: 'Samosa',
        description: 'Crispy triangular flaky pastry stuffed with spicy potato and green peas',
        category: 'Snacks',
        price: 20,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 3,
        canteen: '6Sense',
      ),

      // Hotspot (peri peri maggi, cheeese maggi, plain maggi)
      Food(
        id: 'hot_1',
        name: 'Peri Peri Maggi',
        description: 'Classic masala Maggi noodles dusted with fiery peri peri seasoning',
        category: 'Maggi',
        price: 55,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 7,
        canteen: 'Hotspot',
      ),
      Food(
        id: 'hot_2',
        name: 'Cheese Maggi',
        description: 'Hot soupy Maggi smothered with melted cheddar and mozzarella cheese',
        category: 'Maggi',
        price: 65,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 8,
        canteen: 'Hotspot',
      ),
      Food(
        id: 'hot_3',
        name: 'Plain Maggi',
        description: 'Authentic 2-minute original tastemaker masala Maggi noodles',
        category: 'Maggi',
        price: 40,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1552611052-33e04de081de?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 6,
        canteen: 'Hotspot',
      ),

      // Hut Cafe (parotta, veg briyani, chapati)
      Food(
        id: 'hut_1',
        name: 'Parotta',
        description: 'Flaky layered South Indian parotta served with spicy veg salna kurma',
        category: 'South Indian',
        price: 45,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1626074353765-517a681e40be?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 8,
        canteen: 'Hut Cafe',
      ),
      Food(
        id: 'hut_2',
        name: 'Veg Briyani',
        description: 'Special Hut Cafe wood-fired dum vegetable biryani with onion raita',
        category: 'Meals',
        price: 95,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 10,
        canteen: 'Hut Cafe',
      ),
      Food(
        id: 'hut_3',
        name: 'Chapati',
        description: 'Pair of soft whole wheat chapatis served with flavorful vegetable kurma',
        category: 'Breads',
        price: 40,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 7,
        canteen: 'Hut Cafe',
      ),

      // Cafe Coffee Day (coofee, tea, pasta, cup noodles)
      Food(
        id: 'ccd_1',
        name: 'Coffee',
        description: 'Freshly brewed aromatic South Indian filter blend and CCD roast coffee',
        category: 'Drinks',
        price: 35,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 4,
        canteen: 'Cafe Coffee Day',
      ),
      Food(
        id: 'ccd_2',
        name: 'Tea',
        description: 'Freshly boiled ginger and cardamom infused hot masala milk tea',
        category: 'Drinks',
        price: 25,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 3,
        canteen: 'Cafe Coffee Day',
      ),
      Food(
        id: 'ccd_3',
        name: 'Pasta',
        description: 'Creamy Italian penne pasta tossed in herb garlic white Alfredo sauce',
        category: 'Italian',
        price: 120,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 14,
        canteen: 'Cafe Coffee Day',
      ),
      Food(
        id: 'ccd_4',
        name: 'Cup Noodles',
        description: 'Steaming hot savory vegetable ramen noodles in a convenient grab-and-go cup',
        category: 'Snacks',
        price: 50,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 5,
        canteen: 'Cafe Coffee Day',
      ),

      // Yippe (Classic Yippee Noodles, Cheese Yippee Noodles, Veggie Masala Yippee)
      Food(
        id: 'yip_1',
        name: 'Classic Yippee Noodles',
        description: 'Non-sticky round noodles cooked with signature spice masala mix',
        category: 'Noodles',
        price: 45,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 7,
        canteen: 'Yippe',
      ),
      Food(
        id: 'yip_2',
        name: 'Cheese Yippee Noodles',
        description: 'Loaded with melted cheese, sweet corn and creamy masala seasoning',
        category: 'Noodles',
        price: 65,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 8,
        canteen: 'Yippe',
      ),
      Food(
        id: 'yip_3',
        name: 'Veggie Masala Yippee',
        description: 'Tossed with fresh crunchy carrots, peas and capsicum in spicy savory sauce',
        category: 'Noodles',
        price: 55,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1612927601601-6638404737ce?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 7,
        canteen: 'Yippe',
      ),
    ]);

    // Sample initial order for demonstration
    _orders.add(
      Order(
        orderId: 'ORD-78291',
        items: [
          CartItem(food: _foods[0], quantity: 1),
          CartItem(food: _foods[3], quantity: 1),
        ],
        pickupSlot: '12:30 PM',
        tokenNumber: 'TK-108',
        orderTime: DateTime.now().subtract(const Duration(minutes: 8)),
        status: OrderStatus.preparing,
      ),
    );

    _orders.add(
      Order(
        orderId: 'ORD-65412',
        items: [
          CartItem(food: _foods[1], quantity: 1),
        ],
        pickupSlot: '1:15 PM',
        tokenNumber: 'TK-092',
        orderTime: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.completed,
      ),
    );

    // Initial Campus Food Distribution Hubs (ablock, dblock, techlounge, ideafactory, hostel)
    _distributionStations.addAll([
      const DistributionStation(
        id: 'st_ablock',
        name: 'A-Block Hub',
        code: 'HUB-A',
        location: 'A-Block Ground Floor',
        landmark: 'Near Main Entrance & Administrative Dean Office',
        totalBays: 16,
        occupiedBays: 8,
        queueStatus: 'Moderate',
        activeRunners: 4,
        themeColor: Color(0xFF1E3A8A),
      ),
      const DistributionStation(
        id: 'st_dblock',
        name: 'D-Block Hub',
        code: 'HUB-D',
        location: 'D-Block Central Corridor',
        landmark: 'Between Computing Labs & Engineering Seminar Hall',
        totalBays: 14,
        occupiedBays: 5,
        queueStatus: 'Low',
        activeRunners: 3,
        themeColor: Color(0xFF0F766E),
      ),
      const DistributionStation(
        id: 'st_techlounge',
        name: 'Tech Lounge Hub',
        code: 'HUB-TL',
        location: 'Tech Lounge Foyer',
        landmark: 'Next to High-Performance Computing & Robotics Arena',
        totalBays: 12,
        occupiedBays: 6,
        queueStatus: 'Moderate',
        activeRunners: 3,
        themeColor: Color(0xFF7C3AED),
      ),
      const DistributionStation(
        id: 'st_ideafactory',
        name: 'Idea Factory Hub',
        code: 'HUB-IF',
        location: 'Idea Factory Innovation Center',
        landmark: 'Adjacent to Startup Incubator & Maker Space',
        totalBays: 10,
        occupiedBays: 4,
        queueStatus: 'Low',
        activeRunners: 2,
        themeColor: Color(0xFFB45309),
      ),
      const DistributionStation(
        id: 'st_hostel',
        name: 'Hostel Hub',
        code: 'HUB-H',
        location: 'Hostel Common Block',
        landmark: 'Between Boys & Girls Residential Towers & Dining Hall',
        totalBays: 18,
        occupiedBays: 12,
        queueStatus: 'Heavy',
        activeRunners: 5,
        themeColor: Color(0xFFBE185D),
      ),
    ]);

    // Initial Multi-Canteen Consolidated Orders gathered at distribution stations
    _consolidatedOrders.addAll([
      ConsolidatedOrder(
        orderId: 'ORD-8821',
        tokenNumber: 'TK-REC-104',
        studentName: 'Aishwarya',
        studentRoll: '21CS042',
        studentPhone: '+91 98401 23456',
        stationId: 'st_ablock',
        stationName: 'A-Block Hub',
        bayNumber: 'Bay A-04',
        pickupSlot: '12:45 PM',
        orderTime: DateTime.now().subtract(const Duration(minutes: 14)),
        items: [
          ConsolidatedItem(
            foodName: 'Dosa',
            canteenName: 'Rec Cafe',
            quantity: 1,
            status: 'Arrived at Counter Bay',
            runnerName: 'Runner Selvam (Delivered)',
          ),
          ConsolidatedItem(
            foodName: 'Coffee',
            canteenName: 'Cafe Coffee Day',
            quantity: 1,
            status: 'Arrived at Counter Bay',
            runnerName: 'Runner Dinesh (Delivered)',
          ),
          ConsolidatedItem(
            foodName: 'Veg Noodles',
            canteenName: 'Wokon',
            quantity: 1,
            status: 'In Transit via Runner',
            runnerName: 'Runner Murugan (Bike #2)',
          ),
        ],
      ),
      ConsolidatedOrder(
        orderId: 'ORD-8829',
        tokenNumber: 'TK-REC-112',
        studentName: 'Rahul Sharma',
        studentRoll: '21IT019',
        studentPhone: '+91 97890 54321',
        stationId: 'st_dblock',
        stationName: 'D-Block Hub',
        bayNumber: 'Bay D-02',
        pickupSlot: '12:45 PM',
        orderTime: DateTime.now().subtract(const Duration(minutes: 20)),
        items: [
          ConsolidatedItem(
            foodName: 'Peri Peri Maggi',
            canteenName: 'Hotspot',
            quantity: 1,
            status: 'Arrived at Counter Bay',
          ),
          ConsolidatedItem(
            foodName: 'Parotta',
            canteenName: 'Hut Cafe',
            quantity: 2,
            status: 'Arrived at Counter Bay',
          ),
        ],
      ),
      ConsolidatedOrder(
        orderId: 'ORD-8840',
        tokenNumber: 'TK-REC-125',
        studentName: 'Kavya R.',
        studentRoll: '22EC081',
        studentPhone: '+91 99402 11223',
        stationId: 'st_techlounge',
        stationName: 'Tech Lounge Hub',
        bayNumber: 'Bay TL-03',
        pickupSlot: '01:15 PM',
        orderTime: DateTime.now().subtract(const Duration(minutes: 6)),
        items: [
          ConsolidatedItem(
            foodName: 'Veg Briyani',
            canteenName: 'Rec Cafe',
            quantity: 1,
            status: 'Preparing in Kitchen',
          ),
          ConsolidatedItem(
            foodName: 'Pani Puri',
            canteenName: '6Sense',
            quantity: 1,
            status: 'Preparing in Kitchen',
          ),
        ],
      ),
      ConsolidatedOrder(
        orderId: 'ORD-8790',
        tokenNumber: 'TK-REC-095',
        studentName: 'Karthik S.',
        studentRoll: '20ME055',
        studentPhone: '+91 98840 99887',
        stationId: 'st_hostel',
        stationName: 'Hostel Hub',
        bayNumber: 'Bay H-01',
        pickupSlot: '12:15 PM',
        orderTime: DateTime.now().subtract(const Duration(minutes: 45)),
        isHandedOver: true,
        items: [
          ConsolidatedItem(
            foodName: 'Pasta',
            canteenName: 'Cafe Coffee Day',
            quantity: 2,
            status: 'Arrived at Counter Bay',
          ),
          ConsolidatedItem(
            foodName: 'Chapati',
            canteenName: 'Hut Cafe',
            quantity: 2,
            status: 'Arrived at Counter Bay',
          ),
        ],
      ),
    ]);

    // Initial Demand Forecast Slots for Kitchen Staff
    _demandSlots.addAll([
      DemandSlot(
        id: 'slot_morning',
        title: 'Morning Refreshment Break',
        timeRange: '10:15 AM - 10:35 AM',
        expectedOrderCount: 85,
        currentPreOrders: 34,
        rushLevel: 'Elevated Rush',
        rushMultiplier: 1.8,
        kitchenAdvisory:
            'Prep 60 Samosas & 45 Sandwiches by 10:00 AM to prevent counter bottleneck.',
        dishes: [
          DemandDishForecast(
            dishName: 'Hot Samosa & Chai Combo',
            canteenName: 'Rec Cafe',
            category: 'Snacks',
            forecastedQuantity: 65,
            preOrdersPlaced: 30,
            preppedQuantity: 50,
          ),
          DemandDishForecast(
            dishName: 'Grilled Veg Sandwich',
            canteenName: 'Hut Cafe',
            category: 'Snacks',
            forecastedQuantity: 35,
            preOrdersPlaced: 18,
            preppedQuantity: 25,
          ),
          DemandDishForecast(
            dishName: 'Cold Coffee Frappe',
            canteenName: 'Cafe Coffee Day',
            category: 'Drinks',
            forecastedQuantity: 40,
            preOrdersPlaced: 22,
            preppedQuantity: 32,
          ),
        ],
      ),
      DemandSlot(
        id: 'slot_lunch_1',
        title: 'Lunch Rush 1 (Peak Campus)',
        timeRange: '12:45 PM - 01:15 PM',
        expectedOrderCount: 210,
        currentPreOrders: 96,
        rushLevel: 'CRITICAL HIGH DEMAND',
        rushMultiplier: 2.7,
        kitchenAdvisory:
            'High rush period. Central Food Court Hub (Station Alpha) at capacity. Dispatch runners early.',
        dishes: [
          DemandDishForecast(
            dishName: 'Paneer Butter Masala Combo',
            canteenName: 'Rec Cafe',
            category: 'Meals',
            forecastedQuantity: 55,
            preOrdersPlaced: 38,
            preppedQuantity: 42,
          ),
          DemandDishForecast(
            dishName: 'Veg Hakka Noodles',
            canteenName: 'Wokon',
            category: 'Meals',
            forecastedQuantity: 70,
            preOrdersPlaced: 45,
            preppedQuantity: 48,
          ),
          DemandDishForecast(
            dishName: 'Chicken Biryani Rice',
            canteenName: 'Hotspot',
            category: 'Meals',
            forecastedQuantity: 75,
            preOrdersPlaced: 52,
            preppedQuantity: 54,
          ),
          DemandDishForecast(
            dishName: 'Paneer Pizza',
            canteenName: 'Hotspot',
            category: 'Pizza',
            forecastedQuantity: 35,
            preOrdersPlaced: 20,
            preppedQuantity: 20,
          ),
        ],
      ),
      DemandSlot(
        id: 'slot_lunch_2',
        title: 'Lunch Rush 2',
        timeRange: '01:15 PM - 01:45 PM',
        expectedOrderCount: 130,
        currentPreOrders: 45,
        rushLevel: 'Moderate Rush',
        rushMultiplier: 1.4,
        kitchenAdvisory:
            'Batch refill Meals & Thali. Encourage students to pick up at Station Beta.',
        dishes: [
          DemandDishForecast(
            dishName: 'South Indian Meal Platter',
            canteenName: 'Rec Cafe',
            category: 'Meals',
            forecastedQuantity: 45,
            preOrdersPlaced: 20,
            preppedQuantity: 30,
          ),
          DemandDishForecast(
            dishName: 'Classic Chicken Roll',
            canteenName: 'Hut Cafe',
            category: 'Snacks',
            forecastedQuantity: 40,
            preOrdersPlaced: 15,
            preppedQuantity: 22,
          ),
        ],
      ),
      DemandSlot(
        id: 'slot_evening',
        title: 'Evening Snacks & Refreshment',
        timeRange: '04:15 PM - 04:45 PM',
        expectedOrderCount: 65,
        currentPreOrders: 16,
        rushLevel: 'Normal',
        rushMultiplier: 1.0,
        kitchenAdvisory:
            'Standard stock of cold coffee, shakes and crispy rolls recommended.',
        dishes: [
          DemandDishForecast(
            dishName: 'Crispy Veg Burger',
            canteenName: 'Rec Cafe',
            category: 'Snacks',
            forecastedQuantity: 35,
            preOrdersPlaced: 10,
            preppedQuantity: 15,
          ),
          DemandDishForecast(
            dishName: 'Cold Coffee with Ice Cream',
            canteenName: 'Cafe Coffee Day',
            category: 'Drinks',
            forecastedQuantity: 35,
            preOrdersPlaced: 12,
            preppedQuantity: 20,
          ),
        ],
      ),
    ]);
  }
}
