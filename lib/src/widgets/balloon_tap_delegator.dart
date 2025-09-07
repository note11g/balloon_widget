import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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

  @internal
  static bool usingDelegator(BuildContext context) {
    return context.findAncestorWidgetOfExactType<BalloonTapDelegator>() != null;
  }
}