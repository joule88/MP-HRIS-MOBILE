import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/poin_provider.dart';
import '../../widgets/organisms/home_header.dart';
import '../../widgets/organisms/poin_lembur_card.dart';
import '../../widgets/organisms/presensi_section.dart';
import '../../widgets/molecules/pengumuman_card.dart';
import '../../widgets/organisms/poin_expiry_card.dart';
import '../../widgets/organisms/home_shimmer.dart';
import '../../widgets/atoms/fade_in_up.dart';
import '../presensi/presensi_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().fetchDashboardData();
      context.read<PoinProvider>().loadExpiringPoints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final poinProvider = context.watch<PoinProvider>();

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: const SafeArea(child: HomeShimmer()),
      );
    }

    if (provider.user == null) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_outlined, size: 56, color: AppTheme.textTertiary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    "Gagal memuat data",
                    style: AppTheme.heading3.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Periksa koneksi internet Anda dan coba lagi",
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchDashboardData(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Coba Lagi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingSm),
                HomeHeader(user: provider.user!),

                if (poinProvider.expiringPoints != null && poinProvider.expiryDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                    child: PoinExpiryCard(
                      expiringPoints: poinProvider.expiringPoints!,
                      expiryDate: poinProvider.expiryDate!,
                      onUseNow: () => Navigator.pushNamed(context, '/poin/usage'),
                    ),
                  ),

                const SizedBox(height: AppTheme.spacingMd),

                PoinLemburCard(
                  poin: provider.poinLembur,
                  onGunakan: () => Navigator.pushNamed(context, '/poin/usage'),
                ),

                const SizedBox(height: AppTheme.spacingLg),

                PresensiSection(
                  presensiToday: provider.presensiToday,
                  onPresensi: () {
                    final sudahMasuk = provider.presensiToday?.sudahAbsenMasuk ?? false;
                    final sudahPulang = provider.presensiToday?.sudahAbsenPulang ?? false;
                    String type = 'masuk';
                    if (sudahMasuk && !sudahPulang) {
                      type = 'pulang';
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PresensiMapScreen(type: type),
                      ),
                    ).then((result) {
                      if (result != null && result['success'] == true) {
                        provider.fetchDashboardData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? 'Presensi berhasil'),
                            backgroundColor: AppTheme.statusGreen,
                          ),
                        );
                      }
                    });
                  },
                ),

                const SizedBox(height: AppTheme.spacingLg),

                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: AppTheme.shadowMd,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.beach_access_rounded, color: AppTheme.primaryDark, size: 28),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sisa Cuti Tahunan",
                              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${provider.sisaCuti} Hari",
                              style: AppTheme.heading2.copyWith(color: AppTheme.statusGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingLg),
                Text("Pengumuman Terbaru", style: AppTheme.heading3),
                const SizedBox(height: AppTheme.spacingMd),
                if (provider.pengumumanList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.campaign_outlined, size: 40, color: AppTheme.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          "Belum ada pengumuman",
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.pengumumanList.length,
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          delayMs: index * 50,
                          child: PengumumanCard(pengumuman: provider.pengumumanList[index]),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
