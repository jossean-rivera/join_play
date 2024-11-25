import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _firebaseAuth;

  AuthenticationBloc(this._firebaseAuth) : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<AuthenticationLoginSuccessEvent>((event, emit) {
      _login(emit);
    });
    on<AuthenticationLogoutEvent>((event, emit) async {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        // Ignore exception
      }

      _logout(emit);
    });

    // Handle authentication changes
    on<AuthenticationUserChangedEvent>((event, emit) {
      if (event.user == null) {
        // User is signed out
        _logout(emit);
      } else {
        // User is signed in
        _login(emit);
      }
    });

    // Raise event when the auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      add(AuthenticationUserChangedEvent(user));
    });
  }

  void _login(Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoggedIn());
  }

  void _logout(Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoggedOut());
  }

  /// Method to loging the user with email/password authentication on Firebase.
  Future<String?> loginSubmit(String email, String password) async {
    try {
      // Send loging request to firebase email auth
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login was successful
      emit(AuthenticationLoggedIn());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect username or password.';
      } else {
        return e.message ?? e.code;
      }
    } catch (e) {
      return 'There was an internal error while trying to login, try again later.';
    }
  }
}
