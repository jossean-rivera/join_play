import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../custom_theme_data.dart';
import 'route_names.dart';
import 'route_paths.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String title;
  const ScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final iconSize = mediaQuery.size.width > 600 ? 32.0 : 24.0; // Adjust icon size based on screen width
    final fontSize = mediaQuery.size.width > 600 ? 14.0 : 12.0; // Adjust font size

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: fontSize * 2.5), // Responsive title size
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: isLandscape
              ? const EdgeInsets.symmetric(horizontal: 32.0)
              : const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports, size: iconSize),
            label: "Sports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined, size: iconSize),
            label: "My Games",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: iconSize),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: iconSize),
            label: "Profile",
          ),
        ],
        currentIndex: _getCurrentIndex(context),
        onTap: (index) {
          _onTapItem(index, context);
        },
        selectedItemColor: CustomColors.babyBlue, // Set your desired color
        unselectedItemColor: Colors.grey, // Set your desired unselected color
        selectedFontSize: fontSize,
        unselectedFontSize: fontSize,
        type: BottomNavigationBarType.fixed,
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
