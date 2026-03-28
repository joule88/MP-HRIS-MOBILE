import 'package:flutter/material.dart';
import '../../core/theme.dart';

class QuickMenuCard extends StatelessWidget {
  final VoidCallback onPresensiTap;
  final VoidCallback onPengajuanTap;
  final VoidCallback onLemburTap;
  final VoidCallback onJadwalTap;

  const QuickMenuCard({
    Key? key,
    required this.onPresensiTap,
    required this.onPengajuanTap,
    required this.onLemburTap,
    required this.onJadwalTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(context, Icons.fingerprint, "Presensi", AppTheme.primaryDark, onPresensiTap),
          _buildItem(context, Icons.assignment_outlined, "Pengajuan", Colors.orange, onPengajuanTap),
          _buildItem(context, Icons.access_time_filled, "Lembur", Colors.blue, onLemburTap),
          _buildItem(context, Icons.calendar_month_outlined, "Jadwal", Colors.teal, onJadwalTap),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
