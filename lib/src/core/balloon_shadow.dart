import 'package:flutter/material.dart';

sealed class BalloonShadow {
  /// same with [MaterialBalloonShadow]
  ///
  /// [elevation] is the z-coordinate at which to place this shadow.
  ///
  /// [shadowColor] is the color of the shadow.
  ///
  /// see also: [MaterialBalloonShadow]
  factory BalloonShadow.material(
      {double elevation = 4, Color shadowColor = Colors.black26}) {
    return MaterialBalloonShadow(
        elevation: elevation, shadowColor: shadowColor);
  }

  /// Custom shadow.
  ///
  /// [shadows] is a similar api with Container's `BoxDecoration.boxShadow`.
  ///
  /// see also: [CustomBalloonShadow]
  factory BalloonShadow.custom({required List<BoxShadow> shadows}) {
    return CustomBalloonShadow(shadows: shadows);
  }

  void _renderShadows(Canvas canvas, Path path, Size size);
}

/// it provide [material elevation shadow](https://m3.material.io/styles/elevation/overview)
///
/// [elevation] is the z-coordinate at which to place this shadow.
///
/// [shadowColor] is the color of the shadow.
class MaterialBalloonShadow implements BalloonShadow {
  /// The z-coordinate at which to place this shadow.
  final double elevation;

  /// The color of the shadow.
  ///
  /// it doesn't show raw color.
  ///
  /// it shows shadow color with different alpha value by each elevation value.
  /// (if you want to know what color is rendered, see [elevation reference](https://pub.dev/documentation/shadows/latest/shadows/Elevation-class.html))
  final Color shadowColor;

  const MaterialBalloonShadow({
    this.elevation = 4,
    this.shadowColor = Colors.black26,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialBalloonShadow &&
          runtimeType == other.runtimeType &&
          elevation == other.elevation &&
          shadowColor == other.shadowColor;

  @override
  int get hashCode => elevation.hashCode ^ shadowColor.hashCode;

  @override
  String toString() {
    return 'MaterialBalloonShadow{elevation: $elevation, shadowColor: $shadowColor}';
  }

  @override
  void _renderShadows(Canvas canvas, Path path, Size size) {
    if (elevation > 0) {
      canvas.drawShadow(path, shadowColor, elevation, true);
    }
  }
}

/// Custom shadow.
///
/// [shadows] is a similar api with Container's `BoxDecoration.boxShadow`.
///
/// It can be customized with offset, blurRadius, spreadRadius, and color.
///
/// and support multiple shadows.
///
/// see also: [BoxShadow](https://api.flutter.dev/flutter/painting/BoxShadow-class.html)
class CustomBalloonShadow implements BalloonShadow {
  final List<BoxShadow> shadows;

  const CustomBalloonShadow({required this.shadows});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is CustomBalloonShadow && runtimeType == other.runtimeType) {
      if (shadows.length != other.shadows.length) return false;
      for (int i = 0; i < shadows.length; i++) {
        if (shadows[i] != other.shadows[i]) return false;
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => shadows.hashCode;

  @override
  String toString() {
    return 'CustomBalloonShadow{shadows: $shadows}';
  }

  @override
  void _renderShadows(Canvas canvas, Path path, Size size) {
    for (final boxShadow in shadows) {
      final shadowPath = path.shift(boxShadow.offset);
      final shadowPaint = Paint()
        ..color = boxShadow.color
        ..maskFilter = boxShadow.blurRadius > 0
            ? MaskFilter.blur(BlurStyle.normal, boxShadow.blurRadius * 0.5)
            : const MaskFilter.blur(BlurStyle.solid, 0);

      Path adjustedPath = shadowPath;
      if (boxShadow.spreadRadius != 0) {
        adjustedPath =
            _adjustPathSpread(shadowPath, boxShadow.spreadRadius, size);
      }

      canvas.drawPath(adjustedPath, shadowPaint);
    }
  }

  Path _adjustPathSpread(Path path, double spreadRadius, Size size) {
    final Matrix4 matrix = Matrix4.identity();
    final double scaleX = 1 + spreadRadius / size.width;
    final double scaleY = 1 + spreadRadius / size.height;
    matrix.scale(scaleX, scaleY);
    final Path adjustedPath = path.transform(matrix.storage);
    return adjustedPath;
  }
}

class ShadowRenderer {
  final BalloonShadow strategy;

  ShadowRenderer({required this.strategy});

  void renderShadows(Canvas canvas, Path path, Size size) {
    strategy._renderShadows(canvas, path, size);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowRenderer &&
          runtimeType == other.runtimeType &&
          strategy == other.strategy;

  @override
  int get hashCode => strategy.hashCode ^ runtimeType.hashCode;
}