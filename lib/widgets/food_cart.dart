import 'package:flutter/material.dart';
import '../models/food.dart';
import '../utils/colors.dart';

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final int cartQuantity;
  final VoidCallback? onTap;
  final VoidCallback? onFavourite;
  final bool isFavourite;

  const FoodCard({
    super.key,
    required this.food,
    required this.onAdd,
    this.onRemove,
    this.cartQuantity = 0,
    this.onTap,
    this.onFavourite,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE with bookmark & badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    food.image,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                    ),
                  ),
                ),

                // Top Bookmark / Favorite Button (District Style)
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(
                        isFavourite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isFavourite ? AppColors.primary : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Prep time pill (District style)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "${food.preparationTime} mins",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row (Theobroma / Zepto Style from Image 3)
                  Row(
                    children: [
                      // Veg / Non-Veg Icon
                      _buildDietBadge(food.isVeg),
                      const SizedBox(width: 8),

                      // Bestseller / Popular tag
                      if (food.isPopular || food.isTrending) ...[
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 13, color: Colors.red.shade700),
                            const SizedBox(width: 2),
                            Text(
                              "Bestseller",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Soft Mint Green Rating Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFC8E6C9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFF2E7D32), size: 13),
                            const SizedBox(width: 2),
                            Text(
                              "${food.rating} (${food.salesCount})",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Canteen Tag
                      if (food.canteen != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            food.canteen!,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Food Title
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Live Availability Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: food.remainingCount <= 8 ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: food.remainingCount <= 8 ? const Color(0xFFFDBA74) : const Color(0xFFBBF7D0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          food.remainingCount <= 8
                              ? Icons.local_fire_department_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 13,
                          color: food.remainingCount <= 8 ? const Color(0xFFEA580C) : const Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          food.remainingCount <= 8
                              ? "Selling Fast • Only ${food.remainingCount} Left"
                              : "Remaining: ${food.remainingCount} • ${food.nextBatchTime}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: food.remainingCount <= 8 ? const Color(0xFFC2410C) : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Price & ADD Button Row (Image 3 Catalog Style)
                  Row(
                    children: [
                      Text(
                        "₹${food.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (food.available)
                        _InteractiveAddStepper(
                          count: cartQuantity,
                          onAdd: onAdd,
                          onRemove: onRemove,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Text(
                            "Out of Stock",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
  }

  static Widget _buildDietBadge(bool isVeg) {
    final color = isVeg ? const Color(0xFF16A34A) : const Color(0xFFD32F2F);
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: isVeg ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2-COLUMN CATALOG GRID CARD (IMAGE 3 INSPIRATION)
// -------------------------------------------------------------
class FoodGridCard extends StatelessWidget {
  final Food food;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final int cartQuantity;
  final VoidCallback? onTap;
  final VoidCallback? onFavourite;
  final bool isFavourite;

  const FoodGridCard({
    super.key,
    required this.food,
    required this.onAdd,
    this.onRemove,
    this.cartQuantity = 0,
    this.onTap,
    this.onFavourite,
    this.isFavourite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Bookmark
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 1.15,
                    child: Image.network(
                      food.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.fastfood, size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavourite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isFavourite ? AppColors.primary : Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                if (food.remainingCount <= 8)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Only ${food.remainingCount} left",
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      FoodCard._buildDietBadge(food.isVeg),
                      const SizedBox(width: 4),
                      if (food.isPopular || food.isTrending) ...[
                        Text(
                          "★ Bestseller",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "★ ${food.rating}",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${food.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _InteractiveAddStepper(
                        count: cartQuantity,
                        onAdd: onAdd,
                        onRemove: onRemove,
                        compact: true,
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
  }
}

// -------------------------------------------------------------
// CRISP OUTLINE "ADD" BUTTON & STEPPER (IMAGE 3 STYLE)
// -------------------------------------------------------------
class _InteractiveAddStepper extends StatefulWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;
  final bool compact;

  const _InteractiveAddStepper({
    required this.count,
    required this.onAdd,
    this.onRemove,
    this.compact = false,
  });

  @override
  State<_InteractiveAddStepper> createState() => _InteractiveAddStepperState();
}

class _InteractiveAddStepperState extends State<_InteractiveAddStepper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.88,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _triggerBounce(VoidCallback action) async {
    await _animController.reverse();
    action();
    if (mounted) {
      await _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    if (widget.count == 0) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () => _triggerBounce(widget.onAdd),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: widget.compact ? 32 : 36,
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: green, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: green.withOpacity(0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "ADD",
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: widget.compact ? 32 : 36,
        decoration: BoxDecoration(
          color: green,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: widget.onRemove != null ? () => _triggerBounce(widget.onRemove!) : null,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 10, vertical: 6),
                child: const Icon(Icons.remove, size: 14, color: Colors.white),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Text(
                '${widget.count}',
                key: ValueKey<int>(widget.count),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            InkWell(
              onTap: () => _triggerBounce(widget.onAdd),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.compact ? 8 : 10, vertical: 6),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
