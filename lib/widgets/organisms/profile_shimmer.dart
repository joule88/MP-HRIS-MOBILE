import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/shimmer_widgets.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          const SizedBox(height: 24),

          const ShimmerCircle(size: 100),
          const SizedBox(height: 16),

          const ShimmerBox(height: 20, width: 160),
          const SizedBox(height: 8),
          const ShimmerBox(height: 14, width: 120),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: List.generate(5, (index) => Padding(
                padding: EdgeInsets.only(bottom: index < 4 ? 20 : 0),
                child: Row(
                  children: [
                    const ShimmerCircle(size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(height: 12, width: 80),
                          SizedBox(height: 6),
                          ShimmerBox(height: 16, width: 160),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),

          const SizedBox(height: 24),

          const ShimmerBox(height: 48, borderRadius: 12),
          const SizedBox(height: 12),
          const ShimmerBox(height: 48, borderRadius: 12),
        ],
      ),
    );
  }
}
