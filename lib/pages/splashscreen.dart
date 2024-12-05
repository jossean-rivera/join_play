import 'package:flutter/cupertino.dart';
import 'package:join_play/custom_theme_data.dart';
import 'package:join_play/navigation/router.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/navigation/route_names.dart';

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
      duration: const Duration(milliseconds: 1000), // Total duration for all letters
    );

    // Animation Controller for basketball
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Basketball drop duration
    );

    

    // Start letters animation and trigger basketball animation after it's done
    _lettersController.forward().whenComplete(() {
      setState(() {
        _showBall = true; // Show the ball
      });
      _ballController.forward().whenComplete((){
        Future.delayed(Duration(microseconds: 4000),() {
          if(mounted){
            context.goNamed(RouteNames.login);
          }
        });
      }); // Start basketball animation
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
    // Get screen width using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final Brightness brightness = MediaQuery.platformBrightnessOf(context);

    final bool isDarkMode = brightness == Brightness.dark;
    final Color backgroundColor = 
        isDarkMode? CupertinoColors.black : CupertinoColors.white;
    final Color textColor = isDarkMode? CupertinoColors.white : CupertinoColors.black;
    final Color shadowColor = isDarkMode? CupertinoColors.systemGrey : CupertinoColors.systemGrey4;

    // Generate staggered animations for each letter, starting from the last letter
    _animations = List.generate(_letters.length, (index) {
      // Reverse the order by using (_letters.length - index - 1)
      ///final start = (_letters.length - index - 1) / _letters.length; // Start time
      ///final end = (_letters.length - index) / _letters.length; // End time
      final startDelay = (_letters.length -index - 1) * 0.1;
      return Tween<Offset>(
        begin: Offset(-screenWidth, 0.0), // Start completely off-screen
        end: Offset(0.0, 0.0), // End at its position
      ).animate(CurvedAnimation(
        parent: _lettersController,
        curve: Interval(
          startDelay, // Staggered start for reverse order
          startDelay + 0.4, // Staggered end for reverse order
          curve: Curves.easeInOut,
        ),
      ));
    });

    // Basketball Animation
    _ballAnimation = Tween<double>(
      begin: -screenHeight, // Start above the screen
      end: 0, // End at the SizedBox position
    ).animate(CurvedAnimation(
      parent: _ballController,
      curve: Curves.bounceOut, // Smooth drop with bounce
    ));

    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: brightness,
        primaryColor: CupertinoColors.activeBlue,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Letters Animation
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // "J"
                  SlideTransition(
                    position: _animations[0],
                    child: CustomTheme.threeDText(
                      text: _letters[0],
                      fontSize: 50,
                      textColor: textColor,
                      shadowColor: shadowColor,
                      shadowOffsetX: 3,
                      shadowOffsetY: 3,
                      blurRadius: 4,
                    ),
                  ),
                  // Add a SizedBox with a fixed width of 50 between "J" and "i"
                  SizedBox(width: 50),
                  // Remaining letters ("i", "n", "P", "l", "a", "y")
                  ...List.generate(_letters.length - 1, (index) {
                    return SlideTransition(
                      position: _animations[index + 1],
                      child: CustomTheme.threeDText(
                        text: _letters[index + 1],
                        fontSize: 50,
                        textColor: textColor,
                        shadowColor: shadowColor,
                        shadowOffsetX: 3,
                        shadowOffsetY: 3,
                        blurRadius: 4,
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Basketball Drop Animation
            if (_showBall)
              AnimatedBuilder(
                animation: _ballAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _ballAnimation.value + (screenHeight / 2) - 25, // Calculate drop position
                    left: (screenWidth / 2) - 85, // Align with the SizedBox
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
      ),
    );
  }
}
