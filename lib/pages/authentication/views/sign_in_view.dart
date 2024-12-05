import 'package:flutter/cupertino.dart';
import '../../../custom_theme_data.dart';

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
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.initEmail);
    passwordController = TextEditingController(text: widget.initPassword);

    // Clear error on typing
    emailController.addListener(_clearError);
    passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (errorMessage != null) {
      setState(() {
        errorMessage = null;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        final error = await widget.loginSubmitCallback(email, password);

        if (error != null) {
          setState(() {
            errorMessage = error;
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
    return CupertinoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main content: Logo and fields
            Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/images/logo-darker.png',
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: CustomColors.lightError,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: CustomColors.darkerError),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Email text field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: CupertinoTextField(
                        controller: emailController,
                        placeholder: "Email",
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 16),
                        decoration: null, // Remove default Cupertino border
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password text field with toggle
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.systemGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              placeholder: "Password",
                              style: const TextStyle(fontSize: 16),
                              decoration: null, // Remove default Cupertino border
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
                    const SizedBox(height: 32),

                    // Login button
                    CupertinoButton.filled(
                      onPressed: isSubmitting ? null : _handleLogin,
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: isSubmitting
                          ? const CupertinoActivityIndicator()
                          : const Text(
                              "Log In",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer links at the bottom
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    CupertinoButton(
                      onPressed: () {
                        String email = emailController.text.trim();
                        String password = passwordController.text.trim();
                        widget.signUpRequestCallback(email, password);
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Forgot password? "),
                    CupertinoButton(
                      onPressed: () {
                        String email = emailController.text.trim();
                        widget.forgotPasswordRequestCallback(email);
                      },
                      padding: EdgeInsets.zero,
                      child: Text(
                        "Reset",
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
          ],
        ),
      ),
    );
  }
}
