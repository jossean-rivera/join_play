import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authentication/bloc/authentication_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: FilledButton(
          child: const Text("Log Out"),
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(
              AuthenticationLogoutEvent(),
            );
          },
        ),
      ),
    );
  }
}
