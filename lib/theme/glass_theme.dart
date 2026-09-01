import 'dart:ui';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  VANTARA COLOR PALETTE (Warm Cream + Sage Green)
// ─────────────────────────────────────────────

class VantaraColors {
  // Primary Palette
  static const Color primaryGreen = Color(0xFF4E7A51);
  static const Color darkGreen = Color(0xFF385E3B);
  static const Color lightGreen = Color(0xFFE8F1E7);
  static const Color accentGreen = Color(0xFF5B8C5A);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F5F0);
  static const Color cardWhite = Colors.white;
  static const Color cardCream = Color(0xFFF3EFE0);

  // Text Colors
  static const Color textDark = Color(0xFF2D312E);
  static const Color textSub = Color(0xFF717B72);
  static const Color textBrown = Color(0xFF5D4037);
  static const Color textGrey = Color(0xFF9E9E9E);

  // Border & Divider
  static const Color border = Color(0xFFECE7DE);
  static const Color borderLight = Color(0xFFF0EBE3);

  // Status & Categories (Matching UI Mockup)
  static const Color medicineColor = Color(0xFFE56B6F);
  static const Color medicineBg = Color(0xFFFDE8E9);

  static const Color hydrationColor = Color(0xFF4EA8DE);
  static const Color hydrationBg = Color(0xFFE7F3FB);

  static const Color activityColor = Color(0xFFF4A261);
  static const Color activityBg = Color(0xFFFEF3EA);

  static const Color appointmentColor = Color(0xFF9D4EDD);
  static const Color appointmentBg = Color(0xFFF5ECFD);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
}

// ─────────────────────────────────────────────
//  FLOATING GLASS BOTTOM NAVIGATION BAR
// ─────────────────────────────────────────────

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 18, right: 18, bottom: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D312E).withValues(alpha: 0.09),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFF2D312E).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? VantaraColors.lightGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 240),
                          child: Icon(
                            isSelected
                                ? items[index].activeIcon
                                : items[index].icon,
                            size: 26,
                            color: isSelected
                                ? VantaraColors.primaryGreen
                                : VantaraColors.textGrey,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            items[index].label,
                            style: const TextStyle(
                              color: VantaraColors.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
