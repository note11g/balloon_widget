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