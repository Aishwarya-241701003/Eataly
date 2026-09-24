import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class FirestoreService extends ChangeNotifier {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  FirestoreService._internal() {
    _initData();
  }

  final List<Food> _foods = [];
  final List<Map<String, dynamic>> _canteens = [];
  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  final Set<String> _favourites = {'1', '2'};

  List<Food> get foods => List.unmodifiable(_foods);
  List<Map<String, dynamic>> get canteens => List.unmodifiable(_canteens);
  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  Set<String> get favourites => Set.unmodifiable(_favourites);

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartTotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);

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

  Order placeOrder({
    required String pickupSlot,
    String? canteenName,
    String paymentMethod = "Campus Card",
    String? notes,
  }) {
    final token = "TK-${100 + _orders.length + 1}";
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    final newOrder = Order(
      orderId: orderId,
      items: List.from(_cart),
      pickupSlot: pickupSlot,
      tokenNumber: token,
      orderTime: DateTime.now(),
      status: OrderStatus.preparing,
    );

    _orders.insert(0, newOrder);
    clearCart();
    notifyListeners();
    return newOrder;
  }

  void cancelOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      _orders[index].status = OrderStatus.cancelled;
      notifyListeners();
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
      Food(
        id: '1',
        name: 'Chicken Burger',
        description: 'Juicy crispy chicken patty with fresh lettuce, mayo & toasted sesame buns',
        category: 'Snacks',
        price: 129,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900',
        available: true,
        isVeg: false,
        isPopular: true,
        isNew: false,
        preparationTime: 12,
      ),
      Food(
        id: '2',
        name: 'Paneer Pizza',
        description: 'Loaded with spiced paneer cubes, capsicum, onion and melted mozzarella cheese',
        category: 'Pizza',
        price: 149,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=900',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 15,
      ),
      Food(
        id: '3',
        name: 'Veg Hakka Noodles',
        description: 'Wok tossed noodles with crunchy shredded vegetables and oriental spices',
        category: 'Meals',
        price: 99,
        rating: 4.6,
        image: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=900',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 10,
      ),
      Food(
        id: '4',
        name: 'Cold Coffee Frappe',
        description: 'Creamy chilled brewed coffee topped with rich chocolate drizzle',
        category: 'Drinks',
        price: 89,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=900',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: false,
        preparationTime: 5,
      ),
      Food(
        id: '5',
        name: 'Chicken Biryani Rice',
        description: 'Fragrant basmati rice cooked with authentic spices, tender chicken & raita',
        category: 'Meals',
        price: 130,
        rating: 4.8,
        image: 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
        available: true,
        isVeg: false,
        isPopular: true,
        isNew: false,
        preparationTime: 10,
      ),
      Food(
        id: '6',
        name: 'Classic Chicken Roll',
        description: 'Flaky parotta wrap stuffed with succulent spiced chicken chunks and mint chutney',
        category: 'Snacks',
        price: 109,
        rating: 4.7,
        image: 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600',
        available: true,
        isVeg: false,
        isPopular: true,
        isNew: false,
        preparationTime: 8,
      ),
      Food(
        id: '7',
        name: 'Grilled Veg Sandwich',
        description: 'Triple-layer toasted sandwich stuffed with fresh vegetables, cheese and green chutney',
        category: 'Snacks',
        price: 80,
        rating: 4.3,
        image: 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 8,
      ),
      Food(
        id: '8',
        name: 'Fresh Mint Lime Juice',
        description: 'Zesty fresh lime cooler infused with crushed mint leaves and rock salt',
        category: 'Drinks',
        price: 60,
        rating: 4.4,
        image: 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800',
        available: true,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 4,
      ),
      Food(
        id: '9',
        name: 'Warm Choco Brownie',
        description: 'Fudgy warm chocolate brownie served with molten hot chocolate drizzle',
        category: 'Desserts',
        price: 70,
        rating: 4.9,
        image: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800',
        available: true,
        isVeg: true,
        isPopular: true,
        isNew: true,
        preparationTime: 5,
      ),
      Food(
        id: '10',
        name: 'Cheesy Garlic Bread',
        description: 'Toasted baguette slices infused with herb butter and smothered in mozzarella',
        category: 'Snacks',
        price: 85,
        rating: 4.5,
        image: 'https://images.unsplash.com/photo-1619895092538-128341789043?w=800',
        available: false,
        isVeg: true,
        isPopular: false,
        isNew: false,
        preparationTime: 12,
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
  }
}
