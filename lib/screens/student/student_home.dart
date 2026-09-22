import 'package:flutter/material.dart';
import 'canteen_menu.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int selectedIndex = 0;

  final Color red = const Color(0xFFB3261E);
  final Color cream = const Color(0xFFF8F3EA);
  final Color dark = const Color(0xFF242424);

  final List<Map<String, dynamic>> canteens = [
    {
      'name': 'Rec Cafe',
      'image':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
    },
    {
      'name': 'Hut Cafe',
      'image':
          'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?w=800',
    },
    {
      'name': 'Yippe',
      'image':
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800',
    },
    {
      'name': 'Hotspot',
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800',
    },
    {
      'name': 'Wokon',
      'image':
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800',
    },
    {
      'name': 'Cafe Coffee Day',
      'image':
          'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=800',
    },
    {
      'name': '6Sense',
      'image':
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800',
    },
  ];

  final List<Map<String, dynamic>> foods = [
    {
      'name': 'Chicken Burger',
      'canteen': 'Rec Cafe',
      'price': '₹129',
      'rating': '4.8',
      'image':
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=900',
    },
    {
      'name': 'Paneer Pizza',
      'canteen': 'Hotspot',
      'price': '₹149',
      'rating': '4.7',
      'image':
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=900',
    },
    {
      'name': 'Veg Noodles',
      'canteen': 'Wokon',
      'price': '₹99',
      'rating': '4.6',
      'image':
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=900',
    },
    {
      'name': 'Cold Coffee',
      'canteen': 'Cafe Coffee Day',
      'price': '₹89',
      'rating': '4.5',
      'image':
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=900',
    },
  ];

  void openCanteen(String canteenName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CanteenMenu(
          canteenName: canteenName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _buildHome(),
            _buildOrdersPlaceholder(),
            _buildProfilePlaceholder(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ------------------------------------------------------------
  // HOME
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

          const SizedBox(height: 28),

          _buildOfferBanner(),

          const SizedBox(height: 32),

          _sectionTitle(
            'Choose your canteen',
            'Order from your favourite spot',
          ),

          const SizedBox(height: 16),

          _buildCanteens(),

          const SizedBox(height: 34),

          _sectionTitle(
            'Featured today',
            'Popular picks around campus',
          ),

          const SizedBox(height: 18),

          _buildFoodList(),

          const SizedBox(height: 34),

          _sectionTitle(
            'Near to your heart',
            'Your frequently ordered favourites',
          ),

          const SizedBox(height: 18),

          _buildFavouriteCard(),

          const SizedBox(height: 30),
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
                Text(
                  'Good afternoon 👋',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Aishwarya',
                  style: TextStyle(
                    color: dark,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),

          Container(
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
            child: Icon(
              Icons.notifications_none_rounded,
              color: dark,
              size: 25,
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 25,
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
      child: Container(
        height: 58,
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
              size: 25,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'What are you craving today?',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(7),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // OFFER
  // ------------------------------------------------------------

  Widget _buildOfferBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 165,
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(28),
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
                            'TODAY ONLY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hungry?\nWe got you.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Special offers across campus',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 95,
                    child: Icon(
                      Icons.fastfood_rounded,
                      color: Colors.white,
                      size: 82,
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
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _sectionTitle(String title, String subtitle) {
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
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
          Text(
            'See all',
            style: TextStyle(
              color: red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
    return SizedBox(
      height: 155,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: canteens.length,
        itemBuilder: (context, index) {
          final canteen = canteens[index];

          return GestureDetector(
            onTap: () => openCanteen(canteen['name']),
            child: Container(
              width: 125,
              margin: const EdgeInsets.only(right: 13),
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          canteen['name'],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: dark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];

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
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      child: Image.network(
                        food['image'],
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
                              food['rating'],
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
                      bottom: -20,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${food['name']} added to cart',
                              ),
                              backgroundColor: red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: red.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 17, 14, 0),
                  child: Text(
                    food['name'],
                    style: TextStyle(
                      color: dark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 0),
                  child: Text(
                    food['canteen'],
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Text(
                    food['price'],
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
  // FAVOURITE
  // ------------------------------------------------------------

  Widget _buildFavouriteCard() {
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
                'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600',
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
                    const Text(
                      'Classic Chicken Roll',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '₹109',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 19,
                          ),
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
  // ORDERS
  // ------------------------------------------------------------

  Widget _buildOrdersPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 65,
            color: red,
          ),
          const SizedBox(height: 18),
          Text(
            'My Orders',
            style: TextStyle(
              color: dark,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your orders will appear here.',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE
  // ------------------------------------------------------------

  Widget _buildProfilePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Aishwarya',
            style: TextStyle(
              color: dark,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Student Profile',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
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
    final bool selected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
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