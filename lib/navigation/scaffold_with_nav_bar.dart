import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../custom_theme_data.dart';
import 'route_names.dart';
import 'route_paths.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String title;
  const ScaffoldWithNavBar(
      {super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: "Sports"),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined), label: "My Games"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Profile"),
        ],
        currentIndex: _getCurrentIndex(context),
        onTap: (index) {
          _onTapItem(index, context);
        },
        selectedItemColor: CustomColors.babyBlue, // Set your desired color
        unselectedItemColor: Colors.grey, // Set your desired unselected color
      ),
    );
  }

  _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith(RoutePaths.sports)) {
      return 0;
    }

    if (location.startsWith(RoutePaths.myGames)) {
      return 1;
    }

    if (location.startsWith(RoutePaths.history)) {
      return 2;
    }

    if (location.startsWith(RoutePaths.profile)) {
      return 3;
    }

    return 0;
  }

  void _onTapItem(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).goNamed(RouteNames.sports);
        break;
      case 1:
        GoRouter.of(context).goNamed(RouteNames.myGames);
        break;
      case 2:
        GoRouter.of(context).goNamed(RouteNames.history);
        break;
      case 3:
        GoRouter.of(context).goNamed(RouteNames.profile);
        break;
    }
  }
}
