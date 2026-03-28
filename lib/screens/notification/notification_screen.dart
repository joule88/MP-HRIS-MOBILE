import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/notification_provider.dart';
import '../../models/notifikasi_model.dart';
import '../../widgets/atoms/fade_in_up.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  IconData _iconForTipe(String tipe) {
    if (tipe.contains('disetujui')) return Icons.check_circle_rounded;
    if (tipe.contains('ditolak')) return Icons.cancel_rounded;
    if (tipe.contains('proses')) return Icons.hourglass_top_rounded;
    if (tipe.contains('pengumuman')) return Icons.campaign_rounded;
    if (tipe.contains('lembur')) return Icons.schedule_rounded;
    if (tipe.contains('presensi')) return Icons.fingerprint_rounded;
    if (tipe.contains('izin')) return Icons.description_rounded;
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
    if (tipe.contains('presensi')) return const Color(0xFF06b6d4);
    return const Color(0xFF6366f1);
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

  String _groupLabel(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(dt.year, dt.month, dt.day);

      if (dateOnly == today) return 'Hari Ini';
      if (dateOnly == yesterday) return 'Kemarin';
      return 'Lebih Lama';
    } catch (_) {
      return 'Lainnya';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<NotificationProvider>().fetchUnreadCount();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgLight,
        appBar: AppBar(
          title: Text("Notifikasi", style: AppTheme.heading3),
          backgroundColor: AppTheme.bgLight,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Consumer<NotificationProvider>(
              builder: (_, provider, __) => TextButton(
                onPressed: provider.notifications.any((n) => !n.isRead)
                    ? () => provider.markAllAsRead()
                    : null,
                child: Text(
                  'Baca Semua',
                  style: AppTheme.bodySmall.copyWith(
                    color: provider.notifications.any((n) => !n.isRead)
                        ? AppTheme.primaryBlue
                        : AppTheme.textTertiary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Text(
                  provider.errorMessage!,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.statusRed),
                ),
              );
            }

            if (provider.notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.textTertiary.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 52,
                          color: AppTheme.textTertiary.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Belum ada notifikasi",
                        style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Semua notifikasi terbaru akan muncul di sini.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final grouped = <String, List<NotifikasiModel>>{};
            for (final item in provider.notifications) {
              final label = _groupLabel(item.createdAt);
              grouped.putIfAbsent(label, () => []).add(item);
            }

            final orderedKeys = ['Hari Ini', 'Kemarin', 'Lebih Lama']
                .where((k) => grouped.containsKey(k))
                .toList();

            return RefreshIndicator(
              onRefresh: () => provider.fetchNotifications(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                itemCount: orderedKeys.length,
                itemBuilder: (context, sectionIndex) {
                  final key = orderedKeys[sectionIndex];
                  final items = grouped[key]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sectionIndex > 0) const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
                        child: Text(
                          key,
                          style: AppTheme.labelLarge.copyWith(
                            color: AppTheme.textTertiary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final color = _colorForTipe(item.tipe);

                        return FadeInUp(
                          delayMs: index * 40,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                            child: GestureDetector(
                              onTap: () {
                                if (!item.isRead) {
                                  provider.markAsRead(item.id);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: item.isRead ? Colors.white : color.withValues(alpha: 0.04),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                  boxShadow: AppTheme.shadowSm,
                                  border: item.isRead
                                      ? Border.all(color: Colors.transparent)
                                      : Border.all(color: color.withValues(alpha: 0.15)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(_iconForTipe(item.tipe), color: color, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.judul,
                                                  style: AppTheme.labelLarge.copyWith(
                                                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                              if (!item.isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.pesan,
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.textSecondary,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            _relativeTime(item.createdAt),
                                            style: AppTheme.bodySmall.copyWith(
                                              color: AppTheme.textTertiary,
                                              fontSize: 11,
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
                        );
                      }),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
