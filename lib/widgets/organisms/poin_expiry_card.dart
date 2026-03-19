
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PoinExpiryCard extends StatelessWidget {
  final int expiringPoints;
  final DateTime expiryDate;
  final VoidCallback onUseNow;

  const PoinExpiryCard({
    Key? key,
    required this.expiringPoints,
    required this.expiryDate,
    required this.onUseNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expiringPoints <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statusOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.statusOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Poin Segera Hangus!",
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.statusOrange),
                ),
                const SizedBox(height: 2),
                RichText(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  text: TextSpan(
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    children: [
                      TextSpan(
                        text: "$expiringPoints Poin ",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.statusOrange),
                      ),
                      const TextSpan(text: "akan hangus pada "),
                      TextSpan(
                        text: _formatDate(expiryDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUseNow,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.statusOrange,
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text("Gunakan", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
