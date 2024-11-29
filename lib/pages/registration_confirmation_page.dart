import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/navigation/route_names.dart';
import 'package:rive/rive.dart';
import 'package:confetti/confetti.dart';

class RegistrationConfirmationPage extends StatefulWidget {
  const RegistrationConfirmationPage({super.key});

  @override
  State<RegistrationConfirmationPage> createState() =>
      _RegistrationConfirmationPageState();
}

class _RegistrationConfirmationPageState
    extends State<RegistrationConfirmationPage> {
  late ConfettiController _confettiController;
  late SimpleAnimation _riveController;
  bool _confettiTriggered = false;

  @override
  void initState() {
    super.initState();

    // Initialize confetti controller
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Trigger an initail cofetti
    _confettiController.play();

    // Initialize Rive animation controller with the animation named 'idle'
    _riveController = SimpleAnimation('idle');

    // Add listener to the Rive controller to monitor progress
    _riveController.isActiveChanged.addListener(() {
      if (_riveController.isActive) {
        // Start monitoring progress
        WidgetsBinding.instance.addPostFrameCallback(_trackProgress);
      }
    });
  }

  /// Track the progress of the rive animation using the progress field
  /// When the animation is close to 50% that is when the ball is bouncing
  /// trigger confetti when the ball bounces
  void _trackProgress(_) {
    if (_riveController.instance != null) {
      final progress = _riveController.instance!.progress;

      // Check if the progress is within the target range close to 50%
      if (progress >= 0.48 && progress <= 0.52 && !_confettiTriggered) {
        _confettiController.play();
        _confettiTriggered = true;
      }

      // Continue tracking while the animation is active
      if (_riveController.isActive) {
        WidgetsBinding.instance.addPostFrameCallback(_trackProgress);
      }

      // Reset confetti trigger if animation loops
      if (progress >= 0.95) {
        _confettiTriggered = false;
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose of controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "You're going to the game!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  child: RiveAnimation.asset(
                    'assets/animations/basketball_bounce.riv',
                    controllers: [_riveController],
                    onInit: (_) {
                      _riveController.isActive = true; // Start animation
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context
                            .goNamed(RouteNames.sports); // Navigate to /sports
                      },
                      child: const Text('Looking for more games?'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .goNamed(RouteNames.myGames); // Navigate to /myGame
                      },
                      child: const Text('See my games'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0.0, 0.22), // Align with shadow of ball
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.99,
              numberOfParticles: 10,
              maxBlastForce: 40,
              minBlastForce: 30,
              gravity: 0.3,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
              ],
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}
