import 'package:flutter/material.dart';
import '../models/food.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

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
          borderRadius:
              BorderRadius.circular(AppConstants.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(
                        AppConstants.radiusLarge),
                  ),
                  child: Image.network(
                    food.image,
                    height: 185,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                      height: 185,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.fastfood,
                        size: 55,
                      ),
                    ),
                  ),
                ),

                // Rating
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.star,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          food.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favourite
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: onFavourite,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        isFavourite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),

                // Popular
                if (food.isPopular)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "POPULAR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // NEW
                if (food.isNew)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    food.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: food.isVeg
                            ? AppColors.veg
                            : AppColors.nonVeg,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        food.isVeg
                            ? "Veg"
                            : "Non-Veg",
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${food.preparationTime} mins",
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        "₹${food.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                          ),
                          child: const Text(
                            "Out of Stock",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                                  FontWeight.bold,
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
}

class _InteractiveAddStepper extends StatefulWidget {
  final int count;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  const _InteractiveAddStepper({
    required this.count,
    required this.onAdd,
    this.onRemove,
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
    if (widget.count == 0) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          onPressed: () => _triggerBounce(widget.onAdd),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text(
            "Add",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onRemove != null
                    ? () => _triggerBounce(widget.onRemove!)
                    : null,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(Icons.remove, size: 16, color: Colors.white),
                ),
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
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _triggerBounce(widget.onAdd),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
