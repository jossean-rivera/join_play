import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/authentication/bloc/authentication_bloc.dart';
import '../navigation/route_names.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the AuthenticationBloc instance
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sports"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the children vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center the children horizontally
          children: [
            Text(
              'Hello, ${authenticationBloc.sportUser?.name}',
              style: const TextStyle(fontSize: 24), // Optional: Adjust text style
            ),
            const SizedBox(
                height: 20), // Add some space between text and button
            FilledButton(
              child: const Text("Go to Sport Details"),
              onPressed: () {
                context.goNamed(RouteNames.sportDetails);
              },
            ),
          ],
        ),
      ),
    );
  }
}
