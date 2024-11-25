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
    on<AuthenticationLogoutEvent>((event, emit) async {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        // Ignore exception
      }

      emit(AuthenticationLoggedOut());
    });

    // Handle event to show sign up view
    on<AuthenticationSignUpRequestEvent>((event, emit) {
      emit(AuthenticationSignUpState(
          email: event.email, password: event.password));
    });

    // Handle event to show sign in view
    on<AuthenticationSignInRequestEvent>((event, emit) {
      emit(AuthenticationSignInState(
          email: event.email, password: event.password));
    });

    // Handle event to show forgot password view
    on<AuthenticationForgotPasswordRequestEvent>((event, emit) {
      emit(AuthenticationForgotPasswordState(event.email));
    });

    // Handle authentication changes
    on<AuthenticationUserChangedEvent>((event, emit) {
      if (event.user == null) {
        // User is signed out
        emit(AuthenticationLoggedIn());
      } else {
        // User is signed in
        emit(AuthenticationLoggedOut());
      }
    });

    // Emit our own auth state when the firebase auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      add(AuthenticationUserChangedEvent(user));
    });
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

  /// Method used to register a new user on firebase for email authentication
  Future<String?> emailSignUp(
      String name, String email, String password) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(AuthenticationLoggedIn());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message ?? e.code;
      }
    } catch (e) {
      return 'There was an internal error while trying to login, try again later.';
    }
  }

  /// Calls forgot password flow in firebase auth
  Future<String?> emailForgotPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emit(AuthenticationSignInState(email: email));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }
}
