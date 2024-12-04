import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/navigation/route_names.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _ballAnimation;

  final List<IconData> _sportsIcons = [
    Icons.sports_basketball,
    Icons.sports_volleyball,
    Icons.sports_baseball,
    Icons.sports_soccer,
    Icons.sports_football,
    Icons.sports_rugby,
  ];

  int _currentIconIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animation Controller for bounce
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Adjust for smooth bounce
    );

    // Bouncing Animation
    _ballAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reverse the bounce animation
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Change the ball after the full bounce (up and down)
        setState(() {
          _currentIconIndex = (_currentIconIndex + 1) % _sportsIcons.length;
        });
        // Start the next bounce
        _controller.forward();
      }
    });

    _controller.forward();

    // Redirect to the next screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.goNamed(RouteNames.login); // Redirect handled by router
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "J",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            SlideTransition(
              position: _ballAnimation,
              child: Icon(
                _sportsIcons[_currentIconIndex],
                size: 50,
                color: Colors.orange,
              ),
            ),
            Text(
              "inPlay",
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
