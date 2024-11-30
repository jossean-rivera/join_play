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

  static String getTitleFromRoute(GoRouterState state) {
    final routeName = state.fullPath;
    switch (routeName) {
      case sports:
        return 'Sports';
      case sportDetails:
        return 'Sport Details';
      case myGames:
        return 'My Games';
      case history:
        return 'History';
      case profile:
        return 'Profile';
      case registrationConfirmation:
        return 'Registration Confirmation';
      default:
        return 'Join Play'; // Default title
    }
  }
}
