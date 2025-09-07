import 'dart:ui';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:flutter/material.dart';
import '../core/balloon_nip_position.dart';
import '../core/balloon_shadow.dart';
import '../core/balloon_painter.dart';
import '../core/balloon_clipper.dart';

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
  
  /// Whether to enable glass effect with backdrop blur.
  ///
  /// When [true], applies a backdrop blur filter to the balloon including the nip.
  /// The default value is [false].
  final bool glassEffect;
  
  /// The blur intensity for the glass effect.
  ///
  /// This controls the sigma value for the backdrop blur filter.
  /// Higher values create more intense blur.
  /// The default value is 10.0.
  final double glassBlurSigma;
  
  /// The opacity of the balloon color when glass effect is enabled.
  ///
  /// This value is multiplied with the balloon [color] when [glassEffect] is [true].
  /// Should be between 0.0 and 1.0.
  /// The default value is 0.2.
  final double glassOpacity;
  
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
    this.glassEffect = false,
    this.glassBlurSigma = 10.0,
    this.glassOpacity = 0.2,
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
    this.glassEffect = false,
    this.glassBlurSigma = 10.0,
    this.glassOpacity = 0.2,
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
      glassEffect: glassEffect,
      glassBlurSigma: glassBlurSigma,
      glassOpacity: glassOpacity,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nipHeight = getRealNipHeight(nipSize, nipRadius);
    
    Widget balloonContent = CustomPaint(
      painter: BalloonPainter(
        color: glassEffect ? color.withOpacity(glassOpacity) : color,
        borderRadius: borderRadius,
        shadowRenderer:
            shadow != null ? ShadowRenderer(strategy: shadow!) : null,
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
    );

    // Apply glass effect with BackdropFilter if enabled
    if (glassEffect) {
      balloonContent = ClipPath(
        clipper: BalloonGlassClipper(
          nipPosition: nipPosition,
          nipSize: nipSize,
          nipMargin: nipMargin,
          nipRadius: nipRadius,
          borderRadius: borderRadius,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlurSigma, sigmaY: glassBlurSigma),
          child: balloonContent,
        ),
      );
    }

    final balloonWidget = Padding(
      padding: isHeightIncludingNip
          ? EdgeInsets.only(
              top: nipPosition.isTop ? nipHeight : 0,
              bottom: !nipPosition.isTop ? nipHeight : 0,
            )
          : EdgeInsets.zero,
      child: balloonContent,
    );

    if (oneByOneSize) {
      return CustomSingleChildLayout(
          delegate: BalloonNoSizeLayoutDelegate(
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