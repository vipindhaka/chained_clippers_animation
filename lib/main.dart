import 'dart:math';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

enum CircleSide { left, right }

extension ToPath on CircleSide {
  Path toPath(Size size) {
    final path = Path();
    late Offset offset;
    late bool clockwise;

    switch (this) {
      case CircleSide.left:
        path.moveTo(size.width, 0);
        offset = Offset(size.width, size.height);
        clockwise = false;
        break;
      case CircleSide.right:
        offset = Offset(0, size.height);
        clockwise = true;
        break;
    }
    path.arcToPoint(
      offset,
      radius: Radius.elliptical(size.height / 2, size.width / 2),
      clockwise: clockwise,
    );
    path.close();
    return path;
  }
}

class HalfCircleClipper extends CustomClipper<Path> {
  final CircleSide side;

  HalfCircleClipper(this.side);
  @override
  Path getClip(Size size) => side.toPath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late AnimationController _counterClockwiseRotationController;
  late Animation<double> _counterClockwiseRotationAnimation;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _counterClockwiseRotationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _counterClockwiseRotationAnimation = Tween<double>(begin: 0, end: -(pi / 2))
        .animate(CurvedAnimation(
            parent: _counterClockwiseRotationController,
            curve: Curves.bounceOut));

    _flipController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
        CurvedAnimation(parent: _flipController, curve: Curves.bounceOut));

    _counterClockwiseRotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flipAnimation = Tween<double>(
                begin: _flipAnimation.value, end: _flipAnimation.value + pi)
            .animate(CurvedAnimation(
                parent: _flipController, curve: Curves.bounceOut));

        _flipController
          ..reset()
          ..forward();
      }
    });

    _flipController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _counterClockwiseRotationAnimation = Tween<double>(
                begin: _counterClockwiseRotationAnimation.value,
                end: _counterClockwiseRotationAnimation.value + -(pi / 2))
            .animate(CurvedAnimation(
                parent: _counterClockwiseRotationController,
                curve: Curves.bounceOut));

        _counterClockwiseRotationController
          ..reset()
          ..forward();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _counterClockwiseRotationController.removeStatusListener((status) {});
    _flipController.removeStatusListener((status) {});
    _counterClockwiseRotationController.dispose();
    _flipController.dispose();
    

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () {
      _counterClockwiseRotationController
        ..reset()
        ..forward();
    });
    return SafeArea(
      child: Scaffold(
        body: AnimatedBuilder(
            animation: _counterClockwiseRotationController,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..rotateZ(_counterClockwiseRotationAnimation.value),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) => Transform(
                        transform: Matrix4.identity()
                          ..rotateY(_flipAnimation.value),
                        alignment: Alignment.centerRight,
                        child: ClipPath(
                          clipper: HalfCircleClipper(CircleSide.left),
                          child: Container(
                            height: 200,
                            width: 200,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _flipController,
                      builder: (context, child) => Transform(
                        transform: Matrix4.identity()
                          ..rotateY(_flipAnimation.value),
                        alignment: Alignment.centerLeft,
                        child: ClipPath(
                          clipper: HalfCircleClipper(CircleSide.right),
                          child: Container(
                            height: 200,
                            width: 200,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}
