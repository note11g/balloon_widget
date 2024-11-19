library balloon_widget;

import 'dart:math' as math;
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';

/// `BalloonNipPosition` is an enum that represents the position of the balloon's nip.
enum BalloonNipPosition {
  /// --^-------
  topLeft,

  /// -----^-----
  topCenter,

  /// --------^--
  topRight,

  /// --⌄-------
  bottomLeft,

  /// -----⌄-----
  bottomCenter,

  ///
  /// -------⌄--
  bottomRight;

  bool get isTop =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.topRight ||
      this == BalloonNipPosition.topCenter;

  bool get isBottom =>
      this == BalloonNipPosition.bottomLeft ||
      this == BalloonNipPosition.bottomRight ||
      this == BalloonNipPosition.bottomCenter;

  bool get isStart =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.bottomRight;

  bool get isCenter =>
      this == BalloonNipPosition.topCenter ||
      this == BalloonNipPosition.bottomCenter;

  bool get isLeft =>
      this == BalloonNipPosition.topLeft ||
      this == BalloonNipPosition.bottomLeft;

  bool get isRight =>
      this == BalloonNipPosition.topRight ||
      this == BalloonNipPosition.bottomRight;
}

/// `PositionedBalloon` is a decorator widget that provide the `Balloon` widget similar to Flutter’s built-in [`Tooltip`](https://api.flutter.dev/flutter/material/Tooltip-class.html),
/// allowing it to describe child widgets.
///
/// By integrating directly into the widget tree, it avoids using the [Overlay](https://api.flutter.dev/flutter/widgets/Overlay-class.html) API,
/// so developers do not need to manage its lifecycle.
///
class PositionedBalloon extends StatelessWidget {
  final bool show;

  /// The margin between the nip and child widget.
  final double yOffset;

  /// The balloon widget to be displayed.
  final Balloon balloon;

  /// A function that wraps the balloon widget with a custom widget.
  ///
  /// e.g. `AnimatedOpacity(child: balloon)`, `ConstrainedBox(child: balloon)`, etc.
  final Widget Function(BuildContext context, Balloon balloon)?
      balloonDecorateBuilder;

  /// The child widget to be displayed.
  ///
  /// This widget will be targeted by the balloon.
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

  factory PositionedBalloon.fade({
    Key? key,
    bool show = true,
    double yOffset = 4,
    Duration duration = const Duration(milliseconds: 80),
    Curve curve = Curves.easeInOut,
    required Balloon balloon,
    required Widget child,
  }) {
    return PositionedBalloon.decorateBuilder(
      key: key,
      yOffset: yOffset,
      balloonDecorateBuilder: (_, balloon) => AnimatedOpacity(
          curve: curve,
          duration: duration,
          opacity: show ? 1 : 0,
          child: balloon),
      balloon: balloon,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBalloonTapDelegator = BalloonTapDelegator.usingDelegator(context);

    final isTop = balloon.nipPosition.isTop;
    final stackChildren = [
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
                            return balloonDecorateBuilder!.call(
                                context,
                                balloon.toNoSize(
                                    deferPointer: hasBalloonTapDelegator));
                          })
                        : balloon.toNoSize(
                            deferPointer: hasBalloonTapDelegator)))),
    ];
    return Stack(
        clipBehavior: Clip.none,
        children: !hasBalloonTapDelegator
            ? stackChildren
            : stackChildren.reversed.toList());
  }
}

/// `BalloonTapDelegator` resolves the issue where tap events are not handled
/// when displaying a `Balloon` using `PositionedBalloon`.
///
/// When a `Balloon` is displayed over a child element using `PositionedBalloon`,
/// events that need to be handled within the `Balloon` (e.g., button presses)
/// may not be processed due to the limited area of the child element.
///
/// By wrapping a parent widget that has a larger hit test area than `PositionedBalloon.child`
/// with the BalloonTapDelegator widget,
/// you can forward tap events from that area into the `Balloon`,
/// allowing them to be handled appropriately.
///
///
/// ```dart
/// BalloonTapDelegator( // Place this widget at a level with a larger size than `Balloon.child`
///   child: Scaffold( // in this case, the Scaffold widget has a larger size than the `FloatingActionButton` which is `PositionedBalloon.child`
///     floatingActionButton: PositionedBalloon(
///       show: isVisible,
///       balloon: Balloon(
///         child: Button(
///           label: 'Close',
///           onTap: () {
///             setState(() => isVisible = false);
///           })),
///       child: FloatingActionButton(onPressed: () {
///         setState(() => isVisible = !isVisible);
///       }))));
/// ```
class BalloonTapDelegator extends StatelessWidget {
  final Widget child;

