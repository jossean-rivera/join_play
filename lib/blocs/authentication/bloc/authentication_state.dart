part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthenticationLoggedIn extends AuthenticationState {
  final SportUser loggedInUser;
  AuthenticationLoggedIn(this.loggedInUser);
}

final class AuthenticationLoggedOut extends AuthenticationState {}

final class AuthenticationSignUpState extends AuthenticationState {
  final String? email;
  final String? password;
  AuthenticationSignUpState({this.email, this.password});
}

final class AuthenticationSignInState extends AuthenticationState {
  final String? email;
  final String? password;
  AuthenticationSignInState({this.email, this.password});
}

final class AuthenticationForgotPasswordState extends AuthenticationState {
  final String? email;
  AuthenticationForgotPasswordState(this.email);
}
