import 'package:flutter/material.dart';
import '../../models/food.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/food_cart.dart';
import '../../widgets/search_bar.dart';
import 'cart_screen.dart';

class CanteenMenu extends StatefulWidget {
  final String canteenName;

  const CanteenMenu({
    super.key,
    required this.canteenName,
  });

  @override
  State<CanteenMenu> createState() => _CanteenMenuState();
}

class _CanteenMenuState extends State<CanteenMenu> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = "All";
  String _selectedDiet = "All"; // "All", "Veg", "Non-Veg"
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _searchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Map<String, dynamic>? get _canteenInfo {
    try {
      return _service.canteens.firstWhere(
        (c) => c['name'].toString().toLowerCase() == widget.canteenName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  List<Food> get _filteredFoods {
    return _service.foods.where((food) {
      final matchesSearch = food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          food.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == "All" || food.category == _selectedCategory;
      final matchesDiet = _selectedDiet == "All" ||
          (_selectedDiet == "Veg" && food.isVeg) ||
          (_selectedDiet == "Non-Veg" && !food.isVeg);

      return matchesSearch && matchesCategory && matchesDiet;
    }).toList();
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  Color _getQueueColor(String status) {
    switch (status.toLowerCase()) {
      case 'low':
        return AppColors.queueLow;
      case 'medium':
        return AppColors.queueMedium;
      case 'high':
        return AppColors.queueHigh;
      default:
        return AppColors.queueLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteen = _canteenInfo;
    final queueStatus = canteen?['queueStatus'] ?? 'Low';
    final queueWait = canteen?['queueWait'] ?? '5 mins wait';
    final location = canteen?['location'] ?? 'Rajalakshmi Engineering College';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.canteenName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 3),
                Text(
                  location,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary),
              ),
              if (_service.cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${_service.cartCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Canteen Live Queue & Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getQueueColor(queueStatus).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getQueueColor(queueStatus),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Queue: $queueStatus",
                          style: TextStyle(
                            color: _getQueueColor(queueStatus),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        queueWait,
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.star, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          canteen?['rating'] ?? '4.8',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Search Bar
            AppSearchBar(
              controller: _searchController,
              hintText: 'Search food in ${widget.canteenName}...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),

            const SizedBox(height: 20),

            // Category Chips
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.categories.length,
                itemBuilder: (context, index) {
                  final cat = AppConstants.categories[index];
                  return CategoryChip(
                    title: cat,
                    selected: _selectedCategory == cat,
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Veg / Non-Veg Diet Filter
            Row(
              children: [
                _dietFilterChip("All", Icons.restaurant),
                const SizedBox(width: 8),
                _dietFilterChip("Veg", Icons.eco, color: AppColors.veg),
                const SizedBox(width: 8),
                _dietFilterChip("Non-Veg", Icons.kebab_dining, color: AppColors.nonVeg),
              ],
            ),

            const SizedBox(height: 22),

            // Menu Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Menu Items (${_filteredFoods.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Skip the line, pre-order",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Foods List
            if (_filteredFoods.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.no_meals_rounded, size: 55, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No food found",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Try searching for another dish or category",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  final isFav = _service.isFavourite(food.id);

                  return FoodCard(
                    food: food,
                    isFavourite: isFav,
                    onFavourite: () => _service.toggleFavourite(food.id),
                    onAdd: () {
                      _service.addToCart(food);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${food.name} added to cart!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: 'VIEW CART',
                            textColor: Colors.white,
                            onPressed: _openCart,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _service.cartCount > 0
          ? Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: InkWell(
                  onTap: _openCart,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_service.cartCount} ${_service.cartCount == 1 ? "item" : "items"}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "₹${_service.cartTotal.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          "View Cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _dietFilterChip(String label, IconData icon, {Color? color}) {
    final isSelected = _selectedDiet == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiet = label;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.textPrimary : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : (color ?? Colors.grey.shade700),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}