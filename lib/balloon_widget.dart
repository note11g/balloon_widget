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

  bool get isLeft =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.bottomLeft;
}

/// `PositionedBalloon` is a decorator widget that provide the `Balloon` widget similar to Flutter’s built-in [`Tooltip`](https://api.flutter.dev/flutter/material/Tooltip-class.html),
/// allowing it to describe child widgets.
///
/// By integrating directly into the widget tree, it avoids using the [Overlay](https://api.flutter.dev/flutter/widgets/Overlay-class.html) API,
/// so developers do not need to manage its lifecycle.
///
class PositionedBalloon extends StatelessWidget {
  final bool show;
  final double yOffset;
  final Balloon balloon;
  final Widget Function(BuildContext context, Balloon balloon)?
      balloonDecorateBuilder;
  final Widget child;

  const PositionedBalloon({
    super.key,
    this.show = true,
    this.yOffset = 4,
    required this.balloon,
    required this.child,
  }) : balloonDecorateBuilder = null;

  /// Decorate the balloon with a custom widget wrapping.
  ///
  /// If you want to decorate the balloon with a custom widget, use this constructor.
  const PositionedBalloon.decorateBuilder({
    super.key,
    this.yOffset = 4,
    required this.balloonDecorateBuilder,
    required this.balloon,
    required this.child,
  }) : show = true;

  @override
  Widget build(BuildContext context) {
    final isTop = balloon.nipPosition.isTop;
    return Stack(clipBehavior: Clip.none, children: [
      child,
      if (show || balloonDecorateBuilder != null)
        Positioned(
          top: isTop ? null : 0 - yOffset,
          bottom: isTop ? -1 - yOffset : null,
          left: 1,
          right: 0,
          child: Center(
            child: UnconstrainedBox(
                child: balloonDecorateBuilder != null
                    ? Builder(builder: (context) {
                        return balloonDecorateBuilder!
                            .call(context, balloon.toNoSize());
                      })
                    : balloon.toNoSize()),
          ),
        ),
    ]);
  }
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
  final bool oneByOneSize;
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
  }) : oneByOneSize = false;

  /// Draw a balloon at 1px x 1px.
  ///
  /// that widget take only 1px x 1px size.
  ///
  /// 1px x 1px is located at the nip target position.
  ///
  /// but, drawing normal size.
  const Balloon.noSize({
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
    required this.child,
  })  : isHeightIncludingNip = true,
        oneByOneSize = true;

  Balloon toNoSize() {
    return Balloon.noSize(
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      elevation: elevation,
      shadowColor: shadowColor,
      nipPosition: nipPosition,
      nipSize: nipSize,
      nipMargin: nipMargin,
      nipRadius: nipRadius,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nipHeight = _calcNipHeight(nipSize);
    final balloonWidget = Padding(
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
        ),
      ),
    );

    if (oneByOneSize) {
      return CustomSingleChildLayout(
        delegate: _BalloonNoSizeLayoutDelegate(
          nipPosition: nipPosition,
          nipSize: nipSize,
          nipMargin: nipMargin,
          borderRadius: borderRadius,
          padding: padding,
        ),
        child: balloonWidget,
      );
    } else {
      return balloonWidget;
    }
  }
}

double _calcNipHeight(double nipSize) => nipSize / 2 * math.sqrt(2);

class _BalloonNoSizeLayoutDelegate extends SingleChildLayoutDelegate {
  final BalloonNipPosition nipPosition;
  final double nipSize;
  final double nipMargin;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  _BalloonNoSizeLayoutDelegate({
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
    final nipOffset = _calculateNipOffset(childSize);
    final nipHeight = _calcNipHeight(nipSize);

    double dx = -nipOffset.dx;
    double dy;

    if (nipPosition.isTop) {
      dy = -nipOffset.dy + nipHeight;
    } else {
      dy = -nipOffset.dy - nipHeight;
    }

    return Offset(dx, dy);
  }

  Offset _calculateNipOffset(Size childSize) {
    final nipHeight = _calcNipHeight(nipSize);

    double dx;
    if (nipPosition.isCenter) {
      dx = childSize.width / 2;
    } else if (nipPosition.isLeft) {
      dx = nipMargin + borderRadius.topLeft.x + nipSize / 2;
    } else {
      dx =
          childSize.width - (nipMargin + borderRadius.topRight.x + nipSize / 2);
    }

    double dy;
    if (nipPosition.isTop) {
      dy = nipHeight;
    } else {
      dy = childSize.height - nipHeight;
    }

    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(_BalloonNoSizeLayoutDelegate oldDelegate) {
    return oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.padding != padding;
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
