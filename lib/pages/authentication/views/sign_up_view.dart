import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({
    super.key,
    this.initEmail,
    this.initPassword,
    required this.emailSignUpCallback,
    required this.signInRequestCallback,
  });

  final Future<String?> Function(String name, String email, String password)
      emailSignUpCallback;
  final void Function(String? email, String? password) signInRequestCallback;

  final String? initEmail;
  final String? initPassword;

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
    emailController = TextEditingController(text: widget.initEmail);
    passwordController = TextEditingController(text: widget.initPassword);

    emailController.addListener(_clearError);
    passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (errorMessage != null) {
      setState(() {
        errorMessage = null;
        crossFadeState = CrossFadeState.showFirst;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;
        crossFadeState = CrossFadeState.showFirst;
      });

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        final error = await widget.emailSignUpCallback(name, email, password);

        if (error != null) {
          setState(() {
            errorMessage = error;
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo-dark.png',
                  height: 300,
                ),
              ),
              Text('Create an account',
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )
                    : const Text("Sign Up"),
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
