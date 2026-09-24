import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(
              AppConstants.radiusLarge,
            ),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppColors.primary.withOpacity(.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
