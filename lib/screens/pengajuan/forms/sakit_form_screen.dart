import 'package:flutter/material.dart';
import '../../../core/error_handler.dart';
import '../../../core/theme.dart';
import '../../../widgets/atoms/custom_button.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../providers/pengajuan_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class SakitFormScreen extends StatefulWidget {
  const SakitFormScreen({Key? key}) : super(key: key);

  @override
  State<SakitFormScreen> createState() => _SakitFormScreenState();
}

class _SakitFormScreenState extends State<SakitFormScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _diagnosisController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _uploadedFilePath;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().checkSignatureStatus();
    });
  }

  int get _duration {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _isFileRequired => _duration >= 2;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_startDate == null || _endDate == null || _diagnosisController.text.isEmpty) {
      ErrorHandler.showWarning('Tanggal dan diagnosis wajib diisi');
      return;
    }

    if (_isFileRequired && _uploadedFilePath == null) {
      ErrorHandler.showWarning('Surat dokter wajib untuk sakit ≥ 2 hari');
      return;
    }

    final success = await context.read<PengajuanProvider>().submitSakit({
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(_startDate!),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(_endDate!),
      'alasan': _diagnosisController.text,
      'bukti_file': _uploadedFilePath,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ErrorHandler.showSuccess('Pengajuan Sakit Berhasil');
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
      helpText: "Pilih Tanggal Mulai Sakit",
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

  Future<void> _selectEndDate() async {
    final DateTime initialDate = _startDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? initialDate,
      firstDate: initialDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: "Pilih Tanggal Selesai",
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedFilePath = result.files.single.path;
          _uploadedFileName = result.files.single.name;
        });

        if (mounted) {
          ErrorHandler.showInfo('File dipilih: ${result.files.single.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError('Gagal memilih file');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pengajuanProvider = context.watch<PengajuanProvider>();
    final hasSignature = pengajuanProvider.hasSignature;
    final isLoading = pengajuanProvider.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Form Sakit", style: AppTheme.heading3),
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
                        "Anda belum membuat tanda tangan digital. Silakan buat di menu Profil sebelum mengajukan sakit.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.statusRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: "Tanggal Mulai",
                    controller: _startDateController,
                    readOnly: true,
                    onTap: _selectStartDate,
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
                    onTap: _selectEndDate,
                    suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
                    hint: "Pilih Tanggal",
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingLg),

            CustomTextField(
              label: "Diagnosis / Keluhan",
              controller: _diagnosisController,
              maxLines: 3,
              hint: "Contoh: Demam tinggi, flu, sakit kepala...",
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text("Surat Dokter", style: AppTheme.labelLarge),
            const SizedBox(height: AppTheme.spacingSm),

            if (_startDate != null && _endDate != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isFileRequired
                      ? AppTheme.statusOrange.withValues(alpha: 0.1)
                      : AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFileRequired ? Icons.warning_amber_outlined : Icons.info_outline,
                      size: 20,
                      color: _isFileRequired ? AppTheme.statusOrange : AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isFileRequired
                            ? "WAJIB: Surat dokter diperlukan untuk sakit ≥ 2 hari ($_duration hari)"
                            : "Opsional: Surat dokter untuk sakit 1 hari",
                        style: AppTheme.bodySmall.copyWith(
                          color: _isFileRequired ? AppTheme.statusOrange : AppTheme.primaryBlue,
                          fontWeight: _isFileRequired ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],

            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _uploadedFileName != null ? AppTheme.statusGreen.withValues(alpha: 0.5) : AppTheme.bgCard,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  color: _uploadedFileName != null
                      ? AppTheme.statusGreen.withValues(alpha: 0.05)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      _uploadedFileName != null ? Icons.check_circle : Icons.upload_file,
                      color: _uploadedFileName != null ? AppTheme.statusGreen : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _uploadedFileName ?? "Pilih file (PDF, JPG, PNG)",
                        style: AppTheme.bodyMedium.copyWith(
                          color: _uploadedFileName != null ? AppTheme.statusGreen : AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_uploadedFileName != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _uploadedFileName = null;
                          _uploadedFilePath = null;
                        }),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            CustomButton(
              text: "Ajukan Sakit",
              onPressed: hasSignature ? _handleSubmit : null,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
