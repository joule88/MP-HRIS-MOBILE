import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/atoms/custom_text_field.dart';
import '../../widgets/atoms/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthProvider>().login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().errorMessage ?? "Login Failed"),
            backgroundColor: AppTheme.statusRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Center(
             child: SingleChildScrollView(
               child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppTheme.spacingXl),

                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: const Icon(
                        Icons.diamond_outlined,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      "MPG HRIS",
                      style: AppTheme.heading2.copyWith(letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sistem Informasi SDM",
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                    ),

                    const SizedBox(height: AppTheme.spacingXxl),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Masuk ke Akun",
                        style: AppTheme.heading3,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    
                    CustomTextField(
                      label: "Email",
                      hint: "Masukkan Email Anda",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Email tidak boleh kosong';
                         }
                         return null;
                      },
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    
                    CustomTextField(
                      label: "Password",
                      hint: "Masukkan Password",
                      controller: _passwordController,
                      isPassword: true,
                       validator: (value) {
                         if (value == null || value.isEmpty) {
                           return 'Password tidak boleh kosong';
                         }
                         return null;
                      },
                    ),
                    
                    const SizedBox(height: AppTheme.spacingXl),
                    
                    CustomButton(
                      text: "Masuk",
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                      type: ButtonType.primary,
                    ),

                    const SizedBox(height: AppTheme.spacingXl),
                  ],
                ),
               ),
             ),
          ),
        ),
      ),
    );
  }
}
