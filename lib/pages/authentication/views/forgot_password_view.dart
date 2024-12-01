import 'package:flutter/material.dart';

import '../../../custom_theme_data.dart';

class ForgotPasswordView extends StatefulWidget {
  final Future<String?> Function(String email) emailForgotPasswordCallback;

  final Function(String? initEmail) signInRequestCallback;

  final String? initEmail;

  const ForgotPasswordView({
    super.key,
    this.initEmail = '',
    required this.emailForgotPasswordCallback,
    required this.signInRequestCallback,
  });

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordView();
}

class _ForgotPasswordView extends State<ForgotPasswordView> {
  late TextEditingController emailController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isSubmitting = false;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initEmail);

    // Clear error on typing
    emailController.addListener(_clearError);
  }

  /// Updates the state to remove the error label from the UI
  void _clearError() {
    if (errorMessage != null) {
      setState(() {
        errorMessage = null;

        // Use animated cross fade to hide the error label
        crossFadeState = CrossFadeState.showFirst;
      });
    }
  }

  /// Method to invoke the forgot password callback and update the UI accordingly
  Future<void> _handleForgotPaassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;

        // Use animated cross fade to hide the error label
        crossFadeState = CrossFadeState.showFirst;
      });

      final email = emailController.text.trim();

      try {
        // Invoke forgot password callback
        final error = await widget.emailForgotPasswordCallback(email);

        if (error != null) {
          if (mounted) {
            setState(() {
              // Set the text of the error label
              errorMessage = error;

              // Use animated cross fade to show the error label
              crossFadeState = CrossFadeState.showSecond;
            });
          }
        } else {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Password Reset"),
                  content: Text(
                    "Please check your email for a password reset link. "
                    "Once you set a new password, you can log in on the Sign In screen.",
                  ),
                );
              },
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo-darker.png',
                  height: 300,
                ),
              ),
              Text('Forgot your password?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8), // Add some spacing
              Text('Enter your email address to reset your password.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24), // Add some spacing

              // Error message
              AnimatedCrossFade(
                crossFadeState: crossFadeState,
                duration: const Duration(milliseconds: 300),
                firstChild: Container(),
                secondChild: SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: CustomColors.lightError,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      errorMessage ?? '',
                      style: const TextStyle(color: CustomColors.darkerError),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Email text field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Login button
              FilledButton(
                onPressed: isSubmitting ? null : _handleForgotPaassword,
                child: isSubmitting
                    ?
                    // Show loading icon when submitting
                    const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )
                    :
                    // Display log in text in button when not submitting
                    const Text("Reset"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Changed your mind?"),
                  TextButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      widget.signInRequestCallback(email);
                    },
                    child: const Text("Cancel"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
