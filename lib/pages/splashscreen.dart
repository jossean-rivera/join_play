import 'dart:async';
import 'package:join_play/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../navigation/route_names.dart';
import '../navigation/route_paths.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lettersController;
  late AnimationController _ballController;
  late Animation<double> _ballAnimation;
  late List<Animation<Offset>> _animations;

  final String _letters = "JinPlay";
  bool _showBall = false;

  @override
  void initState() {
    super.initState();

    // Animation Controller for letters
    _lettersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animation Controller for basketball
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Start letters animation and trigger basketball animation after it's done
    _lettersController.forward().whenComplete(() {
      setState(() {
        _showBall = true;
      });
      _ballController.forward();
    });

    // Navigate after a fixed duration

      Timer(const Duration(seconds: 5),(){
        if (mounted) {
        // Unconditionally navigate to the login screen after splash
        context.goNamed(RouteNames.login);
      } 
    });
  }

  @override
  void dispose() {
    _lettersController.dispose();
    _ballController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    _animations = List.generate(_letters.length, (index) {
      final startDelay = (_letters.length - index - 1) * 0.1;
      return Tween<Offset>(
        begin: Offset(-screenWidth, 0.0),
        end: Offset(0.0, 0.0),
      ).animate(CurvedAnimation(
        parent: _lettersController,
        curve: Interval(
          startDelay,
          startDelay + 0.4,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _ballAnimation = Tween<double>(
      begin: -screenHeight,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _ballController,
      curve: Curves.bounceOut,
    ));

    return Scaffold(
      backgroundColor: CustomColors.navyBlue,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _animations[0],
                  child: Text(
                    _letters[0],
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 50),
                ...List.generate(_letters.length - 1, (index) {
                  return SlideTransition(
                    position: _animations[index + 1],
                    child: Text(
                      _letters[index + 1],
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_showBall)
            AnimatedBuilder(
              animation: _ballAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _ballAnimation.value + (screenHeight / 2) - 25,
                  left: (screenWidth / 2) - 85,
                  child: Image.asset(
                    'assets/images/balls/basketball.png',
                    width: 50,
                    height: 50,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
