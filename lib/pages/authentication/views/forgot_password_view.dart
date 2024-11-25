import 'package:flutter/material.dart';

class ForgotPasswordView extends StatefulWidget {
  final Future<String?> Function(String email)
      emailForgotPasswordCallback;

  final Function() signInRequestCallback;

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

  /// Method to invoke the loging callback and update the UI accordingly
  Future<void> _handleLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;

        // Use animated cross fade to hide the error label
        crossFadeState = CrossFadeState.showFirst;
      });

      // Get email and password from the form
      final email = emailController.text.trim();

      try {
        // Invoke login callback
        final error = await widget.emailForgotPasswordCallback(email);

        // If there's a login, error, then display the error label
        if (error != null) {
          setState(() {
            // Set the text of the error label
            errorMessage = error;

            // Use animated cross fade to show the error label
            crossFadeState = CrossFadeState.showSecond;
          });
        }
      } finally {
        setState(() {
          isSubmitting = false;
        });
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
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      errorMessage ?? '',
                      style: TextStyle(color: Colors.red.shade700),
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
                onPressed: isSubmitting ? null : _handleLogin,
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
              Row(
                children: [
                  const Text("Changed your mind?"),
                  TextButton(
                    onPressed: widget.signInRequestCallback,
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
