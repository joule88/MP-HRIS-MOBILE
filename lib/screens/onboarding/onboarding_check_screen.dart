import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/setup_check_provider.dart';
import 'face_enrollment_screen.dart';
import '../profile/signature_screen.dart';

class OnboardingCheckScreen extends StatefulWidget {
  const OnboardingCheckScreen({super.key});

  @override
  State<OnboardingCheckScreen> createState() => _OnboardingCheckScreenState();
}

class _OnboardingCheckScreenState extends State<OnboardingCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runCheck();
    });
  }

  Future<void> _runCheck() async {
    final provider = context.read<SetupCheckProvider>();
    await provider.checkSetup();

    if (!mounted) return;

    // Navigasi berdasarkan hasil pengecekan
    if (!provider.hasFace) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const FaceEnrollmentScreen(isOnboarding: true),
        ),
      );
    } else if (!provider.hasSignature) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SignatureScreen(isOnboarding: true),
        ),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  boxShadow: AppTheme.shadowMd,
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  size: 44,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Memeriksa kelengkapan akun...',
                style: AppTheme.bodySmall.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
