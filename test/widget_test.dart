import 'package:balloon_widget/balloon_widget.dart';
import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  testGoldens('Nip Position should look correct', (tester) async {
    await loadAppFonts();

    const textWidget = Text("Hello Flutter!");
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario(
          'Nip topLeft',
          const Balloon(
              nipPosition: BalloonNipPosition.topLeft, child: textWidget))
      ..addScenario(
          'Nip topRight',
          const Balloon(
              nipPosition: BalloonNipPosition.topRight, child: textWidget))
      ..addScenario(
          'Nip bottomLeft',
          const Balloon(
              nipPosition: BalloonNipPosition.bottomLeft, child: textWidget))
      ..addScenario(
          'Nip bottomRight',
          const Balloon(
              nipPosition: BalloonNipPosition.bottomRight, child: textWidget));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'nip_position_grid');
  });

  testGoldens('inner Padding check', (tester) async {
    await loadAppFonts();

    final containerWidget =
        Container(color: Colors.blueAccent, width: 64, height: 40);
    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario('padding zero',
          Balloon(padding: EdgeInsets.zero, child: containerWidget))
      ..addScenario(
          'padding 12',
          Balloon(
            padding: const EdgeInsets.all(12),
            child: containerWidget,
          ));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'inner_padding_grid');
  });
}
