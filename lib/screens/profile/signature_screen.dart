import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hand_signature/signature.dart';
import '../../core/theme.dart';
import '../../providers/signature_provider.dart';
import '../../widgets/atoms/custom_button.dart';

class SignatureScreen extends StatefulWidget {
  final bool isOnboarding;

  const SignatureScreen({this.isOnboarding = false, Key? key}) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late HandSignatureControl _signatureController;
  bool _isScrollable = true;


  @override
  void initState() {
    super.initState();
    _signatureController = HandSignatureControl(
      threshold: 0.1, // Meningkatkan sensitivitas dari 0.5
      smoothRatio: 0.6, // Penyesuaian kehalusan garis (0.6 - 0.7 biasanya ideal)
      velocityRange: 2.0, // Memberikan variasi ketebalan yang lebih alami
    );

    // Hapus listener setState yang dipanggil setiap kali menggambar karena menyebabkan lag
    // _signatureController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignatureProvider>().fetchSignature();
    });
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  bool get _hasDrawing => _signatureController.paths.isNotEmpty;

  void _clearCanvas() {
    _signatureController.clear();
    setState(() {});
  }

  Future<Uint8List?> _captureCanvas() async {
    try {
      // If we want PNG, hand_signature has a way to export to image
      final picture = _signatureController.toPicture(
        width: 1080,
        height: 720,
        color: const Color(0xFF1E293B),
        strokeWidth: 4.5,
      );

      
      final image = await picture?.toImage(1080, 720);
      if (image == null) return null;
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('[Signature] Capture error: $e');
      return null;
    }
  }

  Future<void> _saveSignature() async {
    if (!_hasDrawing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan gambar tanda tangan terlebih dahulu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final imageBytes = await _captureCanvas();
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengkonversi tanda tangan'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      print('[Signature] Image bytes: ${imageBytes.length}');

      if (mounted) {
        final provider = context.read<SignatureProvider>();
        final success = await provider.uploadSignature(imageBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Tanda tangan berhasil disimpan!'
                  : provider.errorMessage ?? 'Gagal menyimpan'),
              backgroundColor: success ? AppTheme.statusGreen : AppTheme.statusRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (success) {
            if (widget.isOnboarding && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              _clearCanvas();
            }
          }
        }
      }
    } catch (e) {
      print('[Signature] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.statusRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteSignature() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: Text("Hapus Tanda Tangan?", style: AppTheme.heading3),
        content: const Text("Tanda tangan aktif akan dihapus. Anda perlu membuat yang baru."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal", style: AppTheme.labelLarge.copyWith(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Hapus", style: AppTheme.labelLarge.copyWith(color: AppTheme.statusRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<SignatureProvider>().deleteSignature();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Tanda tangan berhasil dihapus' : 'Gagal menghapus'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        title: Text("Tanda Tangan Digital", style: AppTheme.heading3),
        backgroundColor: AppTheme.bgWhite,
        elevation: 0,
        centerTitle: true,
        leading: widget.isOnboarding
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Consumer<SignatureProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.currentSignature == null && !_hasDrawing) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: _isScrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppTheme.spacingMd),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TANDA TANGAN AKTIF",
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: provider.currentSignature != null
                            ? Column(
                                children: [
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppTheme.bgCard,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: provider.currentSignature!.fileTtd,
                                      fit: BoxFit.contain,
                                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      errorWidget: (_, __, ___) => const Icon(Icons.error_outline, color: AppTheme.textTertiary),
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: _deleteSignature,
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      label: const Text("Hapus & Buat Baru"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.statusRed,
                                        side: const BorderSide(color: AppTheme.statusRed),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Icon(Icons.draw_outlined, size: 48, color: AppTheme.textTertiary),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  Text("Belum ada tanda tangan", style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary)),
                                  const SizedBox(height: 4),
                                  Text("Buat tanda tangan di bawah", style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary)),
                                ],
                              ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      Text(
                        "BUAT TANDA TANGAN",
                        style: AppTheme.labelMedium.copyWith(
                          color: AppTheme.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          boxShadow: AppTheme.shadowSm,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusSm - 1),
                                    child: RepaintBoundary(
                                      child: HandSignature(
                                        control: _signatureController,
                                        color: const Color(0xFF1E293B),
                                        width: 2.5,
                                        maxWidth: 5.5,
                                        type: SignatureDrawType.shape,
                                        onPointerDown: () => setState(() => _isScrollable = false),
                                        onPointerUp: () => setState(() => _isScrollable = true),
                                      ),
                                    ),

                                  ),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                              child: Text(
                                "Gambar tanda tangan Anda di area di atas",
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: AppTheme.spacingMd),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, 0, AppTheme.spacingMd, AppTheme.spacingMd),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _clearCanvas,
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text("Hapus"),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.textSecondary,
                                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingMd),
                                  Expanded(
                                    flex: 2,
                                    child: CustomButton(
                                      text: "Simpan",
                                      icon: Icons.save,
                                      isLoading: provider.isLoading,
                                      onPressed: provider.isLoading ? null : _saveSignature,
                                      type: ButtonType.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
