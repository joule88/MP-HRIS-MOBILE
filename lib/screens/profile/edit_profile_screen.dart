import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/atoms/custom_avatar.dart';
import '../../widgets/atoms/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noTelpController;
  late TextEditingController _alamatController;
  File? _selectedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _noTelpController = TextEditingController(text: user?.noTelp ?? '');
    _alamatController = TextEditingController(text: user?.alamat ?? '');
  }

  @override
  void dispose() {
    _noTelpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _selectedPhoto = File(picked.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updateProfile(
      noTelp: _noTelpController.text.trim(),
      alamat: _alamatController.text.trim(),
      foto: _selectedPhoto,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
          backgroundColor: AppTheme.statusGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal memperbarui profil'),
          backgroundColor: AppTheme.statusRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text("Edit Profil", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacingMd),

              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    if (_selectedPhoto != null)
                      ClipOval(
                        child: Image.file(
                          _selectedPhoto!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      CustomAvatar(
                        imageUrl: user?.foto ?? "https://avatar.iran.liara.run/public/35",
                        size: 100,
                        name: user?.namaLengkap ?? '',
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Ketuk untuk ganti foto",
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INFORMASI YANG DAPAT DIUBAH",
                      style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.textTertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),

                    Text("No. Telepon", style: AppTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noTelpController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Masukkan nomor telepon",
                        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                        prefixIcon: const Icon(Icons.phone_outlined, color: AppTheme.textSecondary, size: 20),
                        filled: true,
                        fillColor: AppTheme.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length < 8) {
                          return 'Nomor telepon minimal 8 digit';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    Text("Alamat", style: AppTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _alamatController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Masukkan alamat lengkap",
                        hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.location_on_outlined, color: AppTheme.textSecondary, size: 20),
                        ),
                        filled: true,
                        fillColor: AppTheme.bgInput,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.primaryDark.withValues(alpha: 0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && value.length > 500) {
                          return 'Alamat maksimal 500 karakter';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppTheme.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Untuk mengubah nama, email, divisi, atau jabatan, silakan hubungi HRD.",
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: "Simpan Perubahan",
                  onPressed: _isSaving ? null : _saveProfile,
                  isLoading: _isSaving,
                  type: ButtonType.primary,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
