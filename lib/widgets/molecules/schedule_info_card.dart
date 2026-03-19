import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ScheduleInfoCard extends StatelessWidget {
  final String presensiDatang;
  final String presensiPulang;
  final String? statusJadwal;
  final bool isAdjusted;
  final String? adjustmentNote;
  final String? activeType;

  const ScheduleInfoCard({
    Key? key,
    required this.presensiDatang,
    required this.presensiPulang,
    this.statusJadwal,
    this.isAdjusted = false,
    this.adjustmentNote,
    this.activeType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isModified = isAdjusted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("SCHEDULE", style: AppTheme.labelLarge.copyWith(fontSize: 12, color: AppTheme.textSecondary)),
            if (isModified)
              Container(
                constraints: const BoxConstraints(maxWidth: 160),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  adjustmentNote ?? 'Adjusted',
                  style: TextStyle(fontSize: 10, color: Colors.orange[800], fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: _buildTimeCard(
                "Presensi Datang",
                presensiDatang,
                activeType == 'masuk' ? AppTheme.primaryBlue :
                  (isModified && (adjustmentNote?.contains('Datang') ?? false) ? Colors.orange.shade50 : Colors.white),
                activeType == 'masuk' ? Colors.white :
                  (isModified && (adjustmentNote?.contains('Datang') ?? false) ? Colors.orange.shade900 : AppTheme.textPrimary),
                borderColor: activeType == 'masuk' ? AppTheme.primaryBlue :
                  (isModified && (adjustmentNote?.contains('Datang') ?? false) ? Colors.orange : AppTheme.bgCard),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildTimeCard(
                "Presensi Pulang",
                presensiPulang,
                activeType == 'pulang' ? AppTheme.statusOrange :
                  (isModified && (adjustmentNote?.contains('Pulang') ?? false) ? Colors.orange.shade50 : Colors.white),
                activeType == 'pulang' ? Colors.white :
                  (isModified && (adjustmentNote?.contains('Pulang') ?? false) ? Colors.orange.shade900 : AppTheme.textPrimary),
                borderColor: activeType == 'pulang' ? AppTheme.statusOrange :
                  (isModified && (adjustmentNote?.contains('Pulang') ?? false) ? Colors.orange : AppTheme.bgCard),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard(String label, String time, Color bgColor, Color textColor, {Color? borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd, horizontal: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: textColor.withOpacity(0.8), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: AppTheme.heading2.copyWith(color: textColor, fontSize: 24),
            textAlign: TextAlign.center,
          ),
          if (isAdjusted && (adjustmentNote?.contains(label == "Presensi Datang" ? "Datang" : "Pulang") ?? false))
             Text(
                "(Adjusted)",
                style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.7)),
             )
        ],
      ),
    );
  }
}
