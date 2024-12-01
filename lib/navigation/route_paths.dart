import 'package:go_router/go_router.dart';

class RoutePaths {
  static const String login = "/login";
  static const String sports = "/sports";
  static const String myGames = "/myGames";
  static const String history = "/history";
  static const String profile = "/profile";

  // Details paths for specific sections
  static const String sportDetails = "/sports/:sportId";
  static const String myGamesDetails = "/myGames/details";
  static const String historyDetails = "/history/details";
  static const String registrationConfirmation = "/confirmed";
  static const String gameForm = "/gameForm";

  static String getTitleFromRoute(GoRouterState state) {
    final routePath = state.fullPath;

    // Do not display a title for the confirmed page.
    if (routePath?.endsWith(registrationConfirmation) == true) {
      return '';
    }

    switch (routePath) {
      case sports:
        return 'Sports';
      case sportDetails:
        return '';
      case myGames:
        return 'My Games';
      case history:
        return 'History';
      case profile:
        return 'Profile';
      default:
        return 'Join Play'; // Default title
    }
  }
}
