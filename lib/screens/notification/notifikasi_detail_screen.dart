import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/notifikasi_model.dart';
import '../../widgets/atoms/fade_in_up.dart';

class NotifikasiDetailScreen extends StatelessWidget {
  final NotifikasiModel notifikasi;

  const NotifikasiDetailScreen({super.key, required this.notifikasi});

  IconData _iconForTipe(String tipe) {
    if (tipe.contains('disetujui')) return Icons.check_circle_rounded;
    if (tipe.contains('ditolak')) return Icons.cancel_rounded;
    if (tipe.contains('proses')) return Icons.hourglass_top_rounded;
    if (tipe.contains('pengumuman')) return Icons.campaign_rounded;
    if (tipe.contains('lembur')) return Icons.schedule_rounded;
    if (tipe.contains('presensi')) return Icons.fingerprint_rounded;
    if (tipe.contains('izin')) return Icons.description_rounded;
    if (tipe.contains('cuti')) return Icons.beach_access_rounded;
    if (tipe.contains('poin')) return Icons.stars_rounded;
    return Icons.notifications_outlined;
  }

  Color _colorForTipe(String tipe) {
    if (tipe.contains('disetujui')) return const Color(0xFF10b981);
    if (tipe.contains('ditolak')) return const Color(0xFFef4444);
    if (tipe.contains('pengumuman')) return AppTheme.primaryBlue;
    if (tipe.contains('lembur')) return const Color(0xFFf59e0b);
    if (tipe.contains('poin')) return const Color(0xFFe11d48);
    if (tipe.contains('izin')) return const Color(0xFF8b5cf6);
    if (tipe.contains('cuti')) return const Color(0xFF06b6d4);
    if (tipe.contains('presensi')) return const Color(0xFF06b6d4);
    return const Color(0xFF6366f1);
  }

  String _labelForTipe(String tipe) {
    if (tipe.contains('disetujui')) return 'Disetujui';
    if (tipe.contains('ditolak')) return 'Ditolak';
    if (tipe.contains('proses')) return 'Dalam Proses';
    if (tipe.contains('pengumuman')) return 'Pengumuman';
    if (tipe.contains('lembur')) return 'Lembur';
    if (tipe.contains('presensi')) return 'Presensi';
    if (tipe.contains('izin')) return 'Izin';
    if (tipe.contains('cuti')) return 'Cuti';
    if (tipe.contains('poin')) return 'Poin';
    return 'Notifikasi';
  }

  String _relativeTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';

      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }

  String _fullDateTime(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      final bulan = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${hari[dt.weekday - 1]}, ${dt.day} ${bulan[dt.month - 1]} ${dt.year} • '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt;
    }
  }

  String? _actionRoute(String tipe) {
    if (tipe.contains('pengumuman')) return null;
    if (tipe.contains('izin') || tipe.contains('cuti') || tipe.contains('lembur') || tipe.contains('sakit')) {
      return '/pengajuan';
    }
    if (tipe.contains('presensi')) return '/presensi';
    return null;
  }

  String? _actionLabel(String tipe) {
    if (tipe.contains('izin') || tipe.contains('cuti') || tipe.contains('lembur') || tipe.contains('sakit')) {
      return 'Lihat Pengajuan';
    }
    if (tipe.contains('presensi')) return 'Lihat Riwayat Presensi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipe(notifikasi.tipe);
    final icon = _iconForTipe(notifikasi.tipe);
    final label = _labelForTipe(notifikasi.tipe);
    final actionRoute = _actionRoute(notifikasi.tipe);
    final actionLabel = _actionLabel(notifikasi.tipe);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Detail Notifikasi", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            FadeInUp(
              delayMs: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: AppTheme.bodySmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      notifikasi.judul,
                      style: AppTheme.heading2.copyWith(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _relativeTime(notifikasi.createdAt),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            FadeInUp(
              delayMs: 60,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Detail Pesan',
                          style: AppTheme.heading3.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      notifikasi.pesan,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.7,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgInput,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _fullDateTime(notifikasi.createdAt),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (notifikasi.data != null && notifikasi.data!.isNotEmpty) ...[
              const SizedBox(height: 16),
              FadeInUp(
                delayMs: 120,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppTheme.textTertiary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Tambahan',
                            style: AppTheme.heading3.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...notifikasi.data!.entries
                          .where((e) => e.key != 'tipe' && e.value != null && e.value.toString().isNotEmpty)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        _formatDataKey(e.key),
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.textTertiary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        e.value.toString(),
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
              ),
            ],

            if (actionRoute != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FadeInUp(
                delayMs: 160,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, actionRoute);
                    },
                    icon: Icon(
                      notifikasi.tipe.contains('presensi')
                          ? Icons.fingerprint_rounded
                          : Icons.description_rounded,
                      size: 18,
                    ),
                    label: Text(actionLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      elevation: 0,
                      textStyle: AppTheme.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDataKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }
}
