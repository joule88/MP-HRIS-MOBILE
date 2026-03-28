import 'package:flutter/material.dart';

class ErrorHandler {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSuccess(String message, {int durationSeconds = 3}) {
    _show(
      message: message,
      icon: Icons.check_circle_rounded,
      bgColor: const Color(0xFF10b981),
      durationSeconds: durationSeconds,
    );
  }

  static void showError(String message, {int durationSeconds = 4}) {
    _show(
      message: message,
      icon: Icons.error_rounded,
      bgColor: const Color(0xFFef4444),
      durationSeconds: durationSeconds,
      showClose: true,
    );
  }

  static void showWarning(String message, {int durationSeconds = 3}) {
    _show(
      message: message,
      icon: Icons.warning_amber_rounded,
      bgColor: const Color(0xFFf59e0b),
      durationSeconds: durationSeconds,
    );
  }

  static void showInfo(String message, {int durationSeconds = 3}) {
    _show(
      message: message,
      icon: Icons.info_rounded,
      bgColor: const Color(0xFF3b82f6),
      durationSeconds: durationSeconds,
    );
  }

  static void _show({
    required String message,
    required IconData icon,
    required Color bgColor,
    int durationSeconds = 3,
    bool showClose = false,
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 6,
        duration: Duration(seconds: durationSeconds),
        action: showClose
            ? SnackBarAction(
                label: 'Tutup',
                textColor: Colors.white.withValues(alpha: 0.9),
                onPressed: () {
                  scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }
}
