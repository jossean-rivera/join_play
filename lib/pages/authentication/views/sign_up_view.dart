import 'package:flutter/cupertino.dart';
import '../../../custom_theme_data.dart';

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
  bool isSubmitting = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController(text: widget.initEmail);
    passwordController = TextEditingController(text: widget.initPassword);
  }

  Future<void> _handleSignUp() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
      });

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        final error = await widget.emailSignUpCallback(name, email, password);

        if (error != null) {
          // Show any additional error (if returned from the server)
          setState(() {
            isSubmitting = false;
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
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Main content (form fields and button)
              Expanded(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name field with error message
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: CupertinoColors.systemGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CupertinoTextFormFieldRow(
                              controller: nameController,
                              placeholder: "Name",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                              style: const TextStyle(fontSize: 16),
                              decoration: null, // Remove Cupertino default border
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formKey.currentState?.validate() == false
                                ? "Please enter your name"
                                : "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.destructiveRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Email field with error message
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: CupertinoColors.systemGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: CupertinoTextFormFieldRow(
                              controller: emailController,
                              placeholder: "Email",
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                final emailRegex =
                                    RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value)) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                              style: const TextStyle(fontSize: 16),
                              decoration: null, // Remove Cupertino default border
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formKey.currentState?.validate() == false
                                ? "Please enter your email"
                                : "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.destructiveRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Password field with toggle and error message
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: CupertinoColors.systemGrey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CupertinoTextFormFieldRow(
                                    controller: passwordController,
                                    placeholder: "Password",
                                    obscureText: !isPasswordVisible,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter your password";
                                      }
                                      if (value.length < 6) {
                                        return "Password must be at least 6 characters";
                                      }
                                      return null;
                                    },
                                    style: const TextStyle(fontSize: 16),
                                    decoration:
                                        null, // Remove Cupertino default border
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                  child: Icon(
                                    isPasswordVisible
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formKey.currentState?.validate() == false
                                ? "Please enter your password"
                                : "",
                            style: const TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.destructiveRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Sign Up button
                      CupertinoButton.filled(
                        onPressed: isSubmitting ? null : _handleSignUp,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: isSubmitting
                            ? const CupertinoActivityIndicator()
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer text at the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  CupertinoButton(
                    onPressed: () {
                      String? email = emailController.text.trim();
                      String? password = passwordController.text.trim();
                      widget.signInRequestCallback(email, password);
                    },
                    padding: EdgeInsets.zero,
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
