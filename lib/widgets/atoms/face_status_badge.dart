
import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum FaceStatus { pending, approved, rejected, notEnrolled }

class FaceStatusBadge extends StatelessWidget {
  final FaceStatus status;

  const FaceStatusBadge({
    Key? key,
    this.status = FaceStatus.notEnrolled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case FaceStatus.approved:
        bgColor = AppTheme.statusGreen.withOpacity(0.1);
        textColor = AppTheme.statusGreen;
        icon = Icons.check_circle;
        text = "Wajah Terverifikasi";
        break;
      case FaceStatus.pending:
        bgColor = AppTheme.statusYellow.withOpacity(0.1);
        textColor = AppTheme.statusYellow;
        icon = Icons.access_time;
        text = "Menunggu Verifikasi";
        break;
      case FaceStatus.rejected:
        bgColor = AppTheme.statusRed.withOpacity(0.1);
        textColor = AppTheme.statusRed;
        icon = Icons.cancel;
        text = "Verifikasi Ditolak";
        break;
      case FaceStatus.notEnrolled:
      default:
        bgColor = AppTheme.textSecondary.withOpacity(0.1);
        textColor = AppTheme.textSecondary;
        icon = Icons.face;
        text = "Belum Ada Data Wajah";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: AppTheme.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
