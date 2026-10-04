import 'package:flutter/material.dart';
import '../../models/food.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/food_cart.dart';
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
  bool _isGridView = true;
  bool _eatRightOnly = false;
  bool _ratingFourPlus = false;

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

  bool _isFoodFromThisCanteen(Food food) {
    final target = widget.canteenName.trim().toLowerCase();
    final foodCanteen = (food.canteen ?? '').trim().toLowerCase();
    if (foodCanteen.isEmpty) return true;
    if (target.isEmpty) return true;
    if (foodCanteen == target) return true;
    if (target.contains(foodCanteen) || foodCanteen.contains(target)) return true;
    if (target.contains('6') && foodCanteen.contains('6')) return true;
    if (target.contains('ccd') && foodCanteen.contains('coffee')) return true;
    return false;
  }

  List<String> get _canteenCategories {
    final Set<String> cats = {'All'};
    for (final f in _service.foods) {
      if (_isFoodFromThisCanteen(f) && f.category.isNotEmpty) {
        cats.add(f.category);
      }
    }
    return cats.toList();
  }

  List<Food> get _filteredFoods {
    return _service.foods.where((food) {
      if (!_isFoodFromThisCanteen(food)) return false;

      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.description.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == "All" || food.category == _selectedCategory;
      final matchesDiet = _selectedDiet == "All" ||
          (_selectedDiet == "Veg" && food.isVeg) ||
          (_selectedDiet == "Non-Veg" && !food.isVeg);
      final matchesEatRight = !_eatRightOnly || (food.isVeg && food.preparationTime <= 15);
      final matchesRating = !_ratingFourPlus || food.rating >= 4.0;

      return matchesSearch && matchesCategory && matchesDiet && matchesEatRight && matchesRating;
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

            const SizedBox(height: 14),

            // Top Search Bar (Image 3 Style: Pill container with mic & profile)
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: "Search in ${widget.canteenName}",
                        hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade500),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = "";
                        });
                      },
                      child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                    ),
                  const SizedBox(width: 8),
                  Icon(Icons.mic_none_rounded, color: Colors.deepOrange.shade600, size: 20),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Quick Filter Switch Row (Image 3 Style: Veg, Non-Veg, EatRight, 4.0+)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _vegTogglePill(),
                  const SizedBox(width: 8),
                  _nonVegTogglePill(),
                  const SizedBox(width: 8),
                  _eatRightPill(),
                  const SizedBox(width: 8),
                  _ratingFilterPill(),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Category Horizontal Chips
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _canteenCategories.length,
                itemBuilder: (context, index) {
                  final cat = _canteenCategories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.textPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // Menu Section Header (Image 3: "Recommended (20) ⌵")
            Row(
              children: [
                Text(
                  "Recommended (${_filteredFoods.length})",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 22, color: AppColors.textPrimary),
                const Spacer(),
                // Toggle Grid / List
                IconButton(
                  tooltip: _isGridView ? "Switch to List View" : "Switch to Grid View",
                  icon: Icon(
                    _isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Foods Content (2-Column Grid from Image 3 or List)
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
                        "Try clearing diet filters or search query",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredFoods.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  final isFav = _service.isFavourite(food.id);
                  final qty = _service.getFoodQuantity(food.id);

                  return FoodGridCard(
                    food: food,
                    isFavourite: isFav,
                    cartQuantity: qty,
                    onFavourite: () => _service.toggleFavourite(food.id),
                    onAdd: () {
                      _service.addToCart(food);
                      _showAddedSnackbar(food);
                    },
                    onRemove: () {
                      _service.updateQuantity(food.id, -1);
                    },
                  );
                },
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = _filteredFoods[index];
                  final isFav = _service.isFavourite(food.id);
                  final qty = _service.getFoodQuantity(food.id);

                  return FoodCard(
                    food: food,
                    isFavourite: isFav,
                    cartQuantity: qty,
                    onFavourite: () => _service.toggleFavourite(food.id),
                    onAdd: () {
                      _service.addToCart(food);
                      _showAddedSnackbar(food);
                    },
                    onRemove: () {
                      _service.updateQuantity(food.id, -1);
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

  void _showAddedSnackbar(Food food) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added to cart!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: _openCart,
        ),
      ),
    );
  }

  Widget _vegTogglePill() {
    final isVegActive = _selectedDiet == "Veg";
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiet = isVegActive ? "All" : "Veg";
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isVegActive ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isVegActive ? const Color(0xFF16A34A) : Colors.grey.shade300,
            width: isVegActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Center(
                child: CircleAvatar(backgroundColor: Color(0xFF16A34A), radius: 3),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Veg",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            Icon(
              isVegActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: isVegActive ? const Color(0xFF16A34A) : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _nonVegTogglePill() {
    final isNonVegActive = _selectedDiet == "Non-Veg";
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDiet = isNonVegActive ? "All" : "Non-Veg";
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isNonVegActive ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isNonVegActive ? const Color(0xFFD32F2F) : Colors.grey.shade300,
            width: isNonVegActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Center(
                child: Icon(Icons.arrow_drop_up_rounded, color: Color(0xFFD32F2F), size: 14),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Non-Veg",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            Icon(
              isNonVegActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: isNonVegActive ? const Color(0xFFD32F2F) : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _eatRightPill() {
    return InkWell(
      onTap: () {
        setState(() {
          _eatRightOnly = !_eatRightOnly;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _eatRightOnly ? Colors.pink.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _eatRightOnly ? Colors.pink.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _eatRightOnly ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 14,
              color: _eatRightOnly ? Colors.pink : Colors.grey.shade700,
            ),
            const SizedBox(width: 5),
            Text(
              "EatRight",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _eatRightOnly ? Colors.pink.shade900 : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingFilterPill() {
    return InkWell(
      onTap: () {
        setState(() {
          _ratingFourPlus = !_ratingFourPlus;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _ratingFourPlus ? Colors.amber.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _ratingFourPlus ? Colors.amber.shade400 : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Ratings 4.0+",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _ratingFourPlus ? Colors.amber.shade900 : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}