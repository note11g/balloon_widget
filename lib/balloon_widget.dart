library balloon_widget;

import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BalloonNipPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  bool get isTop =>
      this == BalloonNipPosition.topLeft || this == BalloonNipPosition.topRight;

  bool get isStart =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.bottomRight;
}

class Balloon extends StatelessWidget {
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double elevation;
  final Color shadowColor;
  final BalloonNipPosition nipPosition;
  final double nipSize;
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
    final path = drawPath(size);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawShadow(path, shadowColor, elevation, false);
    canvas.drawPath(path, paint);
  }

  Path drawPath(Size size) {
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

  Radius get topLeftRadius => borderRadius.topLeft;

  Radius get topRightRadius => borderRadius.topRight;

  Radius get bottomLeftRadius => borderRadius.bottomLeft;

  Radius get bottomRightRadius => borderRadius.bottomRight;
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
    if (nipPosition.isStart) {
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
