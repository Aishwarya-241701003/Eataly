import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import 'canteen_heatmap_screen.dart';
import 'canteen_menu.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final FirestoreService _service = FirestoreService();
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final Color red = AppColors.primary;
  final Color cream = AppColors.background;
  final Color dark = AppColors.textPrimary;

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

  void _openCanteen(String canteenName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CanteenMenu(canteenName: canteenName),
      ),
    );
  }

  void _openHeatmap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CanteenHeatmapScreen(),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CartScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            const OrdersScreen(showBackButton: false),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: _selectedIndex == 0 && _service.cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: _openCart,
              backgroundColor: red,
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: Text(
                'Cart (${_service.cartCount}) • ₹${_service.cartTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
    );
  }

  // ------------------------------------------------------------
  // HOME SCREEN
  // ------------------------------------------------------------

  Widget _buildHome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSearchBar(),
          _buildHighDemandAlertBanner(),
          const SizedBox(height: 26),
          _buildOfferBanner(),
          const SizedBox(height: 24),
          _buildCrowdHeatmapBanner(),
          const SizedBox(height: 28),
          _sectionTitle(
            'Choose your canteen',
            'Skip the line • Live queue wait times',
            actionLabel: 'Crowd Map',
            onSeeAll: _openHeatmap,
          ),
          const SizedBox(height: 16),
          _buildCanteens(),
          const SizedBox(height: 32),
          _sectionTitle(
            'Featured today',
            'Fast preparation • Popular campus picks',
            onSeeAll: () => _openCanteen("Rec Cafe"),
          ),
          const SizedBox(height: 18),
          _buildFoodList(),
          const SizedBox(height: 32),
          _sectionTitle(
            'Near to your heart',
            'Your frequently ordered favourite',
          ),
          const SizedBox(height: 18),
          _buildFavouriteCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Good day 👋',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "REC CAMPUS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Aishwarya',
                  style: TextStyle(
                    color: dark,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),

          // Shopping Bag / Cart with Badge
          GestureDetector(
            onTap: _openCart,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: dark,
                    size: 24,
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
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${_service.cartCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Profile Button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 2; // Jump to profile tab
              });
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: () => _openCanteen("Rec Cafe"),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Icon(
                Icons.search_rounded,
                color: Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search food, canteens, drinks...',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(6),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LIVE HIGH DEMAND ALERT BANNER (FROM ADMIN)
  // ------------------------------------------------------------

  Widget _buildHighDemandAlertBanner() {
    if (!_service.isHighDemandActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_rounded,
                  color: AppColors.danger, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        'CAMPUS RUSH SURGE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.danger,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '• LIVE NOTICE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _service.highDemandAlert,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _openHeatmap,
                    child: const Text(
                      'Check Less Crowded Canteens on Live Heatmap →',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OFFER BANNER
  // ------------------------------------------------------------

  Widget _buildOfferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: red.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -35,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: -25,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'BREAK TIME SPECIAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Hungry?\nSkip The Line.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pre-order now & pick up at break',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 90,
                    child: Icon(
                      Icons.fastfood_rounded,
                      color: Colors.white,
                      size: 78,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LIVE CROWD HEATMAP BANNER
  // ------------------------------------------------------------

  Widget _buildCrowdHeatmapBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GestureDetector(
        onTap: _openHeatmap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A1410), Color(0xFF1E0E0A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: red.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: red.withValues(alpha: 0.45), width: 1.5),
                ),
                child: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.queueLow,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'LIVE CROWD HEATMAP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.queueLow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Live Canteen Crowd Levels',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find least crowded canteens before you order',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _sectionTitle(String title, String subtitle, {String actionLabel = 'See all', VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: dark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      color: red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (actionLabel != 'See all') ...[
                    const SizedBox(width: 3),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: red),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // CANTEENS
  // ------------------------------------------------------------

  Widget _buildCanteens() {
    final canteens = _service.canteens;

    return SizedBox(
      height: 165,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: canteens.length + 1,
        itemBuilder: (context, index) {
          if (index == canteens.length) {
            return GestureDetector(
              onTap: _openHeatmap,
              child: Container(
                width: 135,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [red, AppColors.offerGradient2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: red.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Live Crowd\nHeatmap',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: red,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final canteen = canteens[index];
          final queueStatus = canteen['queueStatus'] as String? ?? 'Low';
          final queueWait = canteen['queueWait'] as String? ?? '5 mins';

          Color queueColor = AppColors.queueLow;
          if (queueStatus.toLowerCase() == 'medium') queueColor = AppColors.queueMedium;
          if (queueStatus.toLowerCase() == 'high') queueColor = AppColors.queueHigh;

          return GestureDetector(
            onTap: () => _openCanteen(canteen['name']),
            child: Container(
              width: 135,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Image.network(
                          canteen['image'],
                          height: 92,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              height: 92,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.restaurant),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: queueColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                queueWait.split(' ').first,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            canteen['name'],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: dark,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            canteen['location'] ?? 'Campus',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FOOD LIST
  // ------------------------------------------------------------

  Widget _buildFoodList() {
    final featuredFoods = _service.foods.take(4).toList();

    return SizedBox(
      height: 285,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: featuredFoods.length,
        itemBuilder: (context, index) {
          final food = featuredFoods[index];
          final qty = _service.getFoodQuantity(food.id);

          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.055),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      child: Image.network(
                        food.image,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            height: 155,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.fastfood_rounded,
                              size: 45,
                            ),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.orange.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              food.rating.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      right: 12,
                      bottom: -18,
                      child: _InteractiveFoodAddButton(
                        count: qty,
                        size: 42,
                        onAdd: () {
                          _service.addToCart(food);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${food.name} added to cart!'),
                              backgroundColor: red,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 1400),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: Colors.white,
                                onPressed: _openCart,
                              ),
                            ),
                          );
                        },
                        onRemove: () {
                          _service.updateQuantity(food.id, -1);
                        },
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 17, 14, 0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: food.isVeg ? AppColors.veg : AppColors.nonVeg,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dark,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                  child: Text(
                    "${food.category} • ${food.preparationTime} mins prep",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Text(
                    "₹${food.price.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: red,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FAVOURITE CARD
  // ------------------------------------------------------------

  Widget _buildFavouriteCard() {
    final favFood = _service.foods.firstWhere(
      (f) => f.name.contains("Roll") || f.name.contains("Burger"),
      orElse: () => _service.foods.first,
    );
    final favQty = _service.getFoodQuantity(favFood.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          color: dark,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(25),
              ),
              child: Image.network(
                favFood.image,
                width: 125,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 125,
                    height: 125,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your favourite',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      favFood.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹${favFood.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        _InteractiveFoodAddButton(
                          count: favQty,
                          size: 36,
                          onAdd: () {
                            _service.addToCart(favFood);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${favFood.name} added to cart!'),
                                backgroundColor: red,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(milliseconds: 1400),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  textColor: Colors.white,
                                  onPressed: _openCart,
                                ),
                              ),
                            );
                          },
                          onRemove: () {
                            _service.updateQuantity(favFood.id, -1);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BOTTOM NAVIGATION
  // ------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      decoration: BoxDecoration(
        color: cream,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: 'Home',
              index: 0,
            ),
            _navItem(
              icon: Icons.receipt_long_rounded,
              label: 'Orders',
              index: 1,
            ),
            _navItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool selected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? red.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? red : Colors.grey.shade500,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: red,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InteractiveFoodAddButton extends StatefulWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final double size;

  const _InteractiveFoodAddButton({
    required this.count,
    required this.onAdd,
    this.onRemove,
    this.size = 42,
  });

  @override
  State<_InteractiveFoodAddButton> createState() => _InteractiveFoodAddButtonState();
}

class _InteractiveFoodAddButtonState extends State<_InteractiveFoodAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapBounce(VoidCallback action) async {
    await _controller.reverse();
    action();
    if (mounted) {
      await _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    const red = AppColors.primary;

    if (widget.count > 0) {
      // Expanded stepper pill showing count and - / +
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.size,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: red,
            borderRadius: BorderRadius.circular(widget.size / 2),
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: widget.onRemove != null
                    ? () => _tapBounce(widget.onRemove!)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Icon(
                    Icons.remove_rounded,
                    color: Colors.white,
                    size: widget.size * 0.45,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '${widget.count}',
                  key: ValueKey<int>(widget.count),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: widget.size * 0.36,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _tapBounce(widget.onAdd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: widget.size * 0.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default + circle button with click bounce & micro-interactions
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () => _tapBounce(widget.onAdd),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: red.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: widget.size * 0.58,
          ),
        ),
      ),
    );
  }
}