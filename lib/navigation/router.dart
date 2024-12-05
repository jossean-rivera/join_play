import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:join_play/pages/sport_details_page.dart';
import '../pages/history_page.dart';
import '../pages/my_games_page.dart';
import '../blocs/authentication/bloc/authentication_bloc.dart';
import '../pages/authentication/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/registration_confirmation_page.dart';
import '../pages/sports_page.dart';
import '../pages/game_form.dart';
import '../repositories/addresses_repository.dart';
import '../utilities/firebase_service.dart';
import '../utilities/stream_to_listenable.dart';
import '../pages/splashscreen.dart';
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
    initialLocation: RoutePaths.splashScreen,
    refreshListenable: StreamToListenable([authenticationBloc.stream]),
    redirect: (context, state) {
      if (state.uri.path == '/splashScreen') {
        return null;
      }

      if (authenticationBloc.state is AuthenticationLoggedOut &&
          state.fullPath?.startsWith(RoutePaths.login) != true) {
        return RoutePaths.login;
      } else if (authenticationBloc.state is AuthenticationLoggedIn &&
          state.fullPath?.startsWith(RoutePaths.login) == true) {
        return RoutePaths.sports;
      }

      return null;
    },
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(
        path: RoutePaths.splashScreen,
        name: RouteNames.splashScreen,
        builder: (context, state) => SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) =>
            CupertinoScaffoldWithNavBar(title: RoutePaths.getTitleFromRoute(state), child: child),
        routes: [
          GoRoute(
            path: RoutePaths.sports,
            name: RouteNames.sports,
            builder: (context, state) =>
                SportsPage(firebaseService: context.read<FirebaseService>()),
            routes: [
              GoRoute(
                path: ':sportId',
                name: RouteNames.sportDetails,
                builder: (context, state) {
                  final sportId = state.pathParameters['sportId']!;
                  return SportDetailsPage(
                    sportId: sportId,
                    firebaseService: context.read<FirebaseService>(),
                    authenticationBloc:
                        BlocProvider.of<AuthenticationBloc>(context),
                    addressesRepository: context.read<AddressesRepository>(),
                  );
                },
                routes: [
                  GoRoute(
                    path: RoutePaths.registrationConfirmation,
                    name: RouteNames.registrationConfirmation,
                    builder: (context, state) {
                      return const RegistrationConfirmationPage();
                    },
                  ),
                  GoRoute(
                    path: RoutePaths.gameForm,
                    name: RouteNames.gameForm,
                    builder: (context, state) {
                      final sportId = state.pathParameters['sportId']!;
                      return GameFormPage(
                        sportId: sportId,
                        firebaseService: context.read<FirebaseService>(),
                        authenticationBloc:
                            BlocProvider.of<AuthenticationBloc>(context),
                        addressesRepository:
                            context.read<AddressesRepository>(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.myGames,
            name: RouteNames.myGames,
            builder: (context, state) =>  const MyGamesPage(

            ),
          ),
          GoRoute(
            path: RoutePaths.history,
            name: RouteNames.history,
            builder: (context, state) =>  const HistoryPage(
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) =>  const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}
