import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/organisms/presensi_section.dart';
import '../../widgets/molecules/stat_card.dart';
import '../../widgets/molecules/attendance_time_card.dart';
import '../../widgets/organisms/presensi_detail_sheet.dart';
import '../../models/presensi_model.dart';
import '../../widgets/atoms/fade_in_up.dart';
import 'presensi_map_screen.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({Key? key}) : super(key: key);

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Presensi Karyawan", style: AppTheme.heading3),
        centerTitle: false,
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        actions: [
          InkWell(
            onTap: () {
              _showScheduleModal(context);
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingMd),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                children: [
                  Text(homeProvider.presensiToday?.shift ?? "-", style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryDark)),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _showScheduleModal(context);
                    },
                    child: const Icon(Icons.calendar_month, color: AppTheme.primaryDark, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await homeProvider.fetchDashboardData();
          await attendanceProvider.fetchHistory();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PresensiSection(
                presensiToday: homeProvider.presensiToday,
                onPresensi: () {
                   _handlePresensi(homeProvider.presensiToday != null && homeProvider.presensiToday!.sudahAbsenMasuk ? 'pulang' : 'masuk');
                },
                isLoading: attendanceProvider.isLoading,
              ),

              const SizedBox(height: AppTheme.spacingXl),

              Text("History Presensi", style: AppTheme.heading3),
              const SizedBox(height: AppTheme.spacingMd),

              attendanceProvider.historyList.isEmpty
                  ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingXl),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today, size: 48, color: AppTheme.textTertiary),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            "Tidak ada data presensi",
                            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: attendanceProvider.historyList.length,
                      itemBuilder: (context, index) {
                        final history = attendanceProvider.historyList[index];
                        return FadeInUp(
                          delayMs: index * 50,
                          child: InkWell(
                            onTap: () => _showPresensiDetail(context, history),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                            padding: const EdgeInsets.all(AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: AppTheme.bgWhite,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                              boxShadow: AppTheme.shadowSm,
                            ),
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: AppTheme.primaryDark),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            history.tanggal,
                                            style: AppTheme.labelMedium,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        if (history.statusValidasi == 3)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusRed.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              "Ditolak",
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.statusRed,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        if (history.statusValidasi == 2)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusYellow.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              "Menunggu Validasi",
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.statusOrange,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        if (!history.verifikasiWajah && history.statusMasuk != 'Izin' && history.statusMasuk != 'Cuti' && history.statusMasuk != 'Sakit' && history.statusMasuk != 'Alpha')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.statusOrange.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              "Wajah Tidak Terverifikasi",
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.statusOrange,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        if (history.keteranganLuarRadius != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryDark.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              "Luar Radius",
                                              style: AppTheme.bodySmall.copyWith(
                                                color: AppTheme.primaryDark,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        if (history.statusMasuk != null && history.statusMasuk != '-')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(history.statusMasuk!).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              history.statusMasuk!,
                                              style: AppTheme.bodySmall.copyWith(
                                                color: _getStatusColor(history.statusMasuk!),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        if (history.statusPulang != null &&
                                            history.statusPulang != '-' &&
                                            history.statusPulang != 'Tepat Waktu' &&
                                            history.statusPulang != history.statusMasuk)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(history.statusPulang!).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                            ),
                                            child: Text(
                                              history.statusPulang!,
                                              style: AppTheme.bodySmall.copyWith(
                                                color: _getStatusColor(history.statusPulang!),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.spacingMd),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: StatCard(
                                        label: "Total Jam Kerja",
                                        value: history.totalJam,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacingMd),
                                    Expanded(
                                        child: AttendanceTimeCard(
                                          jamMasuk: history.jamMasuk ?? '-',
                                          jamPulang: history.jamPulang ?? '-',
                                        ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Lihat Detail",
                                      style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                       );
                      },
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showScheduleModal(BuildContext context) {
    Navigator.pushNamed(context, '/schedule');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
      case 'datang awal':
        return AppTheme.statusGreen;
      case 'terlambat':
      case 'pulang awal':
      case 'alpha':
        return AppTheme.statusRed;
      case 'izin':
      case 'sakit':
      case 'cuti':
        return AppTheme.statusOrange;
      default:
        return AppTheme.primaryDark;
    }
  }

  void _showPresensiDetail(BuildContext context, PresensiHistoryModel history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      backgroundColor: Colors.transparent,
      builder: (context) => PresensiDetailSheet(history: history),
    );
  }

  Future<void> _handlePresensi(String type) async {
    if (!mounted) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => PresensiMapScreen(type: type),
      ),
    );

    if (!mounted) return;

    if (result != null && result['success'] == true) {
      await context.read<HomeProvider>().fetchDashboardData();
      await context.read<AttendanceProvider>().fetchHistory();
      _showResultDialog(true, "Absensi Berhasil!", result['message'] ?? "Data absensi Anda telah tercatat.");
    }
  }

  void _showResultDialog(bool success, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? AppTheme.statusGreen : AppTheme.statusRed,
            ),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.heading3),
          ],
        ),
        content: Text(message, style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup", style: AppTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}
