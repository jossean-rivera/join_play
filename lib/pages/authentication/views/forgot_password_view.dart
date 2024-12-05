import 'package:flutter/cupertino.dart';
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

  void _clearError() {
    if (errorMessage != null) {
      setState(() {
        errorMessage = null;
        crossFadeState = CrossFadeState.showFirst;
      });
    }
  }

  Future<void> _handleForgotPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isSubmitting = true;
        errorMessage = null;
        crossFadeState = CrossFadeState.showFirst;
      });

      final email = emailController.text.trim();

      try {
        final error = await widget.emailForgotPasswordCallback(email);

        if (error != null) {
          if (mounted) {
            setState(() {
              errorMessage = error;
              crossFadeState = CrossFadeState.showSecond;
            });
          }
        } else {
          if (mounted) {
            await showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: const Text("Password Reset"),
                  content: const Text(
                    "Please check your email for a password reset link. "
                    "Once you set a new password, you can log in on the Sign In screen.",
                  ),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text("OK"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Forgot Password'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo-darker.png',
                  height: 300,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Forgot your password?',
                textAlign: TextAlign.center,
                style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address to reset your password.',
                textAlign: TextAlign.center,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 24),

              // Error message
              AnimatedCrossFade(
                crossFadeState: crossFadeState,
                duration: const Duration(milliseconds: 300),
                firstChild: Container(),
                secondChild: Container(
                  padding: const EdgeInsets.all(8.0),
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

              // Email text field
              CupertinoTextFormFieldRow(
                controller: emailController,
                placeholder: "Email",
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

              // Reset button
              CupertinoButton.filled(
                onPressed: isSubmitting ? null : _handleForgotPassword,
                child: isSubmitting
                    ? const CupertinoActivityIndicator()
                    : const Text("Reset"),
              ),
              const SizedBox(height: 16),

              // Cancel link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Changed your mind?"),
                  CupertinoButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      widget.signInRequestCallback(email);
                    },
                    child: const Text("Cancel"),
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
