import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/navigation/route_names.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _jController;
  late Animation<Offset> _jAnimation;

  late AnimationController _lettersController;
  late List<Animation<Offset>> _lettersAnimations;

  late AnimationController _ballController;
  late Animation<Offset> _ballAnimation;

  final String _letters = "inPlay";

  bool _showball = false;

  @override
  void initState() {
    super.initState();

    // Animation for "J"
    _jController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _jAnimation = Tween<Offset>(
      begin: Offset(-5.0, 0.0), // Start from outside the left of the screen
      end: Offset(0.0, 0.0), // End at its original position
    ).animate(CurvedAnimation(
      parent: _jController,
      curve: Curves.easeInOut,
    ));

    // Animation for "inPlay"
    _lettersController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _lettersAnimations = List.generate(
      _letters.length,
      (index) => Tween<Offset>(
        begin: Offset(20.0, 0.0), // Start from outside the right of the screen
        end: Offset(0.0, 0.0), // End at its original position
      ).animate(CurvedAnimation(
        parent: _lettersController,
        curve: Interval(
          index * 0.1, // Delay each letter slightly
          1.0,
          curve: Curves.easeInOut,
        ),
      )),
    );

    // Animation for the ball
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ballAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.5), // Bounce upwards
    ).animate(CurvedAnimation(
      parent: _ballController,
      curve: Curves.bounceOut,
    ));

    _ballController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _ballController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _ballController.forward();
      }
    });

    // Start animations sequentially
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await _jController.forward(); // Slide "J"
    await _lettersController.forward(); 
    setState((){
      _showball = true;
    });// Slide "inPlay"
    _ballController.forward(); // Start ball bounce
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.goNamed(RouteNames.login);
      }
    });
  }

  @override
  void dispose() {
    _jController.dispose();
    _lettersController.dispose();
    _ballController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool isDarkMode = brightness == Brightness.dark;

    final Color backgroundColor = isDarkMode ? CupertinoColors.black : CupertinoColors.white;
    final Color textColor = isDarkMode ? CupertinoColors.white : CupertinoColors.black;

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: brightness,
        primaryColor: CupertinoColors.systemRed,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Center(
          child: Row(

            mainAxisSize: MainAxisSize.min,
            children: [
              // "J" sliding in from the left
              SlideTransition(
                position: _jAnimation,
                child: Text(
                  "J",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if(_showball)
                SlideTransition(
                  position: _ballAnimation,
                  child: Image.asset(
                    'assets/images/balls/basketball.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              // "inPlay" letters sliding in one by one from the right
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_letters.length, (index) {
                  return SlideTransition(
                    position: _lettersAnimations[index],
                    child: Text(
                      _letters[index],
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                }),
              ),
              // Ball appears after letters are in place
              
            ],
          ),
        ),
      ),
    );
  }
}
