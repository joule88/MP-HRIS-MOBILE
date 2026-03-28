import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/error_handler.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../atoms/custom_button.dart';
import '../atoms/custom_text_field.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({Key? key}) : super(key: key);

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ErrorHandler.showWarning('Password baru tidak cocok');
        return;
      }

      final success = await context.read<AuthProvider>().changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
            _confirmPasswordController.text,
          );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ErrorHandler.showSuccess('Password berhasil diubah');
        }
      } else {
        if (mounted) {
          final error = context.read<AuthProvider>().errorMessage;
          ErrorHandler.showError(error ?? 'Gagal mengubah password');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ubah Password", style: AppTheme.heading3),
              const SizedBox(height: AppTheme.spacingMd),
              CustomTextField(
                controller: _currentPasswordController,
                label: "Password Saat Ini",
                isPassword: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              CustomTextField(
                controller: _newPasswordController,
                label: "Password Baru",
                isPassword: true,
                validator: (value) =>
                    value == null || value.length < 8 ? "Minimal 8 karakter" : null,
              ),
              const SizedBox(height: AppTheme.spacingSm),
              CustomTextField(
                controller: _confirmPasswordController,
                label: "Konfirmasi Password Baru",
                isPassword: true,
                validator: (value) =>
                    value == null || value.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: Text("Batal", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Flexible(
                    child: CustomButton(
                      text: "Simpan",
                      isLoading: isLoading,
                      onPressed: _handleSubmit,
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
