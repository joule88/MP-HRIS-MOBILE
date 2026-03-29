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

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _getMonthName(int month) => _monthNames[month - 1];

  void _goToPrevMonth(AttendanceProvider p) {
    if (p.selectedMonth == 1) {
      p.setYear(p.selectedYear - 1);
      p.setMonth(12);
    } else {
      p.setMonth(p.selectedMonth - 1);
    }
  }

  void _goToNextMonth(AttendanceProvider p) {
    final now = DateTime.now();
    if (p.selectedYear == now.year && p.selectedMonth == now.month) return;
    if (p.selectedMonth == 12) {
      p.setYear(p.selectedYear + 1);
      p.setMonth(1);
    } else {
      p.setMonth(p.selectedMonth + 1);
    }
  }

  bool _isCurrentMonth(AttendanceProvider p) {
    final now = DateTime.now();
    return p.selectedYear == now.year && p.selectedMonth == now.month;
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
              const SizedBox(height: 12),

              // Month/Year Picker
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.bgWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _goToPrevMonth(attendanceProvider),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_left, size: 20, color: AppTheme.primaryDark),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showMonthYearPicker(context, attendanceProvider),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 18, color: AppTheme.primaryDark),
                          const SizedBox(width: 8),
                          Text(
                            "${_getMonthName(attendanceProvider.selectedMonth)} ${attendanceProvider.selectedYear}",
                            style: AppTheme.labelLarge.copyWith(fontSize: 16, color: AppTheme.primaryDark),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _isCurrentMonth(attendanceProvider) ? null : () => _goToNextMonth(attendanceProvider),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isCurrentMonth(attendanceProvider)
                              ? AppTheme.textTertiary.withValues(alpha: 0.1)
                              : AppTheme.primaryDark.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: _isCurrentMonth(attendanceProvider)
                              ? AppTheme.textTertiary
                              : AppTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // History List
              if (attendanceProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (attendanceProvider.historyList.isEmpty)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingXl),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: AppTheme.textTertiary),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          "Tidak ada data presensi bulan ini",
                          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
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
                                        _buildBadge("Ditolak", AppTheme.statusRed),
                                      if (history.statusValidasi == 2)
                                        _buildBadge("Menunggu Validasi", AppTheme.statusOrange, bgColor: AppTheme.statusYellow),
                                      if (!history.verifikasiWajah && history.statusMasuk != 'Izin' && history.statusMasuk != 'Cuti' && history.statusMasuk != 'Sakit' && history.statusMasuk != 'Alpha')
                                        _buildBadge("Wajah Tidak Terverifikasi", AppTheme.statusOrange),
                                      if (history.keteranganLuarRadius != null)
                                        _buildBadge("Luar Radius", AppTheme.primaryDark),
                                      if (history.statusMasuk != null && history.statusMasuk != '-')
                                        _buildBadge(history.statusMasuk!, _getStatusColor(history.statusMasuk!)),
                                      if (history.statusPulang != null &&
                                          history.statusPulang != '-' &&
                                          history.statusPulang != 'Tepat Waktu' &&
                                          history.statusPulang != history.statusMasuk)
                                        _buildBadge(history.statusPulang!, _getStatusColor(history.statusPulang!)),
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

  Widget _buildBadge(String label, Color color, {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (bgColor ?? color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context, AttendanceProvider provider) {
    final now = DateTime.now();
    int tempMonth = provider.selectedMonth;
    int tempYear = provider.selectedYear;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textTertiary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Pilih Bulan", style: AppTheme.heading3),
                  const SizedBox(height: 16),

                  // Year selector row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setModalState(() => tempYear--),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text("$tempYear", style: AppTheme.labelLarge.copyWith(fontSize: 18)),
                      IconButton(
                        onPressed: tempYear >= now.year ? null : () => setModalState(() => tempYear++),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Month grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: 12,
                    itemBuilder: (ctx, idx) {
                      final m = idx + 1;
                      final isSelected = m == tempMonth && tempYear == provider.selectedYear;
                      final isFuture = tempYear == now.year && m > now.month;

                      return GestureDetector(
                        onTap: isFuture ? null : () {
                          setModalState(() => tempMonth = m);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryDark
                                : isFuture
                                    ? AppTheme.textTertiary.withValues(alpha: 0.05)
                                    : m == tempMonth
                                        ? AppTheme.primaryDark.withValues(alpha: 0.1)
                                        : AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _monthNames[idx].substring(0, 3),
                            style: AppTheme.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : isFuture
                                      ? AppTheme.textTertiary
                                      : m == tempMonth
                                          ? AppTheme.primaryDark
                                          : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.setYear(tempYear);
                        provider.setMonth(tempMonth);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text("Terapkan", style: AppTheme.labelLarge.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