  const BalloonTapDelegator({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DeferredPointerHandler(child: child);
  }

  @visibleForTesting
  static bool usingDelegator(BuildContext context) {
    return context.findAncestorWidgetOfExactType<BalloonTapDelegator>() != null;
  }
}

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

class Balloon extends StatelessWidget {
  final Color color;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final BalloonShadow? shadow;
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
  final bool deferPointer;
  final Widget child;

  const Balloon({
    super.key,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.all(8),
    this.shadow = const MaterialBalloonShadow(),
    this.nipPosition = BalloonNipPosition.bottomRight,
    this.nipSize = 12,
    this.nipMargin = 4,
    this.nipRadius = 2,
    this.isHeightIncludingNip = true,
    required this.child,
  })  : oneByOneSize = false,
        deferPointer = false;

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
    this.shadow = const MaterialBalloonShadow(),
    this.nipPosition = BalloonNipPosition.bottomRight,
    this.nipSize = 12,
    this.nipMargin = 4,
    this.nipRadius = 2,
    this.deferPointer = false,
    required this.child,
  })  : isHeightIncludingNip = true,
        oneByOneSize = true;

  Balloon toNoSize({bool deferPointer = false}) {
    return Balloon.noSize(
      color: color,
      borderRadius: borderRadius,
      padding: padding,
      shadow: shadow,
      nipPosition: nipPosition,
      nipSize: nipSize,
      nipMargin: nipMargin,
      nipRadius: nipRadius,
      deferPointer: deferPointer,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nipHeight = _getRealNipHeight(nipSize, nipRadius);
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
          shadowRenderer:
              shadow != null ? _ShadowRenderer(strategy: shadow!) : null,
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
          child: deferPointer
              ? DeferPointer(child: balloonWidget)
              : balloonWidget);
    } else {
      return balloonWidget;
    }
  }
}

double _calcNipHeight(double nipSize) {
  return nipSize / 2 * math.sqrt(2); // 45 degree triangle
}

double _getRealNipHeight(double nipSize, double nipRadius) {
  final baseHeight = _calcNipHeight(nipSize);
  // sin(45) = sqrt(2) / 2
  final radiusAdjustment = nipRadius * math.sqrt(2) / 2;
  return baseHeight - radiusAdjustment;
}

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
  bool shouldRelayout(_BalloonNoSizeLayoutDelegate oldDelegate) {
    return oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.padding != padding;
  }
}

class _ShadowRenderer {
  final BalloonShadow strategy;

  _ShadowRenderer({required this.strategy});

  void renderShadows(Canvas canvas, Path path, Size size) {
    strategy._renderShadows(canvas, path, size);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ShadowRenderer &&
          runtimeType == other.runtimeType &&
          strategy == other.strategy;

  @override
  int get hashCode => strategy.hashCode ^ runtimeType.hashCode;
}

class _BalloonPainter extends CustomPainter {
  final Color color;
  final _ShadowRenderer? shadowRenderer;
  final double nipSize;
  final BorderRadius borderRadius;
  final BalloonNipPosition nipPosition;
  final double nipMargin;
  final double nipRadius;

  _BalloonPainter({
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

  @override
  bool shouldRepaint(_BalloonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.shadowRenderer != shadowRenderer ||
        oldDelegate.nipSize != nipSize ||
        oldDelegate.nipMargin != nipMargin ||
        oldDelegate.nipPosition != nipPosition ||
        oldDelegate.nipRadius != nipRadius ||
        oldDelegate.borderRadius != borderRadius;
  }
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

    _lineToPoint(start);
    lineTo(nipStartX, start.dy);
    _lineToPoint(nipRoundStartPoint);
    arcToPoint(nipRoundEndPoint, radius: Radius.circular(nipRadius));
    lineTo(nipEndX, end.dy);
    _lineToPoint(end);
  }
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
