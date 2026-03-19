import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/shimmer_widgets.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.spacingSm),

          Row(
            children: [
              const ShimmerCircle(size: 52),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 14, width: 120),
                    SizedBox(height: 8),
                    ShimmerBox(height: 20, width: 180),
                    SizedBox(height: 6),
                    ShimmerBox(height: 12, width: 140),
                  ],
                ),
              ),
              const ShimmerCircle(size: 40),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Row(
              children: [
                const ShimmerCircle(size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(height: 12, width: 100),
                      SizedBox(height: 8),
                      ShimmerBox(height: 24, width: 80),
                    ],
                  ),
                ),
                const ShimmerBox(height: 36, width: 90, borderRadius: 20),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    ShimmerBox(height: 16, width: 120),
                    ShimmerBox(height: 24, width: 70, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Column(
                          children: const [
                            ShimmerBox(height: 12, width: 60),
                            SizedBox(height: 8),
                            ShimmerBox(height: 20, width: 50),
                            SizedBox(height: 6),
                            ShimmerBox(height: 10, width: 80),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCard,
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Column(
                          children: const [
                            ShimmerBox(height: 12, width: 60),
                            SizedBox(height: 8),
                            ShimmerBox(height: 20, width: 50),
                            SizedBox(height: 6),
                            ShimmerBox(height: 10, width: 80),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const ShimmerBox(height: 48, borderRadius: 12),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.shadowSm,
            ),
            child: Column(
              children: [
                _buildInfoRow(),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildInfoRow(),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingLg),

          const ShimmerBox(height: 18, width: 160),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.shadowSm,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(height: 12, width: 60),
                    SizedBox(height: 10),
                    ShimmerBox(height: 16, width: 160),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 120),
                    Spacer(),
                    ShimmerBox(height: 10, width: 80),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: const [
        ShimmerCircle(size: 36),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 12, width: 130),
              SizedBox(height: 6),
              ShimmerBox(height: 16, width: 60),
            ],
          ),
        ),
      ],
    );
  }
}
