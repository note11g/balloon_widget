## 0.4.0+1

* Fix typo in README.md

## 0.4.0

* Add: `PositionedBalloon.fade` constructor which provides fade-in/out effect easily.

* Add: `FocusablePositionedBalloon` Widget & `PositionedBalloon.focusable` constructor which provides easy visibility control with `FocusNode`.

## 0.3.0

* Add: `BalloonTapDelegator` which used to process with tap event delegation to the balloon widget. (PR: [#12](https://github.com/note11g/balloon_widget/pull/12), Issue: [#11](https://github.com/note11g/balloon_widget/issues/11))

## 0.2.0

* Add: `Balloon.shadow` property, `BalloonShadow` interface, and `MaterialBalloonShadow`, `CustomBalloonShadow` concrete class.
* [Breaking] remove `Balloon.elevation` and `Balloon.shadowColor` properties. (Use `Balloon.shadow` instead)
* Chore: add some API descriptions.

## 0.1.0

* Add `BalloonNipPosition.topCenter`, `BalloonNipPosition.bottomCenter` (PR: [#4](https://github.com/note11g/balloon_widget/pull/4))
* Add: `PositionedBalloon` Widget API (PR:[#6](https://github.com/note11g/balloon_widget/pull/6))
* Fix: fix incorrect height layout when including nip height (nip radius value difference from zero nip radius apply at nip height)

## 0.0.1

* initial release.
