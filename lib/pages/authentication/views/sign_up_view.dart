import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView(
      {super.key,
      required this.emailSignUpCallback,
      required this.signInRequestCallback});
  final Future<String?> Function(String name, String email, String password)
      emailSignUpCallback;
  final void Function(String? email, String? password) signInRequestCallback;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? errorMessage;
  bool isSubmitting = false;
  CrossFadeState crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

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

  /// Method to invoke the sign up callback and update the UI accordingly
  Future<void> _handleSignUp() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;

        // Use animated cross fade to hide the error label
        crossFadeState = CrossFadeState.showFirst;
      });

      // Get email and password from the form
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        // Invoke sign up callback
        final error = await widget.emailSignUpCallback(name, email, password);

        // If there's a sign up, error, then display the error label
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
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
              // Name text field
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  final emailRegex = RegExp(r'\w+');
                  if (!emailRegex.hasMatch(value)) {
                    return "Please only use alphanumeric characters";
                  }
                  return null;
                },
              ),
              // Add space
              const SizedBox(height: 16),

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

              // Add space
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

              // Sign Up button
              FilledButton(
                onPressed: isSubmitting ? null : _handleSignUp,
                child: isSubmitting
                    ?
                    // Show loading icon when submitting
                    const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )
                    :
                    // Display sign up text in button when not submitting
                    const Text("Sign Up"),
              ),
              Row(
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      String? email = emailController.text.trim();
                      String? password = passwordController.text.trim();
                      widget.signInRequestCallback(email, password);
                    },
                    child: const Text("Sign In"),
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
