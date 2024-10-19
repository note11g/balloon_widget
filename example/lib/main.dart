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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .colorScheme
              .inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...BalloonNipPosition.values.map((e) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Balloon(nipPosition: e, child: Text(e.name)),
                  ))
            ])),
        floatingActionButton: ValueListenableBuilder(
            valueListenable: showTooltip,
            builder: (context, value, child) {
              return PositionedBalloon(
                show: value,
                balloon: Balloon(
                  nipPosition: BalloonNipPosition.bottomRight,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  child: Text(
                      'this balloon is\ncreated by\nfloating action button',
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSecondary),
                      textAlign: TextAlign.right),
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    showTooltip.value = !showTooltip.value;
                  },
                  tooltip: 'open help',
                  child: Icon(value ? Icons.close : Icons.live_help_outlined),
                ),
              );
            }));
  }
}
