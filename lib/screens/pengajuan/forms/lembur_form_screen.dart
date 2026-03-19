import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../widgets/atoms/custom_text_field.dart';
import '../../../widgets/atoms/custom_button.dart';
import '../../../providers/pengajuan_provider.dart';
import 'package:provider/provider.dart';
import '../../../services/api_client.dart';

class LemburFormScreen extends StatefulWidget {
  const LemburFormScreen({Key? key}) : super(key: key);

  @override
  State<LemburFormScreen> createState() => _LemburFormScreenState();
}

class _LemburFormScreenState extends State<LemburFormScreen> {
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int? _selectedKompensasi;
  List<Map<String, dynamic>> _jenisKompensasi = [];

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchKompensasi();
  }

  Future<void> _fetchKompensasi() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get('/kompensasi');
      if (response.data['success'] == true) {
        setState(() {
          _jenisKompensasi = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
          if (_jenisKompensasi.isNotEmpty) {
            _selectedKompensasi = _jenisKompensasi[0]['id_kompensasi'];
          }
        });
      }
    } catch (e) {
      print('Error fetching kompensasi: $e');
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month - 1, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
       final success = await context.read<PengajuanProvider>().submitLembur({
        'date': _dateController.text,
        'start_time': _startTimeController.text,
        'end_time': _endTimeController.text,
        'reason': _reasonController.text,
        'id_kompensasi': _selectedKompensasi,
      });

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pengajuan Lembur Berhasil Disimpan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PengajuanProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Form Lembur", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Tanggal Lembur",
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(_dateController),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: [
                   Expanded(
                     child: CustomTextField(
                      label: "Jam Mulai",
                      controller: _startTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(_startTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                        validator: (v) => v!.isEmpty ? "Wajib" : null,
                    ),
                   ),
                   const SizedBox(width: AppTheme.spacingMd),
                   Expanded(
                     child: CustomTextField(
                      label: "Jam Selesai",
                      controller: _endTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(_endTimeController),
                      suffixIcon: const Icon(Icons.access_time),
                        validator: (v) => v!.isEmpty ? "Wajib" : null,
                    ),
                   ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              CustomTextField(
                label: "Keterangan Tugas",
                controller: _reasonController,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              if (_jenisKompensasi.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jenis Kompensasi",
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedKompensasi,
                          items: _jenisKompensasi.map((kompensasi) {
                            return DropdownMenuItem<int>(
                              value: kompensasi['id_kompensasi'],
                              child: Text(
                                kompensasi['nama_kompensasi'] ?? 'Unknown',
                                style: AppTheme.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKompensasi = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppTheme.spacingXl),
              CustomButton(
                text: "Ajukan Lembur",
                onPressed: _handleSubmit,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
