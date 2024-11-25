part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthenticationLogoutEvent extends AuthenticationEvent {}

/// Event for when user requests the sign up page
class AuthenticationSignUpRequestEvent extends AuthenticationEvent {}

/// Event for when the user requests the sign in page
class AuthenticationSignInRequestEvent extends AuthenticationEvent {
  String? email;
  String? password;

  AuthenticationSignInRequestEvent(this.email, this.password);
}

class AuthenticationUserChangedEvent extends AuthenticationEvent {
  final User? user;
  AuthenticationUserChangedEvent(this.user);
}
