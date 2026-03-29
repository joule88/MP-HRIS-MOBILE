import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/announcement_model.dart';
import '../../widgets/atoms/custom_avatar.dart';
import '../../widgets/atoms/fade_in_up.dart';

class PengumumanDetailScreen extends StatelessWidget {
  final AnnouncementModel pengumuman;

  const PengumumanDetailScreen({super.key, required this.pengumuman});

  String _formatTanggal(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF3B82F6),
                      Color(0xFF6366F1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.campaign_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Pengumuman',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pengumuman.title,
                          style: AppTheme.heading2.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    delayMs: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Row(
                        children: [
                          CustomAvatar(
                            name: pengumuman.namaPembuat,
                            imageUrl: pengumuman.avatarUrl,
                            size: 44,
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pengumuman.namaPembuat,
                                  style: AppTheme.labelLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pengumuman.jabatan,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.primaryBlue),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTanggal(pengumuman.date),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  FadeInUp(
                    delayMs: 80,
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
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Isi Pengumuman',
                                style: AppTheme.heading3.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pengumuman.description,
                            style: AppTheme.bodyLarge.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.7,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
