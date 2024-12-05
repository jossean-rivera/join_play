import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/authentication/bloc/authentication_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Profile"),
      ),
      child: Center(
        child: CupertinoButton.filled(
          onPressed: () {
            BlocProvider.of<AuthenticationBloc>(context).add(
              AuthenticationLogoutEvent(),
            );
          },
          child: const Text("Log Out"),
        ),
      ),
    );
  }
}
