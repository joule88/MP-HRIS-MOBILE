
import 'package:flutter/material.dart';

class ScannerOverlay extends StatefulWidget {
  final Color borderColor;
  final bool isScanning;

  const ScannerOverlay({
    super.key,
    required this.borderColor,
    this.isScanning = true,
  });

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isScanning) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0.5; // stop at middle or fade out
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ScannerPainter(
            borderColor: widget.borderColor,
            scanValue: _scanAnimation.value,
            isScanning: widget.isScanning,
          ),
        );
      },
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final Color borderColor;
  final double scanValue;
  final bool isScanning;

  _ScannerPainter({
    required this.borderColor,
    required this.scanValue,
    required this.isScanning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw darkened overlay with rounded rectangle cutout
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.75);
    
    final rectWidth = size.width * 0.75;
    // Portrait scanning area (a bit taller than wider)
    final rectHeight = size.height * 0.45;
    final center = Offset(size.width / 2, size.height / 2);
    
    final scannerRect = Rect.fromCenter(
      center: center,
      width: rectWidth,
      height: rectHeight,
    );
    
    final borderRadius = 30.0;
    final rRect = RRect.fromRectAndRadius(scannerRect, Radius.circular(borderRadius));

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(rRect)..close(),
      ),
      overlayPaint,
    );

    // 2. Draw modern corner brackets
    final bracketPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final double length = 40.0;
    
    final left = scannerRect.left;
    final right = scannerRect.right;
    final top = scannerRect.top;
    final bottom = scannerRect.bottom;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(left, top + length)
        ..lineTo(left, top + borderRadius)
        ..quadraticBezierTo(left, top, left + borderRadius, top)
        ..lineTo(left + length, top),
      bracketPaint,
    );
    
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(right, top + length)
        ..lineTo(right, top + borderRadius)
        ..quadraticBezierTo(right, top, right - borderRadius, top)
        ..lineTo(right - length, top),
      bracketPaint,
    );
    
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(left, bottom - length)
        ..lineTo(left, bottom - borderRadius)
        ..quadraticBezierTo(left, bottom, left + borderRadius, bottom)
        ..lineTo(left + length, bottom),
      bracketPaint,
    );
    
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - length)
        ..lineTo(right, bottom - borderRadius)
        ..quadraticBezierTo(right, bottom, right - borderRadius, bottom)
        ..lineTo(right - length, bottom),
      bracketPaint,
    );

    // 3. Draw scanning laser line inside the rounded rect
    if (isScanning) {
      canvas.save();
      canvas.clipPath(Path()..addRRect(rRect));

      final scanLineY = top + (rectHeight * scanValue);
      
      final linePaint = Paint()
        ..color = borderColor.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawLine(
        Offset(left, scanLineY),
        Offset(right, scanLineY),
        linePaint,
      );
      
      // Draw gradient glow under the line
      final glowHeight = 40.0;
      final glowRect = Rect.fromLTRB(left, scanLineY - glowHeight, right, scanLineY);
      final glowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            borderColor.withOpacity(0.0),
            borderColor.withOpacity(0.3),
          ],
        ).createShader(glowRect);
        
      canvas.drawRect(glowRect, glowPaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) {
    return oldDelegate.scanValue != scanValue ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.isScanning != isScanning;
  }
}
