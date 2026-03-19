import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../widgets/atoms/custom_button.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../providers/pengajuan_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class IzinFormScreen extends StatefulWidget {
  const IzinFormScreen({Key? key}) : super(key: key);

  @override
  State<IzinFormScreen> createState() => _IzinFormScreenState();
}

class _IzinFormScreenState extends State<IzinFormScreen> {
  final _dateController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime? _selectedDate;
  String? _uploadedFilePath;
  String? _uploadedFileName;
  String? _dateError;
  String? _reasonError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengajuanProvider>().checkSignatureStatus();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      _dateError = _selectedDate == null ? 'Pilih tanggal izin' : null;
      _reasonError = _reasonController.text.isEmpty ? 'Keperluan tidak boleh kosong' : null;
    });

    if (_selectedDate == null || _reasonController.text.isEmpty) {
      return;
    }

    final success = await context.read<PengajuanProvider>().submitIzin({
      'tanggal_mulai': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'tanggal_selesai': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      'alasan': _reasonController.text,
      'bukti_file': _uploadedFilePath,
    });

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengajuan Izin Berhasil")),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      helpText: "Pilih Tanggal Izin",
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd MMMM yyyy').format(picked);
        _dateError = null;
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File dipilih: ${result.files.single.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih file')),
        );
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
        title: Text("Form Izin", style: AppTheme.heading3),
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
                        "Anda belum membuat tanda tangan digital. Silakan buat di menu Profil sebelum mengajukan izin.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.statusRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

            CustomTextField(
              label: "Tanggal Izin",
              controller: _dateController,
              readOnly: true,
              onTap: _selectDate,
              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryBlue),
              hint: "Pilih tanggal izin",
              errorText: _dateError,
            ),

            const SizedBox(height: AppTheme.spacingLg),

            CustomTextField(
              label: "Keperluan",
              controller: _reasonController,
              maxLines: 4,
              hint: "Contoh: Keperluan keluarga, urusan pribadi...",
              errorText: _reasonError,
              onChanged: (val) {
                if (_reasonError != null && val.isNotEmpty) {
                  setState(() => _reasonError = null);
                }
              },
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text("Lampiran Pendukung", style: AppTheme.labelLarge),
            const SizedBox(height: AppTheme.spacingSm),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Upload surat izin atau dokumen pendukung (opsional)",
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

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
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => setState(() {
                          _uploadedFileName = null;
                          _uploadedFilePath = null;
                        }),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            CustomButton(
              text: "Ajukan Izin",
              onPressed: hasSignature ? _handleSubmit : null,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
