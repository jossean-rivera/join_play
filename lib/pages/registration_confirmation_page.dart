import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:confetti/confetti.dart';

import '../navigation/route_names.dart';

class RegistrationConfirmationPage extends StatefulWidget {
  const RegistrationConfirmationPage({super.key});

  @override
  State<RegistrationConfirmationPage> createState() =>
      _RegistrationConfirmationPageState();
}

class _RegistrationConfirmationPageState
    extends State<RegistrationConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _labelController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _sizeAnimation;
  late ConfettiController _confettiController;
  late SimpleAnimation _riveController;
  bool _confettiTriggered = false;
  bool _labelTriggered = false;

  @override
  void initState() {
    super.initState();

    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 20));

    // Initialize animation controller that manages the label
    _labelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    CurvedAnimation curvedAnimation =
        CurvedAnimation(parent: _labelController, curve: Curves.easeInBack);

    // Create tweens for size and elevation
    _elevationAnimation =
        Tween<double>(begin: 80, end: 0).animate(curvedAnimation);
    _sizeAnimation =
        Tween<double>(begin: 1.0, end: 1.4).animate(curvedAnimation);

    // Trigger initial confetti
    _confettiController.play();

    // Initialize Rive animation controller with the animation named 'idle'
    _riveController = SimpleAnimation('idle');

    // Add listener to the Rive controller to monitor progress
    _riveController.isActiveChanged.addListener(() {
      if (_riveController.isActive) {
        WidgetsBinding.instance.addPostFrameCallback(_trackProgress);
      }
    });
  }

  void _trackProgress(_) {
    if (_riveController.instance != null) {
      final progress = _riveController.instance!.progress;

      if (progress >= 0.48 && progress <= 0.52 && !_confettiTriggered) {
        _confettiController.play();
        _confettiTriggered = true;
      }

      if (!_labelTriggered && progress >= 0.45 && progress <= 0.48) {
        _labelController.forward();
        _labelTriggered = true;
      }

      if (_riveController.isActive) {
        WidgetsBinding.instance.addPostFrameCallback(_trackProgress);
      }

      if (progress >= 0.95) {
        _confettiTriggered = false;
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Confirmation'),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: AnimatedBuilder(
                  animation: _labelController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _elevationAnimation.value),
                      child: Transform.scale(
                        scale: _sizeAnimation.value,
                        child: Text(
                          "You're going to the game!",
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navLargeTitleTextStyle,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: RiveAnimation.asset(
                    'assets/animations/basketball_bounce.riv',
                    controllers: [_riveController],
                    onInit: (_) {
                      _riveController.isActive = true;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    CupertinoButton.filled(
                      onPressed: () {
                        context.goNamed(RouteNames.myGames);
                      },
                      child: const Text('Check my games'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Looking for more games?',
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                    CupertinoButton(
                      onPressed: () {
                        context.goNamed(RouteNames.sports);
                      },
                      child: const Text('Go back.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0.0, 0.22),
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.99,
              numberOfParticles: 10,
              maxBlastForce: 40,
              minBlastForce: 30,
              gravity: 0.3,
              colors: const [
                CupertinoColors.systemRed,
                CupertinoColors.activeBlue,
                CupertinoColors.systemGreen,
                CupertinoColors.systemOrange,
                CupertinoColors.systemPurple,
                CupertinoColors.systemYellow,
              ],
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}
    