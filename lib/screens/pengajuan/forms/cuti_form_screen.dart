import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../widgets/atoms/custom_button.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../providers/pengajuan_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CutiFormScreen extends StatefulWidget {
  const CutiFormScreen({Key? key}) : super(key: key);

  @override
  State<CutiFormScreen> createState() => _CutiFormScreenState();
}

class _CutiFormScreenState extends State<CutiFormScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().checkSignatureStatus();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field wajib diisi")),
      );
      return;
    }

    final success = await context.read<PengajuanProvider>().submitCuti({
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(_startDate!),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(_endDate!),
      'alasan': _reasonController.text,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengajuan Cuti Berhasil")),
      );
    }
  }

  Future<void> _selectStartDate(DateTime minDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: minDate,
      firstDate: minDate,
      lastDate: DateTime(2100),
      helpText: "Pilih Tanggal Mulai",
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd MMM yyyy').format(picked);

        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
           _endDateController.text = DateFormat('dd MMM yyyy').format(picked);
        }
      });
    }
  }

  Future<void> _selectEndDate(DateTime minDate) async {
    final DateTime initialDate = _startDate ?? minDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2100),
      helpText: "Pilih Tanggal Selesai",
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengajuanProvider = context.watch<PengajuanProvider>();
    final hasSignature = pengajuanProvider.hasSignature;
    final isLoading = pengajuanProvider.isLoading;
    final DateTime minDate = DateTime.now().add(const Duration(days: 7));

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Form Cuti", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!hasSignature)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.statusRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.statusRed),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Anda belum membuat tanda tangan digital. Silakan buat di menu Profil sebelum mengajukan cuti.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.statusRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Cuti harus diajukan minimal 7 hari sebelum tanggal mulai",
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Tanggal Mulai",
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _selectStartDate(minDate),
                    suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
                    hint: "Pilih Tanggal",
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: CustomTextField(
                    label: "Tanggal Selesai",
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _selectEndDate(minDate),
                    suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
                    hint: "Pilih Tanggal",
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            CustomTextField(
              label: "Keterangan",
              controller: _reasonController,
              maxLines: 4,
              hint: "Alasan mengajukan cuti...",
            ),

            const SizedBox(height: AppTheme.spacingXl),

            CustomButton(
              text: "Ajukan Cuti",
              onPressed: hasSignature ? _handleSubmit : null,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
