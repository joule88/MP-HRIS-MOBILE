import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/pengajuan_model.dart';
import '../atoms/badge_widget.dart';
import '../atoms/bouncy_tap.dart';
import 'package:intl/intl.dart';

class PengajuanItemCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final VoidCallback? onTap;

  const PengajuanItemCard({
    Key? key,
    required this.pengajuan,
    this.onTap,
  }) : super(key: key);

  BadgeType get _badgeType {
    switch (pengajuan.jenis.toLowerCase()) {
      case 'cuti': return BadgeType.cuti;
      case 'sakit': return BadgeType.sakit;
      case 'izin': return BadgeType.izin;
      case 'lembur': return BadgeType.lembur;
      default: return BadgeType.izin;
    }
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '-';
    try {
      List<String> parts = timeStr.split(':');
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BouncyTap(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.bgWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: AppTheme.bgCard, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formatDate(pengajuan.tanggalPengajuan),
                          style: AppTheme.labelMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BadgeWidget(label: pengajuan.jenis, type: _badgeType, isSmall: true),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: AppTheme.bgCard),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tanggal", style: AppTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        pengajuan.jenis.toLowerCase() == 'lembur'
                            ? _formatDate(pengajuan.tanggalMulai) 
                            : "${_formatDate(pengajuan.tanggalMulai)} - ${_formatDate(pengajuan.tanggalSelesai)}",
                        style: AppTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        pengajuan.jenis.toLowerCase() == 'lembur' ? "Jam Kerja" : "Total Hari", 
                        style: AppTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pengajuan.jenis.toLowerCase() == 'lembur'
                            ? "${_formatTime(pengajuan.jamMulai)} - ${_formatTime(pengajuan.jamSelesai)}"
                            : "${pengajuan.totalHari} Hari", 
                        style: AppTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (pengajuan.status == 'approved') ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppTheme.statusGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pengajuan.approvedAt != null 
                          ? "Disetujui pada ${pengajuan.approvedAt}" 
                          : "Disetujui",
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.statusGreen),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (pengajuan.status == 'rejected') ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  const Icon(Icons.cancel, size: 16, color: AppTheme.statusRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Ditolak", style: AppTheme.bodySmall.copyWith(color: AppTheme.statusRed), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
             if (pengajuan.status == 'pending') ...[
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                  const Icon(Icons.access_time_filled, size: 16, color: AppTheme.statusYellow),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Pending Approval", style: AppTheme.bodySmall.copyWith(color: AppTheme.statusYellow), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            if (pengajuan.keterangan.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                pengajuan.keterangan,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Lihat Detail",
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
