import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/bouncy_tap.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const MenuCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.icon,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.bgCard;
    final iColor = iconColor ?? AppTheme.primaryBlue;

    return BouncyTap(
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowSm,
          border: Border.all(color: AppTheme.bgCard, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Stack(
            children: [
              if (icon != null)
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Icon(icon, size: 64, color: iColor.withValues(alpha: 0.08)),
                ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: iColor, size: 28),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: Text(title, style: AppTheme.heading3.copyWith(fontSize: 16), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    Text(subtitle, style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
