import 'package:detection/Screen/botttom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Animationn extends StatefulWidget {
  const Animationn({Key? key}) : super(key: key);

  @override
  State<Animationn> createState() => _AnimationState();
}

class _AnimationState extends State<Animationn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      value: 0,
      lowerBound: 0,
      upperBound: 4,
      vsync: this,
    );
    _pageController = PageController(initialPage: 0);

    // This will automatically navigate to the next page after 2 seconds.
    _controller.forward().then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Bottom_Nav_Bar()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helmet Detection'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          child: Container(
            width: 4000.0,
            height: 200.0,
            color: Colors.teal,
            padding: const EdgeInsets.all(10),
            child: const Center(
              child: Text(
                'Helmet Detection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
