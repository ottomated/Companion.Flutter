import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_particles/particles.dart';

class SelfCheckInPage extends StatefulWidget {
  @override
  _SelfCheckInPageState createState() => _SelfCheckInPageState();
}

class _SelfCheckInPageState extends State<SelfCheckInPage>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        var title = 'codeday';
        var index = (_controller.value * 3 * title.length).floor() % title.length;
        title = title.substring(0, index) +
            title[index].toUpperCase() +
            title.substring(index + 1);
        return _SelfCheckInScaffold(
          title: title,
          color:
              HSLColor.fromAHSL(1, _controller.value * 360, 0.7, 0.7).toColor(),
        );
      },
    );
  }
}

class _SelfCheckInScaffold extends StatelessWidget {
  final String title;
  final Color color;
  _SelfCheckInScaffold({this.title, this.color});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Center(
          child: Text(this.title),
        ),
        backgroundColor: color.withAlpha(50),
      ),
      body: Stack(
        children: <Widget>[
          Particles(30, Colors.white),
          Center(
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: color,
                  blurRadius: 40,
                  spreadRadius: 20,
                )
              ]),
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'M4F2',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: size.width / 5,
                        letterSpacing: size.width / 20,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: size.width / 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
