import 'dart:async';

import 'package:balloon_widget/balloon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group("PositionedBalloon hitTest", () {
    PositionedBalloon balloonCreator(Completer<bool> completer,
            {required BalloonNipPosition pos}) =>
        PositionedBalloon(
            balloon: Balloon(
                nipPosition: pos,
                child: Column(children: [
                  IconButton(
                      onPressed: () => completer.complete(true),
                      icon: const Icon(Icons.add)),
                  const Text("Hello Flutter!"),
                ])),
            child: Container(width: 64, height: 64, color: Colors.redAccent));

    testWidgets('PositionedBalloon hitTest on Scaffold.body', (tester) async {
      final completer = Completer<bool>();

      await tester.pumpWidget(MaterialApp(
          home: SizedBox(
              width: 800,
              height: 800,
              child: BalloonTapDelegator(
                child: Scaffold(
                    body: balloonCreator(completer,
                        pos: BalloonNipPosition.topLeft)),
              ))));

      await tester.pumpAndSettle();
      final buttonFinder = find.byType(IconButton);

      /// check tap
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(completer.isCompleted, true);
      expect(await completer.future, true);
    });

    testWidgets('PositionedBalloon hitTest on ListView', (tester) async {
      final completer = Completer<bool>();

      await tester.pumpWidget(MaterialApp(
          home: SizedBox(
              width: 800,
              height: 800,
              child: Scaffold(
                  body: BalloonTapDelegator(
                child: ListView(children: [
                  balloonCreator(completer, pos: BalloonNipPosition.topCenter)
                ]),
              )))));

      await tester.pumpAndSettle();
      final buttonFinder = find.byType(IconButton);

      /// check tap
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      expect(completer.isCompleted, true);
      expect(await completer.future, true);
    });
  });

  testGoldens('Nip Position should look correct', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello Flutter!");
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
      ..addScenario(
          'nipPosition: topLeft',
          const Balloon(
              nipPosition: BalloonNipPosition.topLeft, child: textWidget))
      ..addScenario(
          "nipPosition: topCenter",
          const Balloon(
              nipPosition: BalloonNipPosition.topCenter, child: textWidget))
      ..addScenario(
          'nipPosition: topRight',
          const Balloon(
              nipPosition: BalloonNipPosition.topRight, child: textWidget))
      ..addScenario(
          'nipPosition: bottomLeft',
          const Balloon(
              nipPosition: BalloonNipPosition.bottomLeft, child: textWidget))
      ..addScenario(
          "nipPosition: bottomCenter",
          const Balloon(
              nipPosition: BalloonNipPosition.bottomCenter, child: textWidget))
      ..addScenario(
          'nipPosition: bottomRight (default)',
          const Balloon(
              nipPosition: BalloonNipPosition.bottomRight, child: textWidget));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'nip_position_grid');
  });

  testGoldens('inner Padding check', (tester) async {
    await loadAppFonts();

    final containerWidget =
        Container(color: Colors.blueAccent, width: 64, height: 40);
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario('padding: EdgeInsets.zero',
          Balloon(padding: EdgeInsets.zero, child: containerWidget))
      ..addScenario('padding: const EdgeInsets.all(8) (default)',
          Balloon(child: containerWidget))
      ..addScenario(
          'padding: const EdgeInsets.all(12)',
          Balloon(
            padding: const EdgeInsets.all(12),
            child: containerWidget,
          ));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'inner_padding_grid');
  });

  testGoldens('include nip height check', (tester) async {
    await loadAppFonts();

    final containerWidget =
        Container(color: Colors.blueAccent, width: 64, height: 40);
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'isHeightIncludingNip: true (default)',
          Container(
              color: Colors.redAccent,
              child:
                  Balloon(isHeightIncludingNip: true, child: containerWidget)))
      ..addScenario(
          'isHeightIncludingNip: false',
          Container(
            color: Colors.redAccent,
            child: Balloon(
              isHeightIncludingNip: false,
              child: containerWidget,
            ),
          ));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'include_nip_height_grid');
  });

  testGoldens('nip target position check', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello Flutter!");

    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          '[calc nip target position 1]\n'
          'borderRadius: all circular(8), nipMargin: 4, nipSize: 12 (All Default)\n'
          'nipTargetPosition=(borderRadius)+(nipMargin)+(nipSize/2)=8+4+(12/2)=18',
          SizedBox(
            width: double.infinity,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Balloon(
                  nipPosition: BalloonNipPosition.bottomLeft,
                  child: textWidget),
              Container(
                  width: 18,
                  color: Colors.redAccent,
                  child: const Text("w=18",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 10)))
            ]),
          ))
      ..addScenario(
          '[calc nip target position 2]\n'
          'borderRadius: all circular(12), nipMargin: 12, nipSize: 16\n'
          'nipTargetPosition = 12+12+(16/2) = 32',
          SizedBox(
            width: double.infinity,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Balloon(
                  nipPosition: BalloonNipPosition.bottomLeft,
                  borderRadius: BorderRadius.circular(12),
                  nipMargin: 12,
                  nipSize: 16,
                  child: const Column(children: [
                    Text("Calculate nip position",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                        onPressed: null,
                        child: Text("Test Button",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)))
                  ])),
              Container(
                  width: 32,
                  color: Colors.redAccent,
                  child: const Text("w=32",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 10)))
            ]),
          ));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'nip_target_position_grid');
  });

  testGoldens('shadow check', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello Flutter!");
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
      ..addScenario(
          'elevation: 0',
          const Balloon(
              shadow: MaterialBalloonShadow(elevation: 0), child: textWidget))
      ..addScenario('elevation: 4 (default), shadowColor: black26 (default)',
          const Balloon(child: textWidget))
      ..addScenario(
          'elevation: 12, shadowColor: black87',
          const Balloon(
              shadow: MaterialBalloonShadow(
                  elevation: 12, shadowColor: Colors.black87),
              child: textWidget))
      ..addScenario(
          'elevation: 24, shadowColor: redAccent',
          const Balloon(
              shadow: MaterialBalloonShadow(
                  elevation: 24, shadowColor: Colors.redAccent),
              child: textWidget))
      ..addScenario(
          'shadowColor: black54',
          const Balloon(
              shadow: MaterialBalloonShadow(shadowColor: Colors.black54),
              child: textWidget))
      ..addScenario(
          'shadowColor: deepPurpleAccent 0.32',
          Balloon(
              shadow: MaterialBalloonShadow(
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.32)),
              child: textWidget));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'shadow_grid');
  });

  testGoldens('custom shadow check', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello Flutter!");
    final builder = GoldenBuilder.grid(
        columns: 3,
        widthToHeightRatio: 0.7,
        wrap: (child) => Flexible(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: child,
            )))
      ..addScenario(
          'shadow: CustomBalloonShadow(\nBoxShadow(color: black12, offset: 0, 2, blur: 4, spread: 0))',
          const Balloon(
              shadow: CustomBalloonShadow(shadows: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0)
              ]),
              child: textWidget))
      ..addScenario(
          '[Edge Case] shadow: CustomBalloonShadow([\n'
          'BoxShadow(color: red, offset: -4, -8),\n'
          'BoxShadow(color: black54, offset: 4, 8]], color: white54)',
          const Balloon(
              color: Colors.white54,
              shadow: CustomBalloonShadow(shadows: [
                BoxShadow(color: Colors.red, offset: Offset(-4, -8)),
                BoxShadow(color: Colors.black54, offset: Offset(4, 8)),
              ]),
              child: textWidget))
      ..addScenario(
          'shadow: CustomBalloonShadow([\n'
          'BoxShadow(color: deepPurpleAccent 0.32, offset: -4, -8, blur: 4, spread: 2),\n'
          'BoxShadow(color: redAccent 0.48, offset: 4, 8, blur: 8, spread: 0)])',
          Balloon(
              shadow: CustomBalloonShadow(shadows: [
                BoxShadow(
                    color: Colors.deepPurpleAccent.withOpacity(0.32),
                    blurRadius: 4,
                    offset: const Offset(-4, -8),
                    spreadRadius: 2),
                BoxShadow(
                    color: Colors.redAccent.withOpacity(0.48),
                    offset: const Offset(4, 8),
                    blurRadius: 8,
                    spreadRadius: 0),
              ]),
              child: textWidget));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'custom_shadow_grid');
  });

  testGoldens('borderRadius and balloon color check', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello, Flutter!");
    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
      ..addScenario('borderRadius: BorderRadius.zero, color: white(default)',
          const Balloon(borderRadius: BorderRadius.zero, child: textWidget))
      ..addScenario(
          'borderRadius: BorderRadius.circular(8) (default), color: redAccent',
          const Balloon(color: Colors.redAccent, child: textWidget))
      ..addScenario(
          'borderRadius: BorderRadius.circular(14), color: grey',
          Balloon(
              borderRadius: BorderRadius.circular(14),
              color: Colors.grey,
              child: textWidget))
      ..addScenario(
          '[horizontal]\nborderRadius: BorderRadius.circular(99), color: deepPurpleAccent.shade100',
          Balloon(
              borderRadius: BorderRadius.circular(99),
              color: Colors.deepPurpleAccent.shade100,
              child: textWidget))
      ..addScenario(
          '[vertical, edge case]\nborderRadius: BorderRadius.circular(99), color: deepPurpleAccent.shade100',
          Balloon(
              borderRadius: BorderRadius.circular(99),
              color: Colors.deepPurpleAccent.shade100,
              nipPosition: BalloonNipPosition.bottomLeft,
              nipMargin: -6,
              child: const SizedBox(
                width: 40,
                child: textWidget,
              )));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'borderRadius_balloon_color_grid');
  });

  testGoldens('balloon with PositionedBalloon', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Press the button!");
    final heartButton = Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.all(Radius.circular(12))));

    final builder = GoldenBuilder.grid(
        columns: 3,
        widthToHeightRatio: 0.9,
        wrap: (child) => Container(
              alignment: Alignment.bottomCenter,
              height: (800 / 3) * 0.5,
              child: child,
            ))
      ..addScenario(
          'PositionedBalloon: Balloon(bottomLeft)',
          PositionedBalloon(
            balloon: const Balloon(
                nipPosition: BalloonNipPosition.bottomLeft, child: textWidget),
            child: heartButton,
          ))
      ..addScenario(
          'PositionedBalloon: Balloon(bottomCenter)',
          PositionedBalloon(
            balloon: const Balloon(
                nipPosition: BalloonNipPosition.bottomCenter,
                child: textWidget),
            child: heartButton,
          ))
      ..addScenario(
          'PositionedBalloon: Balloon(bottomRight, default)',
          PositionedBalloon(
            balloon: const Balloon(child: textWidget),
            child: heartButton,
          ))
      ..addScenario(
          'PositionedBalloon: Balloon(topLeft)\n/yOffset: 16',
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            PositionedBalloon(
              yOffset: 16,
              balloon: const Balloon(
                  nipPosition: BalloonNipPosition.topLeft, child: textWidget),
              child: heartButton,
            ),
            _heightIndicatorWidget(16),
          ]))
      ..addScenario(
          'PositionedBalloon: Balloon(topCenter)\n/yOffset: 0(default)',
          PositionedBalloon(
            yOffset: 0,
            balloon: const Balloon(
                nipPosition: BalloonNipPosition.topCenter, child: textWidget),
            child: heartButton,
          ))
      ..addScenario(
          'PositionedBalloon: Balloon(topRight)\n/yOffset: 4(default)',
          PositionedBalloon(
            balloon: const Balloon(
                nipPosition: BalloonNipPosition.topRight, child: textWidget),
            child: heartButton,
          ));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'positioned_balloon');
  });
}

Widget _heightIndicatorWidget(double height) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 1,
          color: Colors.blueAccent.withOpacity(0.8),
        ),
        Container(
          width: 2,
          height: height - 2,
          color: Colors.blueAccent.withOpacity(0.8),
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          child: Text("  h=$height",
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ),
        Container(
          width: 8,
          height: 1,
          color: Colors.blueAccent.withOpacity(0.8),
        ),
      ]);
}
