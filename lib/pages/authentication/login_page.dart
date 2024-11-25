import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            case AuthenticationSignUpState _:
              return SignUpView(
                emailSignUpCallback: bloc.emailSignUp,
                signInRequestCallback: (email, password) =>
                    bloc.add(AuthenticationSignInRequestEvent(email, password)),
              );
            case AuthenticationSignInState signInState:
              return SignInView(
                initEmail: signInState.email,
                initPassword: signInState.password,
                loginSubmitCallback: bloc.loginSubmit,
                signUpRequestCallback: () =>
                    bloc.add(AuthenticationSignUpRequestEvent()),
              );
            case AuthenticationInitial _:
            default:
              return SignInView(
                loginSubmitCallback: bloc.loginSubmit,
                signUpRequestCallback: () =>
                    bloc.add(AuthenticationSignUpRequestEvent()),
              );
          }
        });
  }
}
