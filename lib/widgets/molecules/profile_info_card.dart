import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../atoms/custom_avatar.dart';

class ProfileInfoCard extends StatelessWidget {
  final UserModel? user;
  final String currentDate;
  final LatLng? currentLocation;

  const ProfileInfoCard({
    Key? key,
    required this.user,
    required this.currentDate,
    this.currentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("MY PROFILE", style: AppTheme.labelLarge.copyWith(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              CustomAvatar(
                imageUrl: user?.foto,
                name: user?.namaLengkap ?? "U",
                size: 50,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.namaLengkap ?? "Nama Pengguna",
                      style: AppTheme.heading3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentDate,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    if (currentLocation != null)
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Lat ${currentLocation!.latitude.toStringAsFixed(5)} Long ${currentLocation!.longitude.toStringAsFixed(5)}",
                              style: AppTheme.bodySmall.copyWith(fontSize: 10, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
