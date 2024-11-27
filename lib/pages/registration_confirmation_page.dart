import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RegistrationConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: RiveAnimation.asset(
            'assets/animations/cyclist.riv',
            animations: [
              'Timeline 1'
            ], // Use the exact name from the Rive editor
          ),
        ),
      ),
    );
  }
}
