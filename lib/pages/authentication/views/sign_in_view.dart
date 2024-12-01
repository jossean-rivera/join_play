import 'package:flutter/material.dart';
import 'package:join_play/custom_theme_data.dart';

class SignInView extends StatefulWidget {
  final Future<String?> Function(String email, String password)
      loginSubmitCallback;

  final Function(String initEmail, String? initPassword) signUpRequestCallback;
  final Function(String? initEmail) forgotPasswordRequestCallback;

  final String? initEmail;
  final String? initPassword;

  const SignInView({
    super.key,
    this.initEmail = '',
    this.initPassword = '',
    required this.loginSubmitCallback,
    required this.signUpRequestCallback,
    required this.forgotPasswordRequestCallback,
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isSubmitting = false;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initEmail);
    passwordController = TextEditingController(text: widget.initPassword);

    // Clear error on typing
    emailController.addListener(_clearError);
    passwordController.addListener(_clearError);
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
      final password = passwordController.text.trim();

      try {
        // Invoke login callback
        final error = await widget.loginSubmitCallback(email, password);

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
    passwordController.dispose();
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
              Text('LOG INTO YOUR ACCOUNT',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24), // Add some spacing below the logo

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
              const SizedBox(height: 16),

              // Password text field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
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
                    const Text("Log In"),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      widget.signUpRequestCallback(email, password);
                    },
                    child: const Text("Sign Up"),
                  )
                ],
              ),
              Row(
                children: [
                  const Text("Forgot password?"),
                  TextButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      widget.forgotPasswordRequestCallback(email);
                    },
                    child: const Text("Reset"),
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
