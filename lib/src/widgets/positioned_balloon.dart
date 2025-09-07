import 'package:flutter/material.dart';
import 'balloon_widget.dart';
import 'balloon_tap_delegator.dart';

/// `PositionedBalloon` is a decorator widget that provide the `Balloon` widget similar to Flutter's built-in [`Tooltip`](https://api.flutter.dev/flutter/material/Tooltip-class.html),
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

  /// provides fade-in/out effect easily.
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

  /// PositionedBalloon with focus.
  ///
  /// This widget is a combination of `Focus` and `PositionedBalloon`.
  ///
  /// It provides a balloon that is displayed when the focus is on the child widget.
  ///
  ///
  /// It's same with `FocusablePositionedBalloon` constructor.
  static FocusablePositionedBalloon focusable({
    Key? key,
    bool autofocus = false,
    FocusNode? focusNode,
    Duration fadeDuration = const Duration(milliseconds: 80),
    Curve fadeCurve = Curves.easeInOut,
    double yOffset = 4,
    required Balloon balloon,
    required Widget Function(BuildContext context, FocusNode focusNode)
        childBuilder,
  }) {
    return FocusablePositionedBalloon(
      key: key,
      autofocus: autofocus,
      focusNode: focusNode,
      fadeDuration: fadeDuration,
      fadeCurve: fadeCurve,
      yOffset: yOffset,
      balloon: balloon,
      childBuilder: childBuilder,
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

/// PositionedBalloon with focus.
///
/// This widget is a combination of `Focus` and `PositionedBalloon.fade`.
///
///
/// It provides a balloon that is displayed when the focus is on the child widget.
///
///
/// It's same with `PositionedBalloon.focusable` constructor.
class FocusablePositionedBalloon extends StatelessWidget {
  final bool autofocus;
  final FocusNode? focusNode;
  final Balloon balloon;
  final Duration fadeDuration;
  final Curve fadeCurve;
  final double yOffset;
  final Widget Function(BuildContext context, FocusNode focusNode) childBuilder;

  const FocusablePositionedBalloon({
    super.key,
    this.autofocus = false,
    this.focusNode,
    this.fadeDuration = const Duration(milliseconds: 80),
    this.fadeCurve = Curves.easeInOut,
    this.yOffset = 4,
    required this.balloon,
    required this.childBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: autofocus,
        focusNode: focusNode,
        child: Builder(builder: (context) {
          final realFocusNode = Focus.of(context);
          return PositionedBalloon.fade(
            show: realFocusNode.hasFocus,
            yOffset: yOffset,
            balloon: balloon,
            child: childBuilder(context, realFocusNode),
          );
        }));
  }
}