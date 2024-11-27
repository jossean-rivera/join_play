import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:join_play/pages/authentication/views/forgot_password_view.dart';
import 'package:join_play/pages/authentication/views/initial_loading_view.dart';

import '../../blocs/authentication/bloc/authentication_bloc.dart';
import 'views/sign_in_view.dart';
import 'views/sign_up_view.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationBloc bloc = BlocProvider.of<AuthenticationBloc>(context);
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        bloc: bloc,
        builder: (BuildContext context, AuthenticationState state) {
          switch (state) {
            case AuthenticationInitial _:
              return const InitalLoadingView();
            case AuthenticationSignUpState signUpState:
              return SignUpView(
                  initEmail: signUpState.email,
                  initPassword: signUpState.password,
                  emailSignUpCallback: bloc.emailSignUp,
                  signInRequestCallback: (email, password) => bloc.add(
                        AuthenticationSignInRequestEvent(
                            email: email, password: password),
                      ));
            case AuthenticationForgotPasswordState forgotPasswordState:
              return ForgotPasswordView(
                initEmail: forgotPasswordState.email,
                emailForgotPasswordCallback: bloc.emailForgotPassword,
                signInRequestCallback: (initEmail) => bloc
                    .add(AuthenticationSignInRequestEvent(email: initEmail)),
              );
            case AuthenticationSignInState signInState:
              return SignInView(
                initEmail: signInState.email,
                initPassword: signInState.password,
                loginSubmitCallback: bloc.loginSubmit,
                signUpRequestCallback: (initEmail, initPassword) => bloc.add(
                    AuthenticationSignUpRequestEvent(
                        email: initEmail, password: initPassword)),
                forgotPasswordRequestCallback: (email) =>
                    bloc.add(AuthenticationForgotPasswordRequestEvent(email)),
              );
            default:
              return SignInView(
                loginSubmitCallback: bloc.loginSubmit,
                signUpRequestCallback: (initEmail, initPassword) => bloc.add(
                    AuthenticationSignUpRequestEvent(
                        email: initEmail, password: initPassword)),
                forgotPasswordRequestCallback: (email) =>
                    bloc.add(AuthenticationForgotPasswordRequestEvent(email)),
              );
          }
        });
  }
}
