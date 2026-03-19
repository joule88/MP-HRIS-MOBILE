import 'package:flutter/material.dart';
import '../../core/theme.dart';

enum BadgeType { cuti, sakit, izin, lembur, approved, pending, rejected }

class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeType type;
  final bool isSmall;

  const BadgeWidget({
    Key? key,
    required this.label,
    required this.type,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (type) {
      case BadgeType.cuti:
        bgColor = AppTheme.badgeCutiBg;
        textColor = AppTheme.badgeCutiText;
        break;
      case BadgeType.sakit:
        bgColor = AppTheme.badgeSakitBg;
        textColor = AppTheme.badgeSakitText;
        break;
      case BadgeType.izin:
        bgColor = AppTheme.badgeIzinBg;
        textColor = AppTheme.badgeIzinText;
        break;
      case BadgeType.lembur:
        bgColor = AppTheme.badgeLemburBg;
        textColor = AppTheme.badgeLemburText;
        break;
      case BadgeType.approved:
        bgColor = AppTheme.statusGreen.withOpacity(0.1);
        textColor = AppTheme.statusGreen;
        break;
      case BadgeType.pending:
        bgColor = AppTheme.statusYellow.withOpacity(0.1);
        textColor = AppTheme.statusYellow;
        break;
      case BadgeType.rejected:
        bgColor = AppTheme.statusRed.withOpacity(0.1);
        textColor = AppTheme.statusRed;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 2 : 6,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: isSmall ? 10 : 12,
        ),
      ),
    );
  }
}
