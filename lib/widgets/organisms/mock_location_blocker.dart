
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/atoms/custom_button.dart';
import 'package:flutter/services.dart';

class MockLocationBlocker extends StatelessWidget {
  final VoidCallback onRetry;

  const MockLocationBlocker({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.statusRed,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.gps_off,
                  size: 64,
                  color: AppTheme.statusRed,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Text(
                "Fake GPS Terdeteksi!",
                style: AppTheme.heading1.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                "Aplikasi mendeteksi penggunaan lokasi palsu. Demi integritas data, mohon matikan aplikasi Fake GPS Anda untuk melanjutkan.",
                style: AppTheme.bodyLarge.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXxl),
              CustomButton(
                text: "Saya Sudah Mematikannya",
                onPressed: onRetry,
                backgroundColor: Colors.white,
                textColor: AppTheme.statusRed,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  "Keluar Aplikasi",
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
