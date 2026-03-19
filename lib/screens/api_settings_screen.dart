import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_config_service.dart';
import '../core/constants/api_url.dart';
import '../providers/auth_provider.dart';
import '../widgets/atoms/custom_button.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  String _selectedPreset = 'hostname';
  final TextEditingController _customUrlController = TextEditingController();
  bool _isLoading = false;
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() => _isLoading = true);
    try {
      final preset = await ApiConfigService.getCurrentPreset();
      final url = await ApiConfigService.getSavedUrl();
      setState(() {
        _selectedPreset = preset;
        _currentUrl = url;
        if (preset == 'custom' && url != null) {
          _customUrlController.text = url;
        }
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isLoading = true);
    try {
      if (_selectedPreset == 'custom') {
        final customUrl = _customUrlController.text.trim();
        if (customUrl.isEmpty) {
          _showMessage('Masukkan URL custom terlebih dahulu', isError: true);
          return;
        }

        if (!customUrl.startsWith('http://') && !customUrl.startsWith('https://')) {
          _showMessage('URL harus dimulai dengan http:// atau https://', isError: true);
          return;
        }

        await ApiConfigService.setCustomUrl(customUrl);
      } else {
        await ApiConfigService.setPreset(_selectedPreset);
      }

      await ApiUrl.reload();

      _showMessage('Konfigurasi API berhasil disimpan!');

      if (mounted) {
        final shouldRelogin = await _showConfirmDialog(
          'Koneksi API telah diubah. Apakah Anda ingin logout dan login kembali untuk memastikan koneksi baru berfungsi?',
        );

        if (shouldRelogin == true && mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          authProvider.logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    } catch (e) {
      _showMessage('Gagal menyimpan konfigurasi: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          CustomButton(
            text: 'Ya',
            type: ButtonType.primary,
            isFullWidth: false,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan API Server'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'URL Server Saat Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentUrl ?? 'Belum dikonfigurasi',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Pilih Konfigurasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildPresetOption(
                    value: 'hostname',
                    title: 'Hostname (Recommended)',
                    subtitle: 'LAPTOP-I0SUKSKL:8000\nTidak perlu ganti saat pindah WiFi',
                    icon: Icons.computer,
                    iconColor: Colors.green,
                  ),

                  _buildPresetOption(
                    value: 'emulator',
                    title: 'Android Emulator',
                    subtitle: '10.0.2.2:8000\nUntuk testing di emulator',
                    icon: Icons.phone_android,
                    iconColor: Colors.orange,
                  ),

                  _buildPresetOption(
                    value: 'custom',
                    title: 'Custom URL',
                    subtitle: 'Masukkan URL sendiri',
                    icon: Icons.edit,
                    iconColor: Colors.blue,
                  ),

                  if (_selectedPreset == 'custom') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL Server',
                        hintText: 'http://192.168.1.100:8000/api',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Contoh: http://192.168.1.6:8000/api',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Tips',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Gunakan "Hostname" agar tidak perlu ganti setting saat pindah WiFi\n'
                          '• Pastikan laptop dan HP terhubung ke WiFi yang sama\n'
                          '• Server Laravel harus running dengan: php artisan serve --host=0.0.0.0',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Simpan Konfigurasi',
                      onPressed: _isLoading ? null : _saveConfig,
                      isLoading: _isLoading,
                      type: ButtonType.primary,
                      backgroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPresetOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedPreset == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.black87 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.grey.shade50 : Colors.white,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPreset,
        onChanged: (newValue) {
          setState(() => _selectedPreset = newValue!);
        },
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        activeColor: Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _customUrlController.dispose();
    super.dispose();
  }
}
