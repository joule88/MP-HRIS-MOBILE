import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/poin_provider.dart';
import '../../core/theme.dart';

class PoinHistoryScreen extends StatefulWidget {
  const PoinHistoryScreen({super.key});

  @override
  State<PoinHistoryScreen> createState() => _PoinHistoryScreenState();
}

class _PoinHistoryScreenState extends State<PoinHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoinProvider>().loadPointHistory();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'approved':
        return AppTheme.statusGreen;
      case 'ditolak':
      case 'rejected':
        return AppTheme.statusRed;
      default:
        return AppTheme.statusYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Riwayat Penggunaan Poin", style: AppTheme.heading3),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PoinProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.pointHistory.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.pointHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.statusRed),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!, style: AppTheme.bodyLarge.copyWith(color: AppTheme.statusRed)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadPointHistory(),
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          }

          if (provider.pointHistory.isEmpty) {
             return RefreshIndicator(
               onRefresh: () async {
                 await provider.loadPointHistory();
               },
               child: SingleChildScrollView(
                 physics: const AlwaysScrollableScrollPhysics(),
                 child: SizedBox(
                   height: MediaQuery.of(context).size.height * 0.7,
                   child: Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Icon(Icons.history, size: 64, color: AppTheme.textTertiary),
                         const SizedBox(height: 16),
                         Text("Belum ada riwayat POIN", style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary)),
                       ],
                     ),
                   ),
                 ),
               ),
             );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPointHistory();
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              itemCount: provider.pointHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
              itemBuilder: (context, index) {
                final item = provider.pointHistory[index];
                
                String tanggal = item['tanggal_penggunaan'] ?? '-';
                try {
                  final dt = DateTime.parse(tanggal);
                  tanggal = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
                } catch (e) {}

                final jenisItem = item['jenis_pengurangan'] ?? item['jenisPengurangan'] ?? {};
                final statusItem = item['status'] ?? {};
                
                final jenis = jenisItem['nama_pengurangan'] ?? 'Tidak diketahui';
                final statusName = statusItem['nama_status'] ?? 'Pending';
                final poin = item['jumlah_poin'] ?? 0;
                
                String detailWaktu = "";
                if (item['jam_masuk_custom'] != null) {
                  detailWaktu = " - Masuk ${item['jam_masuk_custom']}";
                } else if (item['jam_pulang_custom'] != null) {
                  detailWaktu = " - Pulang ${item['jam_pulang_custom']}";
                }

                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$jenis$detailWaktu", 
                              style: AppTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tanggal, 
                              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(statusName).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                              ),
                              child: Text(
                                statusName,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(statusName),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "-$poin",
                            style: AppTheme.heading3.copyWith(color: AppTheme.statusRed),
                          ),
                          const Text(
                            "Poin",
                            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
