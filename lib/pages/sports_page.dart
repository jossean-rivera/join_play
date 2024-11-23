import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/route_names.dart';

class SportsPage extends StatelessWidget {
  const SportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sports"),
      ),
      body: Center(
        child: FilledButton(
          child: const Text("Go to Sport Details"),
          onPressed: () {
            context.goNamed(RouteNames.sportDetails);
          },
        ),
      ),
    );
  }
}