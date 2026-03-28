import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class CameraUtils {
  static InputImage inputImageFromCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required InputImageRotation rotation,
  }) {
    final allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final format = InputImageFormatUtils.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final inputImageMetadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }

  static InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
class InputImageFormatUtils {
  static InputImageFormat? fromRawValue(int rawValue) {
    switch (rawValue) {
      case 17:
        return InputImageFormat.nv21;
      case 35:
        return InputImageFormat.yuv420;
      case 842094169:
        return InputImageFormat.yv12;
      default:
        return null;
    }
  }
}
