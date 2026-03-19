import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../models/presensi_model.dart';
import '../atoms/bouncy_tap.dart';
import '../molecules/presensi_card.dart';

class PresensiSection extends StatelessWidget {
  final PresensiModel? presensiToday;
  final VoidCallback onPresensi;
  final bool isLoading;

  const PresensiSection({
    Key? key,
    this.presensiToday,
    required this.onPresensi,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = "${now.day} ${_monthName(now.month)} ${now.year}";

    final shift = presensiToday?.shift ?? "-";
    final jamMasuk = presensiToday?.jamMasuk;
    final jamPulang = presensiToday?.jamPulang;

    final statusMasuk = _getStatusMasuk(now);
    final statusPulang = _getStatusPulang(now);

    final sudahMasuk = presensiToday?.sudahAbsenMasuk ?? false;
    final sudahPulang = presensiToday?.sudahAbsenPulang ?? false;

    String buttonText;
    bool buttonDisabled = false;

    if (!sudahMasuk) {
      buttonText = "Absen Masuk";
    } else if (!sudahPulang) {
      buttonText = "Absen Pulang";
    } else {
      buttonText = "Selesai ✓";
      buttonDisabled = true;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Presensi Hari ini", style: AppTheme.heading3),
                  const SizedBox(height: 4),
                  Text(dateStr, style: AppTheme.bodySmall, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                shift,
                style: AppTheme.labelMedium.copyWith(color: AppTheme.textPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),

        if (presensiToday == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined, size: 44, color: AppTheme.textTertiary.withOpacity(0.5)),
                const SizedBox(height: 12),
                Text(
                  "Tidak ada jadwal kerja hari ini",
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Hubungi admin jika Anda merasa ini salah",
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: PresensiCard(
                  type: PresensiType.datang,
                  time: jamMasuk,
                  status: statusMasuk,
                  statusText: presensiToday?.statusMasuk,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: PresensiCard(
                  type: PresensiType.pulang,
                  time: jamPulang,
                  status: statusPulang,
                  statusText: presensiToday?.statusPulang,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          BouncyTap(
            onPressed: buttonDisabled || isLoading ? null : () {
              HapticFeedback.lightImpact();
              onPresensi();
            },
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: buttonDisabled
                      ? AppTheme.statusGreen.withOpacity(0.5)
                      : (sudahMasuk ? AppTheme.primaryOrange : AppTheme.primaryDark),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: buttonDisabled ? [] : AppTheme.glowPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    else ...[
                      Icon(sudahMasuk ? Icons.logout : Icons.fingerprint, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        buttonText,
                        style: AppTheme.labelLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
          ),
        ],
      ],
    );
  }

  PresensiStatus _getStatusMasuk(DateTime now) {
    if (presensiToday == null) return PresensiStatus.belumWaktunya;

    if (presensiToday!.sudahAbsenMasuk) {
      final status = presensiToday!.statusMasuk?.toLowerCase() ?? '';
      if (status.contains('terlambat')) {
        return PresensiStatus.adaMasalah;
      }
      return PresensiStatus.sudahAbsen;
    }

    return _isNearTime(now, presensiToday!.jadwalJamMasuk)
        ? PresensiStatus.waktunya
        : PresensiStatus.belumWaktunya;
  }

  PresensiStatus _getStatusPulang(DateTime now) {
    if (presensiToday == null) return PresensiStatus.belumWaktunya;

    if (!presensiToday!.sudahAbsenMasuk) return PresensiStatus.belumWaktunya;

    if (presensiToday!.sudahAbsenPulang) {
      final status = presensiToday!.statusPulang?.toLowerCase() ?? '';
      if (status.contains('awal') || status.contains('cepat')) {
        return PresensiStatus.adaMasalah;
      }
      return PresensiStatus.sudahAbsen;
    }

    return _isNearTime(now, presensiToday!.jadwalJamPulang)
        ? PresensiStatus.waktunya
        : PresensiStatus.belumWaktunya;
  }

  bool _isNearTime(DateTime now, String? timeStr) {
    if (timeStr == null) return false;
    try {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final target = DateTime(now.year, now.month, now.day, hour, minute);
      final diff = now.difference(target).inMinutes;
      return diff >= -30;
    } catch (_) {
      return false;
    }
  }

  String _monthName(int month) {
    const months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    return months[month - 1];
  }
}
