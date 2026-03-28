import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/error_handler.dart';
import '../../core/theme.dart';
import '../../models/presensi_model.dart';
import '../../providers/attendance_provider.dart';

class PresensiDetailSheet extends StatefulWidget {
  final PresensiHistoryModel history;

  const PresensiDetailSheet({Key? key, required this.history}) : super(key: key);

  @override
  State<PresensiDetailSheet> createState() => _PresensiDetailSheetState();
}

class _PresensiDetailSheetState extends State<PresensiDetailSheet> {
  final _keteranganController = TextEditingController();
  bool _showResubmitForm = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  String _formatTime(String? time) {
    if (time == null) return '-';
    try {
      final parts = time.split(':');
      if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
      return time;
    } catch (_) {
      return time;
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'tepat waktu':
      case 'datang awal':
        return AppTheme.statusGreen;
      case 'terlambat':
      case 'pulang awal':
        return AppTheme.statusRed;
      case 'lembur':
        return AppTheme.badgeLemburText;
      default:
        return AppTheme.textTertiary;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'tepat waktu':
      case 'datang awal':
        return Icons.check_circle;
      case 'terlambat':
      case 'pulang awal':
        return Icons.warning_amber_rounded;
      case 'lembur':
        return Icons.timer;
      default:
        return Icons.remove_circle_outline;
    }
  }

  Future<void> _handleResubmit() async {
    if (_keteranganController.text.trim().isEmpty) {
      ErrorHandler.showWarning('Keterangan wajib diisi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final provider = context.read<AttendanceProvider>();
      await provider.resubmitPresensi(
        widget.history.idPresensi!,
        _keteranganController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ErrorHandler.showSuccess('Presensi berhasil diajukan ulang!');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.history;

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
                  child: Text("Detail Presensi", style: AppTheme.heading3),
                ),
                if (history.shift != null && history.shift != '-')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      history.shift!,
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryDark),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              history.tanggal,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
            if (history.statusValidasi == 3) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.statusRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.statusRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel, color: AppTheme.statusRed, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Presensi Ditolak",
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.statusRed),
                    ),
                  ],
                ),
              ),
            ],
            if (history.statusValidasi == 2) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.statusYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.statusYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hourglass_top, color: AppTheme.statusOrange, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Menunggu Validasi Admin",
                      style: AppTheme.labelMedium.copyWith(color: AppTheme.statusOrange),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.login_rounded, color: AppTheme.statusGreen, size: 28),
                        const SizedBox(height: 8),
                        Text("Masuk", style: AppTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(history.jamMasuk),
                          style: AppTheme.heading3.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: AppTheme.textTertiary.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.logout_rounded, color: AppTheme.primaryOrange, size: 28),
                        const SizedBox(height: 8),
                        Text("Pulang", style: AppTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(history.jamPulang),
                          style: AppTheme.heading3.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: AppTheme.textTertiary.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.schedule_rounded, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(height: 8),
                        Text("Total", style: AppTheme.bodySmall),
                        const SizedBox(height: 4),
                        Text(
                          history.totalJam,
                          style: AppTheme.heading3.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildDetailRow(
              icon: _statusIcon(history.statusMasuk),
              iconColor: _statusColor(history.statusMasuk),
              label: "Status Masuk",
              value: history.statusMasuk ?? '-',
              valueColor: _statusColor(history.statusMasuk),
            ),

            if (history.jamPulang != null)
              _buildDetailRow(
                icon: _statusIcon(history.statusPulang),
                iconColor: _statusColor(history.statusPulang),
                label: "Status Pulang",
                value: history.statusPulang ?? '-',
                valueColor: _statusColor(history.statusPulang),
              ),

            if (history.waktuTerlambat != null)
              _buildDetailRow(
                icon: Icons.timer_off_outlined,
                iconColor: AppTheme.statusRed,
                label: "Waktu Terlambat",
                value: history.waktuTerlambat!,
                valueColor: AppTheme.statusRed,
              ),

            _buildDetailRow(
              icon: history.verifikasiWajah ? Icons.face : Icons.face_retouching_off,
              iconColor: history.verifikasiWajah ? AppTheme.statusGreen : AppTheme.textTertiary,
              label: "Verifikasi Wajah",
              value: history.verifikasiWajah ? "Terverifikasi" : "Tidak Terverifikasi",
              valueColor: history.verifikasiWajah ? AppTheme.statusGreen : AppTheme.textTertiary,
            ),

            if (history.keteranganLuarRadius != null && history.keteranganLuarRadius!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusYellow.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.statusYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.statusYellow),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Keterangan Luar Radius",
                            style: AppTheme.labelMedium.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.keteranganLuarRadius!,
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (history.statusValidasi == 3 && history.alasanPenolakan != null && history.alasanPenolakan!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.statusRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: AppTheme.statusRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Alasan Penolakan",
                            style: AppTheme.labelMedium.copyWith(color: AppTheme.statusRed),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.alasanPenolakan!,
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (history.statusValidasi == 3 && history.idPresensi != null) ...[
              const SizedBox(height: 16),

              if (!_showResubmitForm)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showResubmitForm = true),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Ajukan Ulang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),

              if (_showResubmitForm) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ajukan Ulang Presensi",
                        style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Jelaskan alasan pengajuan ulang presensi Anda.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _keteranganController,
                        maxLines: 3,
                        maxLength: 500,
                        decoration: InputDecoration(
                          hintText: "Contoh: Saya berada di lokasi klien untuk meeting...",
                          hintStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                          filled: true,
                          fillColor: AppTheme.bgWhite,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            borderSide: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            borderSide: BorderSide(color: AppTheme.textTertiary.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            borderSide: const BorderSide(color: AppTheme.primaryBlue),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting ? null : () => setState(() => _showResubmitForm = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                              ),
                              child: const Text("Batal"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleResubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text("Kirim"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
          ),
          Text(
            value,
            style: AppTheme.labelLarge.copyWith(color: valueColor ?? AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}
