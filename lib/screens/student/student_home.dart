import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/offline_sync_service.dart';
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
          const SizedBox(height: 18),
          _buildSearchBar(),
          _buildDistrictExperienceCards(),
          _buildSmartLoadBalancerBanner(),
          _buildIntelligentRecommendations(),
          _buildHighDemandAlertBanner(),
          const SizedBox(height: 24),
          _buildOfferBanner(),
          const SizedBox(height: 24),
          _buildCrowdHeatmapBanner(),
          const SizedBox(height: 28),
          _sectionTitle(
            'Choose your canteen',
            'Live queue • Crowd heat level • Wait prediction',
            actionLabel: 'Crowd Map',
            onSeeAll: _openHeatmap,
          ),
          const SizedBox(height: 16),
          _buildCanteens(),
          const SizedBox(height: 30),
          _sectionTitle(
            '🔥 Trending across campus',
            'Selling fast • Real-time live demand',
            actionLabel: 'View All',
            onSeeAll: () => _openCanteen("Rec Cafe"),
          ),
          const SizedBox(height: 16),
          _buildTrendingSection(),
          const SizedBox(height: 30),
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
  // HEADER (DISTRICT STYLE: LOCATION ROW + RING AVATAR)
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // District-style Vibrant Location Pin
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rajalakshmi Nagar',
                      style: TextStyle(
                        color: dark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: dark,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Thandalam, Chennai',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Offline / Online Status Pill
                    GestureDetector(
                      onTap: () {
                        final nextState = !OfflineSyncService().isOnline;
                        OfflineSyncService().toggleOnlineStatus(nextState);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              nextState
                                  ? "🟢 Cloud Synced: Online mode active"
                                  : "⚡ Offline Mode: Orders cached locally & will auto-sync",
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OfflineSyncService().isOnline
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: OfflineSyncService().isOnline
                                ? const Color(0xFF81C784)
                                : const Color(0xFFFFB74D),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              OfflineSyncService().isOnline
                                  ? Icons.cloud_done_rounded
                                  : Icons.wifi_off_rounded,
                              size: 10,
                              color: OfflineSyncService().isOnline
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              OfflineSyncService().isOnline ? "Synced" : "Offline",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: OfflineSyncService().isOnline
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE65100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Shopping Bag / Cart with Badge
          GestureDetector(
            onTap: _openCart,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: dark,
                    size: 22,
                  ),
                  if (_service.cartCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
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

          // District-style Profile Circle Avatar with Ring
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 2; // Jump to profile tab
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.primaryDark,
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SEARCH (THEOBROMA / DISTRICT PILL STYLE)
  // ------------------------------------------------------------

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _openCanteen("Rec Cafe"),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.search_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Search for 'burger', 'cold coffee'...",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.mic_none_rounded,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DISTRICT APP STYLE: EXPERIENCE / CATEGORY TILES
  // ------------------------------------------------------------

  Widget _buildDistrictExperienceCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _experienceCard(
              title: "Dining",
              subtitle: "4 Canteens",
              badge: "EXPLORE",
              icon: Icons.restaurant_rounded,
              gradientColors: [const Color(0xFF1E212A), const Color(0xFF13151B)],
              iconColor: const Color(0xFFFF6B4A),
              onTap: () => _openCanteen("Rec Cafe"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _experienceCard(
              title: "Express Hub",
              subtitle: "Instant Pick",
              badge: "4 MINS",
              icon: Icons.bolt_rounded,
              gradientColors: [const Color(0xFF1E212A), const Color(0xFF13151B)],
              iconColor: const Color(0xFFFBBF24),
              onTap: () => _openCanteen("Hut Cafe"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _experienceCard(
              title: "Crowd Map",
              subtitle: "Live Radar",
              badge: "LIVE",
              icon: Icons.radar_rounded,
              gradientColors: [const Color(0xFF1E212A), const Color(0xFF13151B)],
              iconColor: const Color(0xFF10B981),
              onTap: _openHeatmap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard({
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 102,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1.5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SMART KITCHEN LOAD BALANCER BANNER (ZEPTO / DISTRICT STYLE)
  // ------------------------------------------------------------
  Widget _buildSmartLoadBalancerBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E1065),
              Color(0xFF4C1D95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C1D95).withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: Colors.black),
                      SizedBox(width: 3),
                      Text(
                        "SMART LOAD BALANCER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "⚡ Save 8 Mins",
                    style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Hungry for Burgers or Quick Bites?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Rec Cafe has 12 orders queued (15m wait). Switch to Hut Cafe (4m wait) to get freshly prepared food 11 mins faster!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.compare_arrows_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Rec Cafe: 15m ➔ Hut Cafe: 4m",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _openCanteen("Hut Cafe"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade400,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Switch Now",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INTELLIGENT FOOD RECOMMENDATIONS (ZEPTO STYLE)
  // ------------------------------------------------------------
  Widget _buildIntelligentRecommendations() {
    final recs = _service.personalizedRecommendations;
    if (recs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personalized for You",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "You usually order Cold Coffee & Dosa on Fridays",
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recs.length,
            itemBuilder: (context, index) {
              final food = recs[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        food.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.fastfood, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "⚡ ${food.preparationTime}m prep",
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            food.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₹${food.price.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              _service.addToCart(food);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("${food.name} added to cart!"),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Text(
                              "+ Quick Add",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TRENDING ACROSS CAMPUS (THEOBROMA / ATTACHMENT 3 STYLE)
  // ------------------------------------------------------------
  Widget _buildTrendingSection() {
    final trending = _service.trendingFoods;
    if (trending.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 228,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: trending.length,
        itemBuilder: (context, index) {
          final food = trending[index];
          final qty = _service.getFoodQuantity(food.id);

          return GestureDetector(
            onTap: () => _openCanteen(food.canteen ?? "Rec Cafe"),
            child: Container(
              width: 155,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.network(
                          food.image,
                          height: 105,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 105,
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.fastfood, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Attachment 3 ⭐ Bestseller badge
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "⭐ Bestseller",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Veg/Non-Veg + Rating pill row
                        Row(
                          children: [
                            Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: food.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: food.isVeg ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 10, color: Color(0xFF15803D)),
                                  const SizedBox(width: 2),
                                  Text(
                                    "${food.rating}",
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Only ${food.remainingCount} left • ${food.canteen ?? 'Campus'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.deepOrange.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${food.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            // Attachment 3 crisp outline ADD button
                            InkWell(
                              onTap: () {
                                _service.addToCart(food);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${food.name} added!"),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: qty > 0 ? const Color(0xFF16A34A) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF16A34A),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  qty > 0 ? "$qty in cart" : "ADD",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: qty > 0 ? Colors.white : const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
  // IN THE SPOTLIGHT (DISTRICT APP STYLE POSTER CAROUSEL)
  // ------------------------------------------------------------

  Widget _buildOfferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'In the spotlight',
                style: TextStyle(
                  color: dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: dark, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 175,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B151B), Color(0xFF1E1116)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Subtle decorative background elements
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Icon(
                    Icons.fastfood_rounded,
                    color: Colors.white.withOpacity(0.15),
                    size: 90,
                  ),
                ),

                // Card content
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'BREAK TIME SPECIAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          // District style Bookmark button
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hungry? Skip The Line.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Pre-order now & pick up at break • Avoid campus rush',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _openCanteen("Rec Cafe"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Pre-order Now",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 14),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // District style dot pagination indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
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
      height: 195,
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
                width: 148,
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
          final liveStatus = _service.getCanteenLiveStatus(canteen['name']);
          final queueWait = "${liveStatus['waitMins']}m wait";
          final queueColor = liveStatus['crowd'] == 'Heavy'
              ? AppColors.queueHigh
              : (liveStatus['crowd'] == 'Medium' ? AppColors.queueMedium : AppColors.queueLow);

          return GestureDetector(
            onTap: () => _openCanteen(canteen['name']),
            child: Container(
              width: 148,
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
                      // Crowd Pill (Top-Left)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${liveStatus['crowdIcon']} ${liveStatus['crowd']}",
                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Wait Time (Top-Right)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                                queueWait,
                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold),
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
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${liveStatus['queueOrders']} Orders • ${liveStatus['confidence']} Conf.",
                              style: TextStyle(fontSize: 8.5, color: Colors.grey.shade700, fontWeight: FontWeight.w700),
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
  // BOTTOM NAVIGATION (DISTRICT STYLE: FLOATING DARK DOCK)
  // ------------------------------------------------------------

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFF161820),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 18 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF282B36) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: selected
              ? Border.all(color: Colors.white.withOpacity(0.12), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey.shade400,
              size: 22,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
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