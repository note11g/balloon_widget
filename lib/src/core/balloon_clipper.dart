import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'balloon_nip_position.dart';
import 'balloon_painter.dart';

/// A clipper that creates balloon-shaped clipping paths.
///
/// This clipper can be used with [ClipPath] to create balloon shapes
/// with rounded corners and nip in various positions.
class BalloonClipper extends CustomClipper<Path> {
  final BalloonNipPosition nipPosition;

  /// The width of the nip (triangular pointer).
  final double nipWidth;

  /// The height of the nip (triangular pointer).
  final double nipHeight;

  /// The radius for rounded corners of the balloon.
  final double borderRadius;

  /// The margin between the nip and the edge of the balloon.
  ///
  /// For [BalloonNipPosition.topLeft] and [BalloonNipPosition.bottomLeft],
  /// this is the distance from the left edge.
  /// For [BalloonNipPosition.topRight] and [BalloonNipPosition.bottomRight],
  /// this is the distance from the right edge.
  /// For center positions, this value is ignored.
  final double nipMargin;

  const BalloonClipper({
    required this.nipPosition,
    required this.nipWidth,
    required this.nipHeight,
    this.borderRadius = 8,
    this.nipMargin = 4,
  });

  @override
  Path getClip(Size size) {
    // Create balloon shape:
    // 1) Rounded rectangle base
    // 2) Triangular nip positioned according to nipPosition
    //    - Calculate position based on left/center/right alignment
    //    - Consider margin for proper nip placement

    final path = Path();

    // Calculate corner radius, ensuring it fits within the size constraints
    final resolvedRadius = math.min(borderRadius, size.shortestSide / 2);
    final radius = Radius.circular(resolvedRadius);

    // Define corner points for rounded rectangle
    final topLeftCorner = Offset(resolvedRadius, 0);
    final topRightCorner = Offset(size.width - resolvedRadius, 0);
    final bottomRightCorner = Offset(size.width, size.height - resolvedRadius);
    final bottomLeftCorner = Offset(0, size.height - resolvedRadius);

    // Define edges as (start, end, cornerRadius) tuples
    // Order: [top edge, right edge, bottom edge, left edge]
    final edges = <(Offset start, Offset end, Radius cornerRadius)>[
      (topLeftCorner, topRightCorner, radius),     // Top edge (left → right)
      (Offset(size.width, resolvedRadius), bottomRightCorner, radius),  // Right edge (top → bottom)
      (Offset(size.width - resolvedRadius, size.height),
      Offset(resolvedRadius, size.height), radius),  // Bottom edge (right → left)
      (Offset(0, size.height - resolvedRadius), Offset(
          0, resolvedRadius), radius),  // Left edge (bottom → top)
    ];

    // Determine which edge gets the nip:
    // - Top nips use edge 0 (top edge)
    // - Bottom nips use edge 2 (bottom edge)
    final nipEdgeIndex = nipPosition.isTop ? 0 : 2;

    // Draw the path
    for (int i = 0; i < edges.length; i++) {
      final (start, end, cornerRadius) = edges[i];

      // Move to start point for first edge
      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      }

      if (i == nipEdgeIndex) {
        // Draw nip (triangular pointer)
        _addNipPath(path, start, end, nipPosition);
      } else {
        // Draw straight line
        path.lineTo(end.dx, end.dy);
      }

      // Connect to next edge with rounded corner
      final nextIndex = (i == edges.length - 1) ? 0 : i + 1;
      final (nextEdgeStart, _, nextCornerRadius) = edges[nextIndex];

      path.arcToPoint(
        nextEdgeStart,
        radius: nextCornerRadius,
      );
    }

    path.close();
    return path;
  }

  /// Draws a nip (triangular pointer) on the specified edge.
  ///
  /// Inserts a triangular nip between [start] and [end] points:
  /// - [BalloonNipPosition.topCenter], [BalloonNipPosition.bottomCenter] → centered
  /// - [BalloonNipPosition.topLeft], [BalloonNipPosition.bottomLeft] → near start point
  /// - [BalloonNipPosition.topRight], [BalloonNipPosition.bottomRight] → near end point
  void _addNipPath(Path path, Offset start, Offset end,
      BalloonNipPosition pos) {
    // Assume horizontal line (top or bottom edge)
    final lineLength = (end.dx - start.dx).abs();

    // Calculate nip center X position based on alignment
    double arrowCenterX;
    if (pos.isCenter) {
      arrowCenterX = (start.dx + end.dx) / 2.0;
    } else if (pos.isLeft) {
      // Position from start point with margin
      arrowCenterX = start.dx + nipMargin + nipWidth / 2;
    } else {
      // Position from end point with margin (right alignment)
      arrowCenterX = end.dx - nipMargin - nipWidth / 2;
    }

    // Determine nip direction: upward for top positions, downward for bottom
    final sign = pos.isTop ? -1.0 : 1.0;
    final arrowTipY = start.dy + (sign * nipHeight);
    final arrowLeftX = arrowCenterX - (nipWidth / 2);
    final arrowRightX = arrowCenterX + (nipWidth / 2);

    // Draw path: start → arrowLeft → arrowTip → arrowRight → end
    path.lineTo(arrowLeftX, start.dy);
    path.lineTo(arrowCenterX, arrowTipY);
    path.lineTo(arrowRightX, start.dy);
    path.lineTo(end.dx, end.dy);
  }

  @override
  bool shouldReclip(BalloonClipper oldClipper) {
    return oldClipper.nipPosition != nipPosition ||
        oldClipper.nipWidth != nipWidth ||
        oldClipper.nipHeight != nipHeight ||
        oldClipper.borderRadius != borderRadius ||
        oldClipper.nipMargin != nipMargin;
  }
}

/// Glass effect clipper that uses the same path logic as [BalloonPainter].
///
/// This clipper creates the exact same balloon shape including the nip
/// for use with [BackdropFilter] to apply glass effect consistently.
class BalloonGlassClipper extends CustomClipper<Path> {
  final BalloonNipPosition nipPosition;
  final double nipSize;
  final double nipMargin;
  final double nipRadius;
  final BorderRadius borderRadius;

  BalloonGlassClipper({
    required this.nipPosition,
    required this.nipSize,
    required this.nipMargin,
    required this.nipRadius,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    final calibratedBorderRadius = BalloonPainter.calibrateBorderRadius(
      borderRadius: borderRadius, 
      size: size
    );
    
    return createBalloonPath(
      size: size,
      borderRadius: calibratedBorderRadius,
      nipPosition: nipPosition,
      nipSize: nipSize,
      nipMargin: nipMargin,
      nipRadius: nipRadius,
    );
  }

  @override
  bool shouldReclip(BalloonGlassClipper oldClipper) {
    return oldClipper.nipPosition != nipPosition ||
        oldClipper.nipSize != nipSize ||
        oldClipper.nipMargin != nipMargin ||
        oldClipper.nipRadius != nipRadius ||
        oldClipper.borderRadius != borderRadius;
  }
}