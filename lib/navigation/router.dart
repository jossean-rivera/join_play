import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/pages/sport_details_page.dart';
import '../pages/history_page.dart';
import '../pages/my_games_page.dart';
import '../blocs/authentication/bloc/authentication_bloc.dart';
import '../pages/authentication/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/sports_page.dart';
import '../utilities/stream_to_listenable.dart';
import 'route_names.dart';
import 'route_paths.dart';
import 'scaffold_with_nav_bar.dart';

// Keys for showing/hiding the bottom bar
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: "Root");
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: "Shell");

GoRouter createRouter(AuthenticationBloc authenticationBloc) {
  return GoRouter(
    initialLocation: RoutePaths.login, // Set the login page as the stating page
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) {
      //  Check if the current bloc state is for logging out
      if (authenticationBloc.state is AuthenticationLoggedOut) {
        //  If the user is not on the login page, then redirect the user to /login
        if (state.fullPath?.startsWith(RoutePaths.login) != true) {
          return RoutePaths.login;
        }
      } else if (authenticationBloc.state is AuthenticationLoggedIn) {

        //  If the event for logging in raise, and the user is in the login page, 
        //  then redirect to the home page
        if (state.fullPath?.startsWith(RoutePaths.login) == true){
          return RoutePaths.sports;
        }
      }

      return null;
    },
    navigatorKey: rootNavigatorKey, // root navigator key
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            ScaffoldWithNavBar(title: "", child: child),
        routes: [
          GoRoute(
            path: RoutePaths.sports,
            name: RouteNames.sports,
            builder: (context, state) => const SportsPage(),
            routes: [
              GoRoute(
                path: RoutePaths.sportDetails,
                name: RouteNames.sportDetails,
                parentNavigatorKey: rootNavigatorKey, // Push to root navigator
                builder: (context, state) => const SportDetailsPage(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.myGames,
            name: RouteNames.myGames,
            builder: (context, state) => const MyGamesPage(),
          ),
          GoRoute(
            path: RoutePaths.history,
            name: RouteNames.history,
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
