import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/announcement_model.dart';
import '../../screens/home/pengumuman_detail_screen.dart';
import '../atoms/custom_avatar.dart';

class PengumumanCard extends StatelessWidget {
  final AnnouncementModel pengumuman;
  final VoidCallback? onTap;

  const PengumumanCard({
    Key? key,
    required this.pengumuman,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PengumumanDetailScreen(pengumuman: pengumuman),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAvatar(
            name: pengumuman.namaPembuat,
             imageUrl: pengumuman.avatarUrl,
            size: 40,
            backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pengumuman.title, style: AppTheme.labelLarge),
                Text(pengumuman.jabatan, style: AppTheme.bodySmall),
                const SizedBox(height: 8),
                Text(
                  pengumuman.description,
                  style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
  }
}
