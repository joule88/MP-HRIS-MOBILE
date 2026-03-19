import 'package:flutter/material.dart';
import '../atoms/shimmer_widgets.dart';

class ScheduleShimmer extends StatelessWidget {
  const ScheduleShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(height: 20, width: 20, borderRadius: 4),
                  ShimmerBox(height: 20, width: 120),
                  ShimmerBox(height: 20, width: 20, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (_) => const ShimmerBox(
                  height: 14, width: 28, borderRadius: 4,
                )),
              ),
              const SizedBox(height: 12),

              ...List.generate(5, (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (col) => Column(
                    children: [
                      ShimmerBox(
                        height: 32, width: 32,
                        borderRadius: 16,
                      ),
                      const SizedBox(height: 4),
                      ShimmerCircle(size: 6),
                    ],
                  )),
                ),
              )),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const ShimmerBox(height: 18, width: 200),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: const [
                          ShimmerBox(height: 12, width: 70),
                          SizedBox(height: 8),
                          ShimmerBox(height: 28, width: 60),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[200]),
                      Column(
                        children: const [
                          ShimmerBox(height: 12, width: 70),
                          SizedBox(height: 8),
                          ShimmerBox(height: 28, width: 60),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        ShimmerCircle(size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(height: 14, width: 140),
                              SizedBox(height: 6),
                              ShimmerBox(height: 12, width: 180),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
