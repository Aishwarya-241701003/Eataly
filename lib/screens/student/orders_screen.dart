import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'cart_screen.dart';

class OrdersScreen extends StatefulWidget {
  final bool showBackButton;

  const OrdersScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _service = FirestoreService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<Order> get _activeOrders {
    return _service.orders
        .where((o) =>
            o.status == OrderStatus.pending ||
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.ready)
        .toList();
  }

  List<Order> get _pastOrders {
    return _service.orders
        .where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.cancelled)
        .toList();
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return AppColors.success;
      case OrderStatus.completed:
        return Colors.grey.shade700;
      case OrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "My Orders",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Active"),
                  if (_activeOrders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_activeOrders.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: "Past Orders"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(_activeOrders, isActive: true),
          _buildOrdersList(_pastOrders, isActive: false),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.fastfood_outlined : Icons.receipt_long_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? "No Active Orders" : "No Past Orders",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isActive
                    ? "Place a pre-order from any campus canteen to see live progress and token status here."
                    : "Completed orders will be saved here so you can reorder with a single tap.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order, isActive: isActive);
      },
    );
  }

  Widget _buildOrderCard(Order order, {required bool isActive}) {
    final statusColor = _getStatusColor(order.status);
    final statusText = order.trackingStageLabel;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Token Header with Canteen & Live Queue info
          Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "DIGITAL TOKEN",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sync Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: order.isSynced
                                ? AppColors.success.withOpacity(0.12)
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                order.isSynced ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                                size: 10,
                                color: order.isSynced ? AppColors.success : Colors.orange.shade900,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                order.isSynced ? "✔ Synced" : "Saved Offline",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: order.isSynced ? AppColors.success : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.tokenNumber,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      order.canteenName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isActive && order.trackingStep < 3) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${order.queueAhead} Ahead",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "~${order.estimatedReadyMins}m",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slot Info & Order ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm, size: 16, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          "Pickup Slot: ${order.pickupSlot}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.orderId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Note: ${order.notes}",
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 5-Step Swiggy/Zepto Tracking Timeline (if active)
                if (isActive) ...[
                  _buildFiveStepTrackingTimeline(order),
                  const SizedBox(height: 14),
                ],

                const Divider(),
                const SizedBox(height: 8),

                // Ordered Items
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: item.food.isVeg ? AppColors.veg : AppColors.nonVeg,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${item.food.name}  x${item.quantity}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            "₹${item.totalPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 10),
                const Divider(),

                // Total and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Paid",
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        Text(
                          "₹${order.totalAmount.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    if (isActive)
                      Row(
                        children: [
                          // Pre-ordering modification before cooking
                          if (order.canModify) ...[
                            OutlinedButton.icon(
                              icon: const Icon(Icons.edit_calendar_rounded, size: 14),
                              label: const Text("Modify"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                side: const BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _showModifyOrderModal(order),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                foregroundColor: AppColors.danger,
                                side: const BorderSide(color: AppColors.danger),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _confirmCancelOrder(order.orderId),
                              child: const Text("Cancel"),
                            ),
                          ] else if (order.trackingStep >= 3) ...[
                            ElevatedButton.icon(
                              icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                              label: const Text("Show Token"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _showTokenModal(order),
                            ),
                          ] else ...[
                            OutlinedButton.icon(
                              icon: const Icon(Icons.fast_forward_rounded, size: 14),
                              label: const Text("Simulate"),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => _service.advanceOrderTracking(order.orderId),
                            ),
                          ],
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        label: const Text("Reorder"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _service.reorder(order);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Items added to cart!"),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()),
                          );
                        },
                      ),
                  ],
                ),

                // Simulation Helper for testing kitchen progress
                if (isActive && order.trackingStep < 4) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _service.advanceOrderTracking(order.orderId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.touch_app_outlined, size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            "Simulate Kitchen Advance ➔",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // 5-STEP SWIGGY / ZEPTO LIVE ORDER TRACKING
  // Accepted ➔ Cooking ➔ Packaging ➔ Ready ➔ Collected
  // -------------------------------------------------------------
  Widget _buildFiveStepTrackingTimeline(Order order) {
    final currentStep = order.trackingStep;
    final stages = [
      {'label': 'Accepted', 'icon': Icons.assignment_turned_in_rounded},
      {'label': 'Cooking', 'icon': Icons.soup_kitchen_rounded},
      {'label': 'Packaging', 'icon': Icons.inventory_2_rounded},
      {'label': 'Ready', 'icon': Icons.check_circle_rounded},
      {'label': 'Collected', 'icon': Icons.done_all_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "LIVE KITCHEN TRACKER",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                "Stage ${currentStep + 1} of 5",
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(stages.length, (index) {
              final isPassed = index <= currentStep;
              final isCurrent = index == currentStep;
              final stage = stages[index];

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? (isCurrent ? AppColors.primary : AppColors.success)
                                  : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (isCurrent)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Icon(
                              isPassed && !isCurrent
                                  ? Icons.check
                                  : (stage['icon'] as IconData),
                              size: 14,
                              color: isPassed ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stage['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                              color: isCurrent
                                  ? AppColors.primary
                                  : (isPassed ? AppColors.textPrimary : Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index < stages.length - 1)
                      Container(
                        width: 8,
                        height: 2.5,
                        color: index < currentStep ? AppColors.success : Colors.grey.shade300,
                        margin: const EdgeInsets.only(bottom: 14),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // PRE-ORDER MODIFICATION MODAL (BEFORE COOKING)
  // -------------------------------------------------------------
  void _showModifyOrderModal(Order order) {
    String tempSlot = order.pickupSlot;
    final noteController = TextEditingController(text: order.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "Modify Order Before Cooking",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Orders can be freely rescheduled and updated before the kitchen starts cooking.",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text(
                "Select New Pickup Slot:",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.pickupSlots.map((slot) {
                  final isSelected = tempSlot == slot;
                  return InkWell(
                    onTap: () {
                      setModalState(() {
                        tempSlot = slot;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                "Kitchen Preparation Notes:",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "e.g. Less spicy, pack extra tissue",
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _service.modifyOrderSlot(order.orderId, tempSlot);
                    if (noteController.text.isNotEmpty) {
                      _service.modifyOrderNotes(order.orderId, noteController.text);
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Order modified to slot $tempSlot!"),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text("Save Modifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTokenModal(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            const Text(
              "Express Pickup Token",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Text(
              order.tokenNumber,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Pickup Slot: ${order.pickupSlot}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 90,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Present this screen at the canteen pickup counter to collect your food instantly without waiting in line.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmCancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Cancel Order?"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              _service.cancelOrder(orderId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Order has been cancelled."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
