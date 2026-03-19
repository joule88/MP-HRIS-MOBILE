import 'package:flutter/material.dart';
import '../../core/theme.dart';

class AttendanceTimeCard extends StatelessWidget {
  final String jamMasuk;
  final String jamPulang;

  const AttendanceTimeCard({
    Key? key,
    required this.jamMasuk,
    required this.jamPulang,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimeRow("Datang", jamMasuk, AppTheme.statusGreen),
        const SizedBox(height: 8),
        _buildTimeRow("Pulang", jamPulang, AppTheme.statusRed),
      ],
    );
  }

  Widget _buildTimeRow(String label, String time, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    time,
                    style: AppTheme.labelLarge.copyWith(fontSize: 14),
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
