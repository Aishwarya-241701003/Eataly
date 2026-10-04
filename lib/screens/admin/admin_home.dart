import 'package:flutter/material.dart';
import '../../models/distribution_station.dart';
import '../../models/food.dart';
import '../../models/order.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../auth/role_selection_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final String adminEmail;
  const AdminHomeScreen({
    super.key,
    this.adminEmail = 'admin@rajalakshmi.edu.in',
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestore = FirestoreService();
  late TabController _tabController;

  bool _isCanteenOpen = true;
  String _selectedStatusFilter = 'All';
  String _selectedStationId = 'st_ablock';
  String _selectedDemandSlotId = 'slot_lunch_1';

  // Local state for stock overrides
  final Map<String, bool> _itemStockOverrides = {};

  final List<Food> _adminMenuItems = [
    Food(
      id: 'm1',
      name: 'Paneer Butter Masala Combo',
      description: 'Served with 2 butter naans, jeera rice and gulab jamun.',
      category: 'Meals',
      price: 120,
      rating: 4.8,
      image: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500',
      available: true,
      isVeg: true,
      isPopular: true,
      isNew: false,
      preparationTime: 15,
    ),
    Food(
      id: 'm2',
      name: 'Farmhouse Veg Pizza',
      description: 'Loaded with capsicum, onion, tomato, and fresh mozzarella.',
      category: 'Pizza',
      price: 160,
      rating: 4.6,
      image: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
      available: true,
      isVeg: true,
      isPopular: true,
      isNew: false,
      preparationTime: 20,
    ),
    Food(
      id: 'm3',
      name: 'Crispy Veg Burger Combo',
      description: 'Crunchy patty with cheese slice and french fries.',
      category: 'Snacks',
      price: 90,
      rating: 4.5,
      image: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
      available: true,
      isVeg: true,
      isPopular: false,
      isNew: true,
      preparationTime: 10,
    ),
    Food(
      id: 'm4',
      name: 'Cold Coffee with Ice Cream',
      description: 'Thick creamy blended cold coffee topped with vanilla ice cream.',
      category: 'Drinks',
      price: 65,
      rating: 4.9,
      image: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500',
      available: true,
      isVeg: true,
      isPopular: true,
      isNew: false,
      preparationTime: 5,
    ),
    Food(
      id: 'm5',
      name: 'Chocolate Lava Cake',
      description: 'Warm chocolate cake with molten chocolate center.',
      category: 'Desserts',
      price: 75,
      rating: 4.7,
      image: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500',
      available: false,
      isVeg: true,
      isPopular: false,
      isNew: true,
      preparationTime: 8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _firestore.addListener(_handleStateChange);
  }

  @override
  void dispose() {
    _firestore.removeListener(_handleStateChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) setState(() {});
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge)),
        title: const Text('Exit Admin Portal',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            'Are you sure you want to log out of the canteen staff session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    _firestore.updateOrderStatus(orderId, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #$orderId updated to: ${newStatus.name.toUpperCase()}'),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHighDemandBroadcastDialog() {
    final textController = TextEditingController(text: _firestore.highDemandAlert);

    final presets = [
      'High rush at Rec Cafe & Food Court (~25m wait). Pick up at common Station Beta or check Heatmap!',
      'CRITICAL LUNCH RUSH: Multi-canteen orders are consolidating at Station Alpha (Library Annex).',
      'Kitchen at maximum capacity: Orders placed now have +15 mins preparation delay.',
      'Evening refreshment rush: Beverages and snacks are ready at Station Gamma (SAC).',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 26),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Broadcast Demand Alert',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instantly notify students on the Eataly app about queue delays, high rush hour, or distribution hub collections.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Quick Presets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...presets.map((p) => InkWell(
                      onTap: () {
                        setDialogState(() {
                          textController.text = p;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          p,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textPrimary),
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                const Text(
                  'Alert Message:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (_firestore.isHighDemandActive)
              TextButton(
                onPressed: () {
                  _firestore.toggleHighDemand(false);
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('High demand rush alert deactivated.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Turn Off Alert',
                    style: TextStyle(color: AppColors.danger)),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _firestore.toggleHighDemand(true,
                    customMessage: textController.text);
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('High Demand Alert broadcasted to student app!'),
                    backgroundColor: AppColors.danger,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Broadcast Alert'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const adminBlue = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: adminBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: adminBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Eataly Staff Admin',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.adminEmail,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Quick Broadcast Alert action
          IconButton(
            tooltip: 'Broadcast High Demand Alert',
            icon: Icon(
              _firestore.isHighDemandActive
                  ? Icons.campaign_rounded
                  : Icons.campaign_outlined,
              color: _firestore.isHighDemandActive
                  ? AppColors.danger
                  : adminBlue,
            ),
            onPressed: _showHighDemandBroadcastDialog,
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            onPressed: _handleLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: adminBlue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: adminBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Live Orders'),
            Tab(icon: Icon(Icons.hub_rounded, size: 18), text: 'Distribution Hubs'),
            Tab(icon: Icon(Icons.trending_up_rounded, size: 18), text: 'Expected Demand'),
            Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 18), text: 'Menu Stock'),
            Tab(icon: Icon(Icons.analytics_outlined, size: 18), text: 'Operations & Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(),
          _buildDistributionCountersTab(),
          _buildExpectedDemandTab(),
          _buildMenuStockTab(),
          _buildOperationsTab(),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 1: LIVE ORDERS WITH HIGH DEMAND ALERT BANNER
  // ----------------------------------------------------
  Widget _buildOrdersTab() {
    final activeOrders = _firestore.orders;
    final filteredOrders = _selectedStatusFilter == 'All'
        ? activeOrders
        : activeOrders
            .where((o) =>
                o.status.name.toLowerCase() ==
                _selectedStatusFilter.toLowerCase())
            .toList();

    return Column(
      children: [
        // High Demand Alert Banner
        _buildHighDemandSurgeBanner(),

        // Status filter chips
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Pending',
                'Preparing',
                'Ready',
                'Completed',
              ].map((status) {
                final isSelected = _selectedStatusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatusFilter = status;
                      });
                    },
                    selectedColor: const Color(0xFF1E3A8A),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12.5,
                    ),
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Orders list
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        'No $_selectedStatusFilter orders found',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHighDemandSurgeBanner() {
    final isSurge = _firestore.isHighDemandActive;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSurge
            ? AppColors.danger.withValues(alpha: 0.1)
            : const Color(0xFF1E3A8A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isSurge
              ? AppColors.danger.withValues(alpha: 0.4)
              : const Color(0xFF1E3A8A).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSurge ? Icons.warning_rounded : Icons.info_outline_rounded,
            color: isSurge ? AppColors.danger : const Color(0xFF1E3A8A),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSurge
                      ? '⚠️ HIGH DEMAND SURGE IN EFFECT'
                      : 'Campus Demand Status: Normal',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isSurge ? AppColors.danger : const Color(0xFF1E3A8A),
                  ),
                ),
                Text(
                  isSurge
                      ? _firestore.highDemandAlert
                      : 'Kitchen running at optimum rate. Multi-canteen orders routing smoothly.',
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _showHighDemandBroadcastDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSurge ? AppColors.danger : const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isSurge ? 'Edit Alert' : 'Inform Rush'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        break;
      case OrderStatus.preparing:
        statusColor = Colors.orange;
        break;
      case OrderStatus.ready:
        statusColor = AppColors.success;
        break;
      case OrderStatus.completed:
        statusColor = const Color(0xFF1E3A8A);
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.danger;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.orderId}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Token: ${order.tokenNumber}',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Slot: ${order.pickupSlot}',
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '₹${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          Column(
            children: order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x  ${item.food.name}',
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (order.status == OrderStatus.pending)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _updateOrderStatus(order.orderId, OrderStatus.preparing),
                    icon: const Icon(Icons.soup_kitchen_rounded, size: 16),
                    label: const Text('Start Preparing'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (order.status == OrderStatus.preparing)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _updateOrderStatus(order.orderId, OrderStatus.ready),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Mark Ready for Pickup'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (order.status == OrderStatus.ready)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _updateOrderStatus(order.orderId, OrderStatus.completed),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark Handed Over'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 2: CENTRAL FOOD DISTRIBUTION COUNTERS
  // Multi-canteen orders gathered at high-traffic common campus spots
  // ----------------------------------------------------
  Widget _buildDistributionCountersTab() {
    final stations = _firestore.distributionStations;
    final selectedStation = stations.firstWhere(
      (s) => s.id == _selectedStationId,
      orElse: () => stations.first,
    );

    final ordersForStation = _firestore.consolidatedOrders
        .where((o) => o.stationId == selectedStation.id)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner explaining Multi-Canteen Campus Distribution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.hub_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campus Food Distribution Hubs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Multi-canteen items are consolidated and transported by runners to central common stations. Students collect all dishes from their assigned Counter Bay!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Station Selector Chips
          const Text(
            'Select Campus Distribution Station:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 82,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final st = stations[index];
                final isSelected = st.id == _selectedStationId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStationId = st.id;
                    });
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? st.themeColor : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? st.themeColor : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: st.themeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              st.code,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white70 : st.themeColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : st.themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${st.occupiedBays}/${st.totalBays} Bays',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : st.themeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          st.name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          st.location,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Station Details Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.place_rounded, color: selectedStation.themeColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${selectedStation.name} • ${selectedStation.location}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Landmark: ${selectedStation.landmark}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStationMetric('Occupied Bays',
                        '${selectedStation.occupiedBays}/${selectedStation.totalBays}'),
                    _buildStationMetric('Queue Load', selectedStation.queueStatus),
                    _buildStationMetric('Active Runners',
                        '${selectedStation.activeRunners} en route'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Section Title: Multi-Canteen Orders for this station
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Orders at ${selectedStation.code} (${ordersForStation.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Pick up at assigned bay',
                style: TextStyle(
                    fontSize: 11.5,
                    color: selectedStation.themeColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (ordersForStation.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: const Text(
                'No orders currently pending at this station.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ...ordersForStation.map((order) => _buildConsolidatedOrderCard(order)),
        ],
      ),
    );
  }

  Widget _buildStationMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildConsolidatedOrderCard(ConsolidatedOrder order) {
    final isReady = order.isAllItemsAtCounter;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: order.isHandedOver
              ? Colors.grey.shade300
              : (isReady ? AppColors.success : const Color(0xFF1E3A8A).withValues(alpha: 0.3)),
          width: isReady && !order.isHandedOver ? 1.8 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.bayNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.tokenNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isHandedOver
                      ? Colors.grey.shade200
                      : (isReady
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.consolidationStatus,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: order.isHandedOver
                        ? Colors.grey.shade700
                        : (isReady ? AppColors.success : AppColors.warning),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Student Info
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${order.studentName} (${order.studentRoll})',
                style: const TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                'Slot: ${order.pickupSlot}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar for item consolidation
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: order.consolidationProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isReady ? AppColors.success : const Color(0xFF1E3A8A),
              ),
              minHeight: 5,
            ),
          ),

          const SizedBox(height: 12),

          // Multi-canteen Item List
          const Text(
            'Multi-Canteen Food Checklist:',
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),

          ...order.items.map((item) {
            Color itemColor;
            IconData itemIcon;
            if (item.isAtCounter) {
              itemColor = AppColors.success;
              itemIcon = Icons.check_circle_rounded;
            } else if (item.isInTransit) {
              itemColor = const Color(0xFF2563EB);
              itemIcon = Icons.delivery_dining_rounded;
            } else {
              itemColor = AppColors.warning;
              itemIcon = Icons.soup_kitchen_rounded;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(itemIcon, size: 16, color: itemColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}x ${item.foodName}',
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'from ${item.canteenName}${item.runnerName != null ? ' • ${item.runnerName}' : ''}',
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isAtCounter && !order.isHandedOver)
                    TextButton(
                      onPressed: () {
                        _firestore.updateConsolidatedItemStatus(
                          order.orderId,
                          item.foodName,
                          'Arrived at Counter Bay',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${item.foodName} marked as Arrived at ${order.bayNumber}!'),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Mark Arrived',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    )
                  else
                    Text(
                      item.status,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: itemColor),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          // Handover action button
          if (!order.isHandedOver)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {
                  _firestore.markConsolidatedOrderHandedOver(order.orderId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Token #${order.tokenNumber} handed over to ${order.studentName}!'),
                      backgroundColor: const Color(0xFF1E3A8A),
                    ),
                  );
                },
                icon: const Icon(Icons.handshake_rounded, size: 16),
                label: Text(
                  isReady ? 'Hand Over Order to Student' : 'Force Hand Over',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isReady ? const Color(0xFF1E3A8A) : Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 3: EXPECTED ORDERING & PEAK DEMAND FORECAST
  // ----------------------------------------------------
  Widget _buildExpectedDemandTab() {
    final demandSlots = _firestore.demandSlots;
    final selectedSlot = demandSlots.firstWhere(
      (s) => s.id == _selectedDemandSlotId,
      orElse: () => demandSlots.first,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'College Rush Forecast & Prep',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Anticipate student rush during morning breaks & lunch hours. Prepare kitchen batches in advance to eliminate queue bottlenecks.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Slot Picker Chips
          const Text(
            'Select College Break Rush Period:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: demandSlots.map((slot) {
                final isSelected = slot.id == _selectedDemandSlotId;
                final isSurge = slot.rushLevel.contains('CRITICAL');

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDemandSlotId = slot.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E3A8A)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E3A8A)
                            : (isSurge ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border),
                        width: isSelected || isSurge ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              slot.title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (isSurge) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'PEAK',
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${slot.timeRange} • ~${slot.expectedOrderCount} orders (${slot.rushMultiplier}x)',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Selected Slot Overview Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedSlot.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedSlot.rushLevel.contains('CRITICAL')
                            ? AppColors.danger.withValues(alpha: 0.12)
                            : AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selectedSlot.rushLevel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: selectedSlot.rushLevel.contains('CRITICAL')
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  selectedSlot.kitchenAdvisory,
                  style: const TextStyle(
                      fontSize: 12.5, color: Color(0xFF334155), height: 1.35),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildMetric('Expected Orders', '${selectedSlot.expectedOrderCount}'),
                    _buildMetric('Advance Pre-Orders', '${selectedSlot.currentPreOrders}'),
                    _buildMetric('Batch Prep Progress',
                        '${(selectedSlot.overallPrepPercentage * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: selectedSlot.overallPrepPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      selectedSlot.overallPrepPercentage >= 0.8
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 14),
                // One-tap trigger surge alert for this slot
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _firestore.triggerRushAlertForSlot(selectedSlot.id, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'High Demand Alert triggered for ${selectedSlot.title}! Students notified.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    },
                    icon: const Icon(Icons.campaign_rounded, size: 16),
                    label: const Text('Inform Students of this Rush Window'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Dish Batch Prep List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Prep Dish Breakdown',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${selectedSlot.dishes.length} High Demand Dishes',
                style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...selectedSlot.dishes.map((dish) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dish.dishName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${dish.canteenName} • ${dish.category} (Advance orders: ${dish.preOrdersPlaced})',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () {
                              _firestore.updateDishPrepQuantity(
                                  selectedSlot.id, dish.dishName, -5);
                            },
                          ),
                          Text(
                            '${dish.preppedQuantity}/${dish.forecastedQuantity}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: dish.isPrepComplete
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1E3A8A)),
                            onPressed: () {
                              _firestore.updateDishPrepQuantity(
                                  selectedSlot.id, dish.dishName, 5);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: dish.prepProgress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        dish.isPrepComplete
                            ? AppColors.success
                            : const Color(0xFF1E3A8A),
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // TAB 4: MENU & STOCK MANAGEMENT
  // ----------------------------------------------------
  Widget _buildMenuStockTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      itemCount: _adminMenuItems.length,
      itemBuilder: (context, index) {
        final item = _adminMenuItems[index];
        final isAvailable = _itemStockOverrides[item.id] ?? item.available;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.image,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    width: 55,
                    height: 55,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${item.price.toStringAsFixed(0)} • ${item.category}',
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: isAvailable,
                    activeThumbColor: const Color(0xFF1E3A8A),
                    onChanged: (val) {
                      setState(() {
                        _itemStockOverrides[item.id] = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.name} marked as ${val ? "Available" : "Sold Out"}',
                          ),
                          backgroundColor:
                              val ? AppColors.success : AppColors.danger,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  Text(
                    isAvailable ? 'In Stock' : 'Sold Out',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------------------
  // TAB 5: CANTEEN OPERATIONS & HIGH DEMAND ALERTS
  // ----------------------------------------------------
  Widget _buildOperationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // High Demand Surge Controller Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _firestore.isHighDemandActive
                  ? AppColors.danger.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: _firestore.isHighDemandActive
                    ? AppColors.danger.withValues(alpha: 0.4)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: _firestore.isHighDemandActive
                          ? AppColors.danger
                          : AppColors.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Campus High Demand Surge',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _firestore.isHighDemandActive
                                ? 'Surge notice currently broadcasted to students.'
                                : 'Trigger surge warning when orders exceed capacity.',
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _firestore.isHighDemandActive,
                      activeThumbColor: AppColors.danger,
                      onChanged: (val) {
                        _firestore.toggleHighDemand(val);
                      },
                    ),
                  ],
                ),
                if (_firestore.isHighDemandActive) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Live Broadcast: "${_firestore.highDemandAlert}"',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showHighDemandBroadcastDialog,
                    icon: const Icon(Icons.campaign_rounded, size: 16),
                    label: const Text('Broadcast / Edit Rush Announcement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Canteen Status Switch Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isCanteenOpen
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.danger.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isCanteenOpen
                        ? Icons.store_rounded
                        : Icons.store_mall_directory_outlined,
                    color: _isCanteenOpen ? AppColors.success : AppColors.danger,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCanteenOpen ? 'Canteen Open' : 'Canteen Closed',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _isCanteenOpen
                            ? 'Students can browse & place orders.'
                            : 'Order placing is temporarily paused.',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isCanteenOpen,
                  activeThumbColor: AppColors.success,
                  onChanged: (val) {
                    setState(() {
                      _isCanteenOpen = val;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Overview KPI Grid
          const Text(
            'Today\'s Summary',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              _buildKpiCard('Total Orders', '28', Icons.receipt_rounded,
                  AppColors.primary),
              const SizedBox(width: 12),
              _buildKpiCard('Revenue', '₹ 3,420',
                  Icons.currency_rupee_rounded, AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildKpiCard(
                  'Queue Rush',
                  _firestore.isHighDemandActive ? 'HIGH SURGE' : 'Normal',
                  Icons.people_alt_rounded,
                  _firestore.isHighDemandActive
                      ? AppColors.danger
                      : AppColors.warning),
              const SizedBox(width: 12),
              _buildKpiCard('Hub Stations', '4 Active', Icons.hub_rounded,
                  const Color(0xFF1E3A8A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
