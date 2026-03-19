import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/pengajuan_model.dart';
import '../atoms/badge_widget.dart';
import 'package:intl/intl.dart';

class PengajuanDetailSheet extends StatelessWidget {
  final PengajuanModel pengajuan;

  const PengajuanDetailSheet({Key? key, required this.pengajuan}) : super(key: key);

  BadgeType get _badgeType {
    switch (pengajuan.jenis.toLowerCase()) {
      case 'cuti': return BadgeType.cuti;
      case 'sakit': return BadgeType.sakit;
      case 'izin': return BadgeType.izin;
      case 'lembur': return BadgeType.lembur;
      default: return BadgeType.izin;
    }
  }

  Color get _jenisColor {
    switch (pengajuan.jenis.toLowerCase()) {
      case 'cuti': return AppTheme.badgeCutiText;
      case 'sakit': return AppTheme.badgeSakitText;
      case 'izin': return AppTheme.badgeIzinText;
      case 'lembur': return AppTheme.badgeLemburText;
      default: return AppTheme.primaryBlue;
    }
  }

  Color get _statusColor {
    switch (pengajuan.status) {
      case 'approved': return AppTheme.statusGreen;
      case 'rejected': return AppTheme.statusRed;
      default: return AppTheme.statusYellow;
    }
  }

  String get _statusText {
    switch (pengajuan.status) {
      case 'approved': return 'Disetujui';
      case 'rejected': return 'Ditolak';
      default: return 'Menunggu Persetujuan';
    }
  }

  IconData get _statusIcon {
    switch (pengajuan.status) {
      case 'approved': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.access_time_filled;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '-';
    try {
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLembur = pengajuan.jenis.toLowerCase() == 'lembur';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: AppTheme.bgWhite,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text("Detail Pengajuan", style: AppTheme.heading3),
                ),
                BadgeWidget(label: pengajuan.jenis, type: _badgeType),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusText,
                          style: AppTheme.labelLarge.copyWith(color: _statusColor),
                        ),
                        if (pengajuan.status == 'approved' && pengajuan.approvedAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Pada ${pengajuan.approvedAt}",
                            style: AppTheme.bodySmall.copyWith(color: _statusColor.withValues(alpha: 0.7)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: "Tanggal Pengajuan",
              value: _formatDate(pengajuan.tanggalPengajuan),
            ),

            const Divider(height: 1, color: AppTheme.bgCard),
            const SizedBox(height: 14),

            if (isLembur) ...[
              _buildInfoRow(
                icon: Icons.event,
                label: "Tanggal Lembur",
                value: _formatDate(pengajuan.tanggalMulai),
              ),
              _buildInfoRow(
                icon: Icons.schedule,
                label: "Jam Lembur",
                value: "${_formatTime(pengajuan.jamMulai)} - ${_formatTime(pengajuan.jamSelesai)}",
              ),
            ] else ...[
              _buildInfoRow(
                icon: Icons.date_range_outlined,
                label: "Periode",
                value: "${_formatDate(pengajuan.tanggalMulai)}\ns/d ${_formatDate(pengajuan.tanggalSelesai)}",
              ),
              _buildInfoRow(
                icon: Icons.timelapse_outlined,
                label: "Total Hari",
                value: "${pengajuan.totalHari} Hari",
              ),
            ],

            if (pengajuan.keterangan.isNotEmpty) ...[
              const Divider(height: 1, color: AppTheme.bgCard),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes_outlined, size: 20, color: _jenisColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Keterangan / Alasan",
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pengajuan.keterangan,
                          style: AppTheme.bodyMedium.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: _jenisColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary)),
                const SizedBox(height: 4),
                Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
