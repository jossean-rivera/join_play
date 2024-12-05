import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../custom_theme_data.dart';
import 'route_names.dart';
import 'route_paths.dart';

class CupertinoScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final String title;

  const CupertinoScaffoldWithNavBar({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(title),
        backgroundColor: CustomColors.babyBlue, // Optional customization
      ),
      child: Column(
        children: [
          Expanded(child: child),
          CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.sportscourt),
                label: "Sports",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person_crop_circle_badge_checkmark),
                label: "My Games",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.clock),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: "Profile",
              ),
            ],
            currentIndex: _getCurrentIndex(context),
            onTap: (index) {
              _onTapItem(index, context);
            },
            activeColor: CustomColors.babyBlue, // Selected item color
            inactiveColor: CupertinoColors.systemGrey, // Unselected item color
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
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
