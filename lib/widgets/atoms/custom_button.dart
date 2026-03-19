import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../atoms/bouncy_tap.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color txtColor;
    Color borderColor;

    switch (type) {
      case ButtonType.primary:
        bgColor = backgroundColor ?? AppTheme.primaryDark;
        txtColor = textColor ?? Colors.white;
        borderColor = Colors.transparent;
        break;
      case ButtonType.secondary:
        bgColor = AppTheme.primaryOrange;
        txtColor = textColor ?? Colors.white;
        borderColor = Colors.transparent;
        break;
      case ButtonType.outline:
        bgColor = Colors.transparent;
        txtColor = textColor ?? AppTheme.primaryDark;
        borderColor = AppTheme.primaryDark;
        break;
      case ButtonType.text:
        bgColor = Colors.transparent;
        txtColor = textColor ?? AppTheme.primaryDark;
        borderColor = Colors.transparent;
        break;
    }

    if (onPressed == null) {
      bgColor = bgColor.withOpacity(0.5);
      txtColor = txtColor.withOpacity(0.5);
      if (type == ButtonType.outline) {
        borderColor = borderColor.withOpacity(0.5);
      }
    }

    Widget content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.outline || type == ButtonType.text
                    ? AppTheme.primaryDark
                    : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: txtColor, size: 20),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  style: AppTheme.labelLarge.copyWith(color: txtColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final bool isDisabled = isLoading || onPressed == null;

    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: txtColor,
        disabledBackgroundColor: bgColor,
        disabledForegroundColor: txtColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          side: type == ButtonType.outline
              ? BorderSide(color: borderColor, width: 1.5)
              : BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      ),
      child: content,
    );

    return BouncyTap(
      onPressed: isDisabled ? null : () {},
      behavior: HitTestBehavior.deferToChild,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: !isDisabled && type == ButtonType.primary
              ? AppTheme.glowPrimary
              : null,
        ),
        child: button,
      ),
    );
  }
}
