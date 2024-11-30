import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:join_play/pages/location_page.dart';

import 'blocs/authentication/bloc/authentication_bloc.dart';
import 'custom_theme_data.dart';
import 'navigation/router.dart';
import 'firebase_options.dart';
import 'repositories/firebase_user_repository.dart';
import 'repositories/user_repository.dart';
import 'utilities/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /**
   * Testing page for getting the device's location and display coordinates
   * and calculate the distance between the current location and a given address.
   */
  //runApp(const MaterialApp(home: LocationPage()));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) =>
              FirestoreUserRepository(FirebaseFirestore.instance),
        ),
        RepositoryProvider(
            create: (context) => FirebaseService(FirebaseFirestore.instance))
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
                FirebaseAuth.instance, context.read<UserRepository>()),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              theme: customThemeData,
              title: 'Flutter Demo',
              routerConfig: createRouter(context.read<AuthenticationBloc>()),
            );
          },
        ),
      ),
    );
  }
}
