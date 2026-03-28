import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../providers/poin_provider.dart';
import '../../core/error_handler.dart';
import '../../core/theme.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/custom_text_field.dart';

class PointUsageScreen extends StatefulWidget {
  const PointUsageScreen({super.key});

  @override
  State<PointUsageScreen> createState() => _PointUsageScreenState();
}

class _PointUsageScreenState extends State<PointUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _alasanController = TextEditingController();

  final List<Map<String, dynamic>> _jenisOptions = [
    {'id': 4, 'label': 'Datang Terlambat'},
    {'id': 5, 'label': 'Pulang Cepat'},
    {'id': 6, 'label': 'Tidak Masuk (Full Day)'},
  ];

  int? _selectedJenisId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _estimasiPoin = 0;
  String? _perhitunganDetail;

  bool _isScheduleChecked = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PoinProvider>().loadExpiringPoints();
    });
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    await initializeDateFormatting('id_ID', null);

    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedJenisId = null;
        _selectedTime = null;
        _estimasiPoin = 0;
        _isScheduleChecked = false;
        _perhitunganDetail = null;
      });

      final provider = context.read<PoinProvider>();
      final hasSchedule = await provider.checkShiftSchedule(picked);

      setState(() {
        _isScheduleChecked = hasSchedule;
      });

      if (!hasSchedule && mounted) {
        ErrorHandler.showError(provider.errorMessage ?? 'Jadwal tidak ditemukan');
      }
    }
  }

  void _calculatePoin() {
    final provider = context.read<PoinProvider>();
    final shiftStart = provider.shiftStart;
    final shiftEnd = provider.shiftEnd;

    if (shiftStart == null || shiftEnd == null) return;
    if (_selectedJenisId == null) return;

    int totalMenit = 0;
    String detail = "";

    int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

    int startMinutes = toMinutes(shiftStart);
    int endMinutes = toMinutes(shiftEnd);

    if (endMinutes < startMinutes) endMinutes += 24 * 60;

    if (_selectedJenisId == 6) {
      totalMenit = endMinutes - startMinutes;
      detail = "Full Shift (${totalMenit} menit)";
    }
    else if (_selectedJenisId == 4 && _selectedTime != null) {
      int customMinutes = toMinutes(_selectedTime!);
      if (customMinutes < startMinutes) customMinutes += 24 * 60;

      if (customMinutes <= startMinutes) {
        _estimasiPoin = 0;
        _perhitunganDetail = "Jam masuk lebih awal/sama dengan jam mulai shift";
        return;
      }

      totalMenit = customMinutes - startMinutes;
      detail = "Terlambat ${totalMenit} menit";
    }
    else if (_selectedJenisId == 5 && _selectedTime != null) {
      int customMinutes = toMinutes(_selectedTime!);
      if (customMinutes < startMinutes) customMinutes += 24 * 60;

      if (customMinutes >= endMinutes) {
        _estimasiPoin = 0;
        _perhitunganDetail = "Jam pulang lebih akhir/sama dengan jam selesai shift";
        return;
      }

      totalMenit = endMinutes - customMinutes;
      detail = "Pulang awal ${totalMenit} menit";
    }

    if (totalMenit > 0) {
      final biaya = (totalMenit / 30).ceil();
      setState(() {
        _estimasiPoin = biaya;
        _perhitunganDetail = "$detail ÷ 30 menit = $biaya Poin";
      });
    } else {
      setState(() {
        _estimasiPoin = 0;
        _perhitunganDetail = null;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final provider = context.read<PoinProvider>();
    final shiftStart = provider.shiftStart;
    final shiftEnd = provider.shiftEnd;

    TimeOfDay initial = TimeOfDay.now();
    if (_selectedJenisId == 4 && shiftStart != null) initial = shiftStart;
    if (_selectedJenisId == 5 && shiftEnd != null) initial = shiftEnd;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? initial,
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      _calculatePoin();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_estimasiPoin <= 0 && _selectedJenisId != null) {
      ErrorHandler.showWarning('Estimasi poin 0 atau tidak valid. Cek jam input.');
      return;
    }

    final provider = context.read<PoinProvider>();
    if ((provider.totalPoin ?? 0) < _estimasiPoin) {
      ErrorHandler.showWarning('Saldo poin tidak mencukupi');
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    String timeCustom = "";
    if (_selectedTime != null) {
      timeCustom = "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";
    }

    String? jamMasuk, jamPulang;
    String labelJenis = _jenisOptions.firstWhere((e) => e['id'] == _selectedJenisId)['label'];
    String keterangan = "[$formattedDate] - $labelJenis";

    if (_selectedJenisId == 4) {
      jamMasuk = timeCustom;
      keterangan += " (Masuk $timeCustom)";
    } else if (_selectedJenisId == 5) {
      jamPulang = timeCustom;
      keterangan += " (Pulang $timeCustom)";
    } else if (_selectedJenisId == 6) {
      keterangan += " (Full Day)";
    }

    if (_alasanController.text.isNotEmpty) {
      keterangan += ": ${_alasanController.text}";
    }

    final result = await provider.tukarPoin(
      jumlah: _estimasiPoin,
      keterangan: keterangan,
      idPengurangan: _selectedJenisId!,
      jamMasukCustom: jamMasuk,
      jamPulangCustom: jamPulang,
    );

    if (!mounted) return;

    if (result['success']) {
      _showSuccessDialog();
    } else {
      ErrorHandler.showError(result['message'] ?? 'Gagal memproses permintaan');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppTheme.statusGreen, size: 64),
            const SizedBox(height: 16),
            Text("Pengajuan Berhasil!", style: AppTheme.heading3),
            const SizedBox(height: 8),
            Text(
              "Poin Anda telah dipotong sebesar $_estimasiPoin poin.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "OK",
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PoinProvider>();
    final totalPoin = provider.totalPoin ?? 0;

    String infoShift = "-";
    if (provider.shiftStart != null && provider.shiftEnd != null) {
      final s = provider.shiftStart!;
      final e = provider.shiftEnd!;
      infoShift = "${s.hour.toString().padLeft(2,'0')}:${s.minute.toString().padLeft(2,'0')} - ${e.hour.toString().padLeft(2,'0')}:${e.minute.toString().padLeft(2,'0')}";
      if (provider.namaShift != null) infoShift += " (${provider.namaShift})";
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Pengajuan Poin", style: AppTheme.heading3),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pushNamed(context, '/poin/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDark, Color(0xFF334155)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Saldo Poin Aktif", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("$totalPoin", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.stars_rounded, color: AppTheme.statusYellow, size: 32),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text("Tanggal Penggunaan", style: AppTheme.labelMedium),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                            ? "Pilih Tanggal..."
                            : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate!),
                          style: TextStyle(
                            color: _selectedDate == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.calendar_month, color: AppTheme.primaryDark),
                    ],
                  ),
                ),
              ),

              if (provider.isLoading) ...[
                const SizedBox(height: 32),
                const Center(child: CircularProgressIndicator()),
              ] else if (_isScheduleChecked) ...[

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_filled, color: AppTheme.primaryDark),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Jadwal Kerja Anda", style: AppTheme.labelMedium),
                            Text(infoShift, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text("Keperluan", style: AppTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedJenisId,
                      hint: Text("Pilih keperluan...", style: TextStyle(color: AppTheme.textSecondary)),
                      isExpanded: true,
                      items: _jenisOptions.map((item) => DropdownMenuItem<int>(
                        value: item['id'] as int,
                        child: Text(item['label'] as String),
                      )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedJenisId = val;
                          _selectedTime = null;
                        });
                        if (val == 6) _calculatePoin();
                        else _estimasiPoin = 0;
                      },
                    ),
                  ),
                ),

                if (_selectedJenisId == 4 || _selectedJenisId == 5) ...[
                  const SizedBox(height: 16),
                  Text(
                    _selectedJenisId == 4 ? "Jam Berapa Akan Masuk?" : "Jam Berapa Akan Pulang?",
                    style: AppTheme.labelMedium
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.shadowSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime == null
                              ? "-- : --"
                              : "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedTime == null ? FontWeight.normal : FontWeight.bold,
                              color: _selectedTime == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                            ),
                          ),
                          Icon(Icons.schedule, color: _selectedTime == null ? AppTheme.textSecondary : AppTheme.primaryDark),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                if (_estimasiPoin > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (totalPoin >= _estimasiPoin) ? AppTheme.statusGreen.withValues(alpha: 0.1) : AppTheme.statusRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: (totalPoin >= _estimasiPoin) ? AppTheme.statusGreen.withValues(alpha: 0.3) : AppTheme.statusRed.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text("Poin yang Dibutuhkan", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "$_estimasiPoin Poin",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: (totalPoin >= _estimasiPoin) ? AppTheme.statusGreen : AppTheme.statusRed,
                          ),
                        ),
                        if (_perhitunganDetail != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _perhitunganDetail!,
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ],
                        if (totalPoin < _estimasiPoin)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "Saldo Poin Tidak Mencukupi",
                              style: TextStyle(color: AppTheme.statusRed, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                CustomTextField(
                  label: "Keterangan Tambahan (Opsional)",
                  controller: _alasanController,
                  maxLines: 2,
                ),

                const SizedBox(height: 32),

                CustomButton(
                  text: "Ajukan Penggunaan",
                  onPressed: (_estimasiPoin > 0 && totalPoin >= _estimasiPoin) ? _handleSubmit : null,
                  isLoading: provider.isLoading,
                  backgroundColor: (_estimasiPoin > 0 && totalPoin >= _estimasiPoin)
                      ? AppTheme.primaryDark
                      : AppTheme.bgInput,
                  textColor: (_estimasiPoin > 0 && totalPoin >= _estimasiPoin)
                      ? Colors.white
                      : AppTheme.textSecondary,
                ),

              ] else if (_selectedDate != null && !provider.isLoading) ...[
                 const SizedBox(height: 32),
                 Center(
                   child: Column(
                     children: [
                       Icon(Icons.event_busy, size: 48, color: AppTheme.textSecondary),
                       SizedBox(height: 16),
                       Text(
                         "Pilih tanggal lain untuk melihat jadwal.",
                         style: TextStyle(color: AppTheme.textSecondary),
                       ),
                     ],
                   ),
                 ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
