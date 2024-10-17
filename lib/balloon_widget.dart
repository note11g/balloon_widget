library balloon_widget;

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BalloonNipPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight;

  bool get isTop =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.topRight ||
      this == BalloonNipPosition.topCenter;

  bool get isStart =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.bottomRight;

  bool get isCenter =>
      this == BalloonNipPosition.topCenter ||
      this == BalloonNipPosition.bottomCenter;
}

class Balloon extends StatelessWidget {
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final Color shadowColor;
  final BalloonNipPosition nipPosition;
  final double nipSize;

  /// The margin between the nip and the edge of the balloon. (start point is rounded end point)
  ///
  /// if nipPosition is `topCenter` or `bottomCenter`, this value is ignored.
  ///
  /// The default value is 4.0.
  final double nipMargin;
  final double nipRadius;
  final bool isHeightIncludingNip;
  final Widget child;

  const Balloon({
    super.key,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.all(8),
    this.elevation = 4,
    this.shadowColor = Colors.black26,
    this.nipPosition = BalloonNipPosition.bottomRight,
    this.nipSize = 12,
    this.nipMargin = 4,
    this.nipRadius = 2,
    this.isHeightIncludingNip = true,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final nipHeight = _calcNipHeight(nipSize);
    return Padding(
        padding: isHeightIncludingNip
            ? EdgeInsets.only(
                top: nipPosition.isTop ? nipHeight : 0,
                bottom: !nipPosition.isTop ? nipHeight : 0,
              )
            : EdgeInsets.zero,
        child: CustomPaint(
            painter: _BalloonPainter(
              color: color,
              borderRadius: borderRadius,
              elevation: elevation,
              shadowColor: shadowColor,
              nipPosition: nipPosition,
              nipMargin: nipMargin,
              nipSize: nipSize,
              nipRadius: nipRadius,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Padding(
                padding: padding,
                child: child,
              ),
            )));
  }
}

class _BalloonPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final double elevation;
  final double nipSize;
  final BorderRadius borderRadius;
  final BalloonNipPosition nipPosition;
  final double nipMargin;
  final double nipRadius;

  _BalloonPainter({
    required this.color,
    required this.shadowColor,
    required this.elevation,
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

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    if (elevation > 0) canvas.drawShadow(path, shadowColor, elevation, true);
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
        path.drawNip(start, end,
            nipSize: nipSize,
            nipMargin: nipMargin,
            nipPosition: nipPosition,
            nipRadius: nipRadius);
      } else {
        if (i == 0) path.moveTo(start.dx, start.dy);
        path.lineToPoint(end);
      }
      // next round(arc)
      final nextIdx = i != lines.length - 1 ? i + 1 : 0;
      final (next, _, _) = lines[nextIdx];
      path.arcToPoint(next, radius: rad);
    }

    return path..close();
  }

  @override
  bool shouldRepaint(_BalloonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.elevation != elevation ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipRadius != nipRadius ||
        oldDelegate.borderRadius != borderRadius;
  }
}

extension _BalloonPathExtension on Path {
  void lineToPoint(Offset point) => lineTo(point.dx, point.dy);

  void drawNip(
    Offset start,
    Offset end, {
    required double nipSize,
    required double nipMargin,
    required BalloonNipPosition nipPosition,
    required double nipRadius,
  }) {
    final xDir = nipPosition.isTop ? 1 : -1;

    final nipHeight = _calcNipHeight(nipSize);
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

    lineToPoint(start);
    lineTo(nipStartX, start.dy);
    lineToPoint(nipRoundStartPoint);
    arcToPoint(nipRoundEndPoint, radius: Radius.circular(nipRadius));
    lineTo(nipEndX, end.dy);
    lineToPoint(end);
  }
}

double _calcNipHeight(double nipSize) => nipSize / 2 * math.sqrt(2);
