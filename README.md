# balloon_widget

[![pub package](https://img.shields.io/pub/v/balloon_widget.svg?color=4285F4)](https://pub.dev/packages/balloon_widget)
[![github](https://img.shields.io/github/stars/note11g/balloon_widget)](https://github.com/note11g/balloon_widget)

a simple balloon widget.


![nip_position_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/nip_position_grid.png)
![position_balloon.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/positioned_balloon.png)
![borderRadius_balloon_color_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/borderRadius_balloon_color_grid.png)
![include_nip_height_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/include_nip_height_grid.png)
![inner_padding_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/inner_padding_grid.png)
![shadow_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/shadow_grid.png)
![custom_shadow_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/custom_shadow_grid.png)
![nip_target_position_grid.png](https://github.com/note11g/balloon_widget/raw/main/test/goldens/nip_target_position_grid.png)

## Usage

### Use as a widget

```dart
Balloon(
  child: Text('Hello, Balloon!'),
);
```

### Use as a widget which placed at the specific widget.

```dart

bool isVisible = true;

@override
Widget build(BuildContext context) {
  // if you want apply decoration on balloon widget, use `PositionedBalloon.decorateBuilder` widget.
  // or just need fade-in/out effect, use `PositionedBalloon.fade` constructor.
  return PositionedBalloon(
    show: isVisible,
    balloon: Balloon(
      nipPosition: BalloonNipPosition.topCenter,
      child: Text("now go shopping, you got a event coin!"),
    ),
    child: TextButton(
      onPressed: () {
        openUrl(this.goodsUrl);
        setState(() => isVisible = false);
      },
      text: Text("go shopping"),
    ),
  );
}
```

### Use as a widget which placed at the specific widget with Focus. (easy way to handle dynamic-visibility without variable)

```dart
@override
Widget build(BuildContext context) {
  return PositionedBalloon.focusable( // or you can use `FocusablePositionedBalloon` widget.
    autofocus: true, // default is false
    balloon: Balloon(
      nipPosition: BalloonNipPosition.topCenter,
      child: Text("now go shopping, you got a event coin!"),
    ),
    childBuilder: (context, focusNode) =>
        TextButton(
          onPressed: () {
            openUrl(this.goodsUrl);
            if (focusNode.hasFocus) focusNode.unfocus();
          },
          text: Text("go shopping"),
        ),
  );
}
```

### Use as a widget which placed at the specific widget and include button on the balloon widget.

```dart

bool isVisible = true;

@override
Widget build(BuildContext context) {
  return BalloonTapDelegator(
      child: Scaffold(
          body: ListView(
              children: [
                PositionedBalloon(
                    show: isVisible,
                    balloon: Balloon(
                        nipPosition: BalloonNipPosition.topCenter,
                        child: Row(children: [
                          Text("now go shopping, you got a event coin!"),
                          IconButton(
                              onPressed: () => setState(() => isVisible = false),
                              icon: Icon(Icons.close)),
                        ]),
                        child: TextButton(
                          onPressed: () {
                            openUrl(this.goodsUrl);
                            setState(() => isVisible = false);
                          },
                          text: Text("go shopping"),
                        ))),
              ])));
}
```

