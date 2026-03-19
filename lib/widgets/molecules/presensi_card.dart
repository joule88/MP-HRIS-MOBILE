import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/marquee_text.dart';

enum PresensiType { datang, pulang }
enum PresensiStatus { belumWaktunya, waktunya, sudahAbsen, adaMasalah }

class PresensiCard extends StatefulWidget {
  final PresensiType type;
  final String? time;
  final PresensiStatus status;
  final String? statusText;
  final VoidCallback? onTap;

  const PresensiCard({
    Key? key,
    required this.type,
    this.time,
    this.status = PresensiStatus.belumWaktunya,
    this.statusText,
    this.onTap,
  }) : super(key: key);

  @override
  State<PresensiCard> createState() => _PresensiCardState();
}

class _PresensiCardState extends State<PresensiCard> with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupPulse();
  }

  @override
  void didUpdateWidget(PresensiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _pulseController?.dispose();
      _pulseController = null;
      _setupPulse();
    }
  }

  void _setupPulse() {
    if (widget.status == PresensiStatus.waktunya) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
      _pulseController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.status) {
      case PresensiStatus.belumWaktunya:
        return AppTheme.textTertiary;
      case PresensiStatus.waktunya:
        return AppTheme.primaryBlue;
      case PresensiStatus.sudahAbsen:
        return AppTheme.statusGreen;
      case PresensiStatus.adaMasalah:
        return AppTheme.statusRed;
    }
  }

  String get _statusLabel {
    if (widget.status == PresensiStatus.sudahAbsen || widget.status == PresensiStatus.adaMasalah) {
      if (widget.statusText != null && widget.statusText!.isNotEmpty) {
        return widget.statusText!;
      }
    }

    switch (widget.status) {
      case PresensiStatus.belumWaktunya:
        return "Belum Waktunya";
      case PresensiStatus.waktunya:
        return "Waktunya Absen!";
      case PresensiStatus.sudahAbsen:
        return "Tepat Waktu ✓";
      case PresensiStatus.adaMasalah:
        final isDatang = widget.type == PresensiType.datang;
        return isDatang ? "Terlambat" : "Pulang Awal";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDatang = widget.type == PresensiType.datang;
    final icon = isDatang ? Icons.login : Icons.logout;
    final label = isDatang ? "Presensi Datang" : "Presensi Pulang";
    final displayTime = widget.time ?? "--:--";

    Widget card = Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 50,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: _accentColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ScrollableText(
                        text: label,
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  displayTime,
                  style: AppTheme.heading2.copyWith(fontSize: 20, color: _accentColor),
                ),
                const SizedBox(height: 2),
                ScrollableText(
                  text: _statusLabel,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: 10,
                    color: _accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.status == PresensiStatus.waktunya && _pulseAnimation != null) {
      card = AnimatedBuilder(
        animation: _pulseAnimation!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(_pulseAnimation!.value * 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: child,
          );
        },
        child: card,
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: card,
    );
  }
}
