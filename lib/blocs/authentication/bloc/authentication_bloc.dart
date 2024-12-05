import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:join_play/models/sport_user.dart';
import 'package:join_play/repositories/user_repository.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _firebaseAuth;
  final UserRepository _userRepository;

  /// User data for the sports application
  SportUser? sportUser;

  AuthenticationBloc(this._firebaseAuth, this._userRepository)
      : super(AuthenticationInitial()) {

    // Handle the successful login event
    on<AuthenticationLoggedInEvent>((event, emit) {
      sportUser = event.loggedInUser;
      emit(AuthenticationLoggedIn(event.loggedInUser));
    });

    // Handle the logout event
    on<AuthenticationLogoutEvent>((event, emit) async {
      try {
        await _firebaseAuth.signOut();
      } catch (_) {
        // Ignore exceptions
      }
      sportUser = null;
      emit(AuthenticationLoggedOut());
    });

    // Handle event to show sign-up view
    on<AuthenticationSignUpRequestEvent>((event, emit) {
      emit(AuthenticationSignUpState(
          email: event.email, password: event.password));
    });

    // Handle event to show sign-in view
    on<AuthenticationSignInRequestEvent>((event, emit) {
      emit(AuthenticationSignInState(
          email: event.email, password: event.password));
    });

    // Handle event to show forgot password view
    on<AuthenticationForgotPasswordRequestEvent>((event, emit) {
      emit(AuthenticationForgotPasswordState(event.email));
    });

    // Handle authentication changes
    on<AuthenticationUserChangedEvent>((event, emit) async {
      if (event.user?.uid != null) {
        SportUser? sportLoggedInUser =
            await _userRepository.getUser(event.user?.uid ?? '');

        if (sportLoggedInUser != null) {
          add(AuthenticationLoggedInEvent(sportLoggedInUser));
          return;
        }
      }

      emit(AuthenticationLoggedOut());
    });

    // Emit authentication state changes based on Firebase
    _firebaseAuth.authStateChanges().listen((User? user) {
      add(AuthenticationUserChangedEvent(user));
    });
  }

  /// Log in the user with email/password using Firebase authentication
  Future<String?> loginSubmit(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user?.uid != null) {
        SportUser? user =
            await _userRepository.getUser(credential.user?.uid ?? '');
        if (user != null) {
          add(AuthenticationLoggedInEvent(user));
          return null;
        } else {
          await _firebaseAuth.currentUser?.delete();
          return 'No user data found for this email. Please register again.';
        }
      }

      return 'An internal error occurred during login. Please try again later.';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for this email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect username or password.';
      } else {
        return e.message ?? e.code;
      }
    } catch (_) {
      return 'An internal error occurred during login. Please try again later.';
    }
  }

  /// Register a new user in Firebase for email authentication
  Future<String?> emailSignUp(String name, String email, String password) async {
    try {
      UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user?.uid != null) {
        SportUser user = SportUser(
            uuid: credential.user?.uid ?? '', name: name, email: email);
        _userRepository.addUser(user);
        add(AuthenticationLoggedInEvent(user));
      } else {
        await _firebaseAuth.currentUser?.delete();
        return 'An internal error occurred during registration. Please try again later.';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for this email.';
      } else {
        return e.message ?? e.code;
      }
    } catch (_) {
      return 'An internal error occurred during registration. Please try again later.';
    }
  }

  /// Initiates a password reset flow in Firebase
  Future<String?> emailForgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      emit(AuthenticationSignInState(email: email));
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (_) {
      return 'An error occurred while resetting the password.';
    }
  }
}
