import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/firestore_service.dart';
import '../../services/offline_sync_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final String? notes;
  final double discount;

  const CheckoutScreen({
    super.key,
    this.notes,
    this.discount = 0.0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService _service = FirestoreService();

  String _selectedSlot = AppConstants.pickupSlots.first;
  String _selectedPaymentMethod = "Campus Card";
  bool _isPlacingOrder = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Campus Card',
      'title': 'REC Campus ID Wallet',
      'subtitle': 'Balance: ₹450 (Instant 1-Tap Pay)',
      'icon': Icons.credit_card_rounded,
      'color': Colors.blue,
    },
    {
      'id': 'UPI',
      'title': 'UPI / GPay / PhonePe',
      'subtitle': 'Scan & Pay or UPI Intent',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Colors.deepPurple,
    },
    {
      'id': 'Cash',
      'title': 'Pay at Counter on Pickup',
      'subtitle': 'Cash or card at express counter',
      'icon': Icons.payments_outlined,
      'color': Colors.teal,
    },
  ];

  Future<void> _handlePlaceOrder() async {
    setState(() {
      _isPlacingOrder = true;
    });

    // Simulate network latency / order confirmation
    await Future.delayed(const Duration(milliseconds: 900));

    final newOrder = _service.placeOrder(
      pickupSlot: _selectedSlot,
      paymentMethod: _selectedPaymentMethod,
      notes: widget.notes,
    );

    if (!mounted) return;
    setState(() {
      _isPlacingOrder = false;
    });

    _showOrderSuccessDialog(newOrder);
  }

  void _showConflictResolutionSheet(String fullSlot) {
    final syncService = OfflineSyncService();
    final alternateSlot = syncService.suggestAlternateSlot(fullSlot);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(22),
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
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.danger, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Slot Conflict Detected",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "20 students have already booked this slot",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.amber.shade900, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Smart Conflict Resolution Suggestion",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "To prevent kiosk crowding and wait times, system recommends automatic rescheduling or switching to an alternate canteen:",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 12),
                  // Option A: Alternate Slot
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSlot = alternateSlot;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Rescheduled to $alternateSlot (Fastest pickup!)"),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Option 1: Switch to $alternateSlot",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        "⚡ RECOMMENDED",
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Queue: 2 Orders • Ready in ~3 mins",
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Option B: Alternate Canteen
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.storefront_rounded, color: Colors.deepOrange, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Option 2: REC Hut Cafe (Same items)",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Immediate 12:30 PM slot open • 4 mins walk",
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedSlot = fullSlot;
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      "Keep 12:30 PM (Expect Wait)",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedSlot = alternateSlot;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Rescheduled to $alternateSlot!"),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      "Accept $alternateSlot",
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderSuccessDialog(Order order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 45,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "Order Placed!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Your order is recorded in the kitchen queue. Skip the counter rush with your live digital token.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            // Digital Token Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "DIGITAL PICKUP TOKEN",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.tokenNumber,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alarm, size: 16, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      Text(
                        "Slot: ${order.pickupSlot}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Text(
                          "${order.queueAhead} Orders Ahead",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          "Ready in ~${order.estimatedReadyMins} mins",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Sync status pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: order.isSynced ? AppColors.success.withOpacity(0.1) : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.isSynced ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                    size: 14,
                    color: order.isSynced ? AppColors.success : Colors.orange.shade800,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    order.isSynced ? "✔ Synced with Kitchen Database" : "Saved Offline • Syncing in background",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: order.isSynced ? AppColors.success : Colors.orange.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  // Navigate to Orders screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrdersScreen(showBackButton: true),
                    ),
                  );
                },
                child: const Text(
                  "Track in My Orders",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _service.cart;
    final itemTotal = _service.cartTotal;
    final finalTotal = (itemTotal - widget.discount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Checkout & Pickup Slot",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Aishwarya B",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Roll No: 241701003 • Dept: CSD",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Rajalakshmi Engineering College",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "VERIFIED",
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Select Pickup Slot Section (Design Thinking Core Feature)
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Choose Pickup Slot",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  "Skip kiosk queues",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Select when you plan to collect your food at the canteen counter:",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),

            // Slots Grid
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppConstants.pickupSlots.map((slot) {
                final isSelected = _selectedSlot == slot;
                final syncService = OfflineSyncService();
                final isFull = syncService.isSlotFull(slot);
                final orders = syncService.getSlotOrders(slot);

                return InkWell(
                  onTap: () {
                    if (isFull) {
                      _showConflictResolutionSheet(slot);
                    } else {
                      setState(() {
                        _selectedSlot = slot;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isFull ? Colors.red.shade50 : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isFull ? Colors.red.shade200 : Colors.grey.shade300),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isFull ? Colors.red.shade700 : Colors.grey.shade600),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              slot,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : (isFull ? Colors.red.shade900 : AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : (isFull ? Colors.red.shade100 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isFull
                                ? "FULL (20/20)"
                                : (slot == '12:45 PM' ? "⚡ FASTEST ($orders/20)" : "$orders/20 Booked"),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isFull ? Colors.red.shade900 : AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Pickup Location Notice
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Express Pre-Order Counter Pickup",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Collect food at your chosen slot ($_selectedSlot) by showing your digital token number on screen.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Payment Methods
            const Text(
              "Select Payment Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._paymentMethods.map((pm) {
              final isSelected = _selectedPaymentMethod == pm['id'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = pm['id'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade200,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (pm['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(pm['icon'] as IconData, color: pm['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pm['title'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pm['subtitle'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Order summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Items (${cartItems.length})", style: TextStyle(color: Colors.grey.shade700)),
                      Text("₹${itemTotal.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (widget.discount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Discount applied", style: TextStyle(color: AppColors.success)),
                        Text("-₹${widget.discount.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                      ],
                    ),
                  ],
                  if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Note: ", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        Expanded(
                          child: Text(
                            widget.notes!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Payable",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        "₹${finalTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          child: CustomButton(
            text: "Place Order • Slot $_selectedSlot",
            icon: Icons.lock_outline_rounded,
            isLoading: _isPlacingOrder,
            onPressed: cartItems.isEmpty ? null : _handlePlaceOrder,
          ),
        ),
      ),
    );
  }
}
