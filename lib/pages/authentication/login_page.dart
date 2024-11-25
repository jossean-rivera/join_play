import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/authentication/bloc/authentication_bloc.dart';
import 'views/sign_in_view.dart';

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
            default:
              return SignInView(
                loginSubmitCallback: (email, password) =>
                    bloc.loginSubmit(email, password),
              );
          }
        });
  }
}
