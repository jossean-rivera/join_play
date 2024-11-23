import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/route_names.dart';

class SportDetailsPage extends StatelessWidget {
  const SportDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Games"),
      ),
      body: Center(
        child: FilledButton(
          child: const Text("Go to back"),
          onPressed: () {
            context.goNamed(RouteNames.sports);
          },
        ),
      ),
    );
  }
}