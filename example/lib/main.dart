import 'package:balloon_widget/balloon_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            background: Colors.deepPurple.shade50),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final showTooltip = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BalloonTapDelegator(
          child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                clipBehavior: Clip.none,
                title: PositionedBalloon.focusable(
                    yOffset: 6,
                    autofocus: true,
                    balloon: Balloon(
                      color: Theme.of(context).colorScheme.secondary,
                      nipPosition: BalloonNipPosition.topCenter,
                      child: Text.rich(
                          const TextSpan(children: [
                            TextSpan(
                                text:
                                    'this balloon is created by app bar title\n'),
                            TextSpan(
                                text: "want to remove? tap outside",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ),
                    childBuilder: (context, focusNode) {
                      return GestureDetector(
                          onTap: () => focusNode.hasFocus
                              ? focusNode.unfocus()
                              : focusNode.requestFocus(),
                          child: Text(widget.title));
                    }),
              ),
              body: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    ...BalloonNipPosition.values.map((e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Balloon(nipPosition: e, child: Text(e.name)),
                        )),
                  ])),
              floatingActionButton: ValueListenableBuilder(
                  valueListenable: showTooltip,
                  builder: (context, value, child) {
                    return PositionedBalloon.fade(
                      show: value,
                      balloon: Balloon(
                        nipPosition: BalloonNipPosition.bottomRight,
                        color: Theme.of(context).colorScheme.secondary,
                        padding: EdgeInsets.zero,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, top: 8, bottom: 8),
                                child: Text(
                                    'this balloon is\ncreated by\nfloating action button',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                                    textAlign: TextAlign.right),
                              ),
                              IconButton(
                                  iconSize: 24,
                                  tooltip: 'close',
                                  onPressed: () {
                                    showTooltip.value = false;
                                    print('close');
                                  },
                                  icon: const Icon(Icons.close,
                                      color: Colors.white)),
                            ]),
                      ),
                      child: FloatingActionButton(
                        onPressed: () {
                          showTooltip.value = !showTooltip.value;
                        },
                        tooltip: 'open help',
                        child: Icon(
                            value ? Icons.close : Icons.live_help_outlined),
                      ),
                    );
                  }))),
    );
  }
}
