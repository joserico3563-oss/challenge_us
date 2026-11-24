import 'package:flutter/material.dart';

class RecochaScaffold extends StatelessWidget {
  const RecochaScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFF101D30)),
        Image.asset(
          'assets/larecocha/backgrounds/background.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const ColoredBox(color: Color(0x40000000)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          bottomNavigationBar: bottomNavigationBar,
        ),
      ],
    );
  }
}
