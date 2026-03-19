import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/home_provider.dart';
import '../../widgets/atoms/fade_in_up.dart';

class SalaryEstimatorScreen extends StatelessWidget {
  const SalaryEstimatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final totalAbsence = homeProvider.izinCount + homeProvider.alphaCount;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Estimasi Gaji", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Column(
                  children: [
                    Text(
                      "Potongan Bulan Ini",
                      style: AppTheme.bodyMedium.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$totalAbsence Hari",
                      style: AppTheme.heading1.copyWith(color: Colors.white, fontSize: 36),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        "Berdasarkan data presensi Anda",
                        style: AppTheme.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),
            Text("Detail Ketidakhadiran", style: AppTheme.heading3),
            const SizedBox(height: AppTheme.spacingMd),

            FadeInUp(
              delayMs: 100,
              child: _buildDetailItem(
                Icons.event_busy,
                "Izin & Sakit",
                "${homeProvider.izinCount} Hari",
                AppTheme.statusOrange,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            FadeInUp(
              delayMs: 200,
              child: _buildDetailItem(
                Icons.warning_amber_rounded,
                "Alpha / Mangkir",
                "${homeProvider.alphaCount} Hari",
                AppTheme.statusRed,
              ),
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Estimasi ini bersifat sementara dan dapat berubah sesuai dengan kebijakan payroll kantor.",
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: AppTheme.labelLarge),
          ),
          Text(
            value,
            style: AppTheme.heading3.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
