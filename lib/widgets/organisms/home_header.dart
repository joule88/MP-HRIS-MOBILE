import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/user_model.dart';
import '../atoms/custom_avatar.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;

  const HomeHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return "Selamat Pagi ☀️";
    if (hour >= 11 && hour < 15) return "Selamat Siang 🌤️";
    if (hour >= 15 && hour < 18) return "Selamat Sore 🌅";
    return "Selamat Malam 🌙";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.glowPrimary,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glassWhite10,
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glassWhite10,
              ),
            ),
          ),
          Row(
            children: [
              CustomAvatar(
                imageUrl: user.foto,
                name: user.namaLengkap,
                size: 48,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.namaLengkap.split(' ').first,
                      style: AppTheme.heading2.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.glassWhite10,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.glassWhite20, width: 1),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, '/notification');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
