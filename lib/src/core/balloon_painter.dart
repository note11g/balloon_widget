import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'balloon_nip_position.dart';
import 'balloon_shadow.dart';

double calcNipHeight(double nipSize) {
  return nipSize / 2 * math.sqrt(2); // 45 degree triangle
}

double getRealNipHeight(double nipSize, double nipRadius) {
  final baseHeight = calcNipHeight(nipSize);
  // sin(45) = sqrt(2) / 2
  final radiusAdjustment = nipRadius * math.sqrt(2) / 2;
  return baseHeight - radiusAdjustment;
}

class BalloonNoSizeLayoutDelegate extends SingleChildLayoutDelegate {
  final BalloonNipPosition nipPosition;
  final double nipSize;
  final double nipMargin;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  BalloonNoSizeLayoutDelegate({
    required this.nipPosition,
    required this.nipSize,
    required this.nipMargin,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Size getSize(BoxConstraints constraints) {
    return const Size(1, 1);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final Offset nipOffset = _calculateNipOffset(childSize);
    return nipOffset * -1;
  }

  Offset _calculateNipOffset(Size childSize) {
    final Size(width: cw, height: ch) = childSize;
    final baseDx = (nipMargin + (nipSize / 2));

    final double dx = switch (nipPosition) {
      BalloonNipPosition.topCenter || BalloonNipPosition.bottomCenter => cw / 2,
      BalloonNipPosition.topLeft => borderRadius.topLeft.x + baseDx,
      BalloonNipPosition.bottomLeft => borderRadius.bottomLeft.x + baseDx,
      BalloonNipPosition.topRight => cw - (borderRadius.topRight.x + baseDx),
      BalloonNipPosition.bottomRight =>
        cw - (borderRadius.bottomRight.x + baseDx),
    };
    final double dy = nipPosition.isTop ? 0.0 : ch;
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(BalloonNoSizeLayoutDelegate oldDelegate) {
    return oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.padding != padding;
  }
}

class BalloonPainter extends CustomPainter {
  final Color color;
  final ShadowRenderer? shadowRenderer;
  final double nipSize;
  final BorderRadius borderRadius;
  final BalloonNipPosition nipPosition;
  final double nipMargin;
  final double nipRadius;

  BalloonPainter({
    required this.color,
    required this.shadowRenderer,
    required this.nipSize,
    required this.nipMargin,
    required this.borderRadius,
    required this.nipPosition,
    required this.nipRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = drawPath(
        size, calibrateBorderRadius(borderRadius: borderRadius, size: size));

    shadowRenderer?.renderShadows(canvas, path, size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  static BorderRadius calibrateBorderRadius(
      {required BorderRadius borderRadius, required Size size}) {
    final keySize = size.shortestSide;
    if (keySize >= borderRadius.topLeft.x + borderRadius.topRight.x &&
        keySize >= borderRadius.bottomLeft.x + borderRadius.bottomRight.x &&
        keySize >= borderRadius.topLeft.y + borderRadius.bottomLeft.y &&
        keySize >= borderRadius.topRight.y + borderRadius.bottomRight.y) {
      return borderRadius;
    }

    if (keySize == size.height) {
      // height가 가장 짧은 변인 경우. y를 기준으로 분배.
      final leftOriginalHeight =
          borderRadius.topLeft.y + borderRadius.bottomLeft.y;
      final correctTopLeft =
              keySize * (borderRadius.topLeft.y / leftOriginalHeight),
          correctBottomLeft =
              keySize * (borderRadius.bottomLeft.y / leftOriginalHeight);

      final rightOriginalHeight =
          borderRadius.topRight.y + borderRadius.bottomRight.y;
      final correctTopRight =
              keySize * (borderRadius.topRight.y / rightOriginalHeight),
          correctBottomRight =
              keySize * (borderRadius.bottomRight.y / rightOriginalHeight);

      return BorderRadius.only(
        topLeft: Radius.circular(correctTopLeft),
        topRight: Radius.circular(correctTopRight),
        bottomLeft: Radius.circular(correctBottomLeft),
        bottomRight: Radius.circular(correctBottomRight),
      );
    } else {
      // width가 가장 짧은 변인 경우. x를 기준으로 분배.
      final topOriginalHeight =
          borderRadius.topLeft.x + borderRadius.topRight.x;
      final correctTopLeft =
              keySize * (borderRadius.topLeft.x / topOriginalHeight),
          correctTopRight =
              keySize * (borderRadius.topRight.x / topOriginalHeight);

      final bottomOriginalHeight =
          borderRadius.bottomLeft.x + borderRadius.bottomRight.x;
      final correctBottomLeft =
              keySize * (borderRadius.bottomLeft.x / bottomOriginalHeight),
          correctBottomRight =
              keySize * (borderRadius.bottomRight.x / bottomOriginalHeight);

      return BorderRadius.only(
        topLeft: Radius.circular(correctTopLeft),
        topRight: Radius.circular(correctTopRight),
        bottomLeft: Radius.circular(correctBottomLeft),
        bottomRight: Radius.circular(correctBottomRight),
      );
    }
  }

  Path drawPath(Size size, BorderRadius borderRadius) {
    return createBalloonPath(
      size: size,
      borderRadius: borderRadius,
      nipPosition: nipPosition,
      nipSize: nipSize,
      nipMargin: nipMargin,
      nipRadius: nipRadius,
    );
  }

  @override
  bool shouldRepaint(BalloonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowRenderer != shadowRenderer ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipRadius != nipRadius ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// Shared balloon path creation logic used by both [BalloonPainter] and [BalloonGlassClipper].
///
/// Creates a balloon-shaped path including rounded corners and nip based on the provided parameters.
/// This function ensures consistent balloon shapes across painting and clipping operations.
Path createBalloonPath({
  required Size size,
  required BorderRadius borderRadius,
  required BalloonNipPosition nipPosition,
  required double nipSize,
  required double nipMargin,
  required double nipRadius,
}) {
  final topLeftRadius = borderRadius.topLeft,
      topRightRadius = borderRadius.topRight,
      bottomLeftRadius = borderRadius.bottomLeft,
      bottomRightRadius = borderRadius.bottomRight;

  final List<(Offset, Offset, Radius)> lines = [
    (
      Offset(topLeftRadius.x, 0),
      Offset(size.width - topRightRadius.x, 0),
      topRightRadius,
    ),
    (
      Offset(size.width, topRightRadius.y),
      Offset(size.width, size.height - bottomRightRadius.y),
      bottomRightRadius,
    ),
    (
      Offset(size.width - bottomRightRadius.x, size.height),
      Offset(bottomLeftRadius.x, size.height),
      bottomLeftRadius,
    ),
    (
      Offset(0, size.height - bottomLeftRadius.y),
      Offset(0, topLeftRadius.y),
      topLeftRadius,
    ),
  ];
  final nipLineIdx = nipPosition.isTop ? 0 : 2;

  final path = Path();
  for (int i = 0; i < lines.length; i++) {
    final (start, end, rad) = lines[i];
    if (i == nipLineIdx) {
      path._drawNip(start, end,
          nipSize: nipSize,
          nipMargin: nipMargin,
          nipPosition: nipPosition,
          nipRadius: nipRadius);
    } else {
      if (i == 0) path.moveTo(start.dx, start.dy);
      path._lineToPoint(end);
    }
    // next round(arc)
    final nextIdx = i != lines.length - 1 ? i + 1 : 0;
    final (next, _, _) = lines[nextIdx];
    path.arcToPoint(next, radius: rad);
  }

  return path..close();
}

extension _BalloonPathExtension on Path {
  void _lineToPoint(Offset point) => lineTo(point.dx, point.dy);

  void _drawNip(
    Offset start,
    Offset end, {
    required double nipSize,
    required double nipMargin,
    required BalloonNipPosition nipPosition,
    required double nipRadius,
  }) {
    final xDir = nipPosition.isTop ? 1 : -1;

    final nipHeight = calcNipHeight(nipSize);
    final nipWidthCenter = nipSize / 2;
    final radiusWidth = (nipRadius * math.sqrt(2) / 2);

    final double nipStartX, nipEndX;
    if (nipPosition.isCenter) {
      final centerX = (start.dx + end.dx) / 2;
      nipStartX = centerX - (nipWidthCenter * xDir);
      nipEndX = centerX + (nipWidthCenter * xDir);
    } else if (nipPosition.isStart) {
      nipStartX = start.dx + (nipMargin * xDir);
      nipEndX = nipStartX + (nipSize * xDir);
    } else {
      nipEndX = end.dx - (nipMargin * xDir);
      nipStartX = nipEndX - (nipSize * xDir);
    }

    final nipPoint = Offset(
      nipStartX + (nipWidthCenter * xDir),
      start.dy - (nipHeight * xDir),
    );
    final nipRoundStartPoint = Offset(
      nipPoint.dx - (radiusWidth * xDir),
      nipPoint.dy + (nipRadius * xDir),
    );
    final nipRoundEndPoint = Offset(
      nipPoint.dx + (radiusWidth * xDir),
      nipRoundStartPoint.dy,
    );

    _lineToPoint(start);
    lineTo(nipStartX, start.dy);
    _lineToPoint(nipRoundStartPoint);
    arcToPoint(nipRoundEndPoint, radius: Radius.circular(nipRadius));
    lineTo(nipEndX, end.dy);
    _lineToPoint(end);
  }
}