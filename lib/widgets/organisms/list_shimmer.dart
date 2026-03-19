import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/shimmer_widgets.dart';

class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                  ShimmerBox(height: 14, width: 140),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 200),
                  SizedBox(height: 6),
                  ShimmerBox(height: 10, width: 100),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const ShimmerBox(height: 24, width: 64, borderRadius: 12),
          ],
        ),
      ),
    );
  }
}
