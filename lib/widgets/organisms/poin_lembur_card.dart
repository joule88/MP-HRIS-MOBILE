import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PoinLemburCard extends StatelessWidget {
  final int poin;
  final VoidCallback onGunakan;

  const PoinLemburCard({
    Key? key,
    required this.poin,
    required this.onGunakan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryOrange, const Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.glowOrange,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.stars_rounded,
              size: 140,
              color: AppTheme.glassWhite20,
            ),
          ),
          Positioned(
            top: -40,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glassWhite10,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Poin Lembur",
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.glassWhite70),
                    ),
                    Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$poin",
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.0,
                    ),
                    maxLines: 1,
                  ),
                ),

                const SizedBox(height: 12),

                InkWell(
                  onTap: onGunakan,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  child: Container(
                    height: 36,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.glassWhite20,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(color: AppTheme.glassWhite50, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "Gunakan Poin",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
