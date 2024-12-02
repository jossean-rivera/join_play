import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../navigation/route_names.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        child: const Text("Go to Profile"),
        onPressed: () {
          context.goNamed(RouteNames.profile);
        },
      ),
    );
  }
}
