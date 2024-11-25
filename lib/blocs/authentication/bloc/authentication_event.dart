part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthenticationLogoutEvent extends AuthenticationEvent {}

/// Event for when user requests the sign up page
final class AuthenticationSignUpRequestEvent extends AuthenticationEvent {}

/// Event for when the user requests the sign in page
final class AuthenticationSignInRequestEvent extends AuthenticationEvent {
  final String? email;
  final String? password;

  AuthenticationSignInRequestEvent({this.email, this.password});
}

/// Event raised when the user in firebase changes
final class AuthenticationUserChangedEvent extends AuthenticationEvent {
  final User? user;
  AuthenticationUserChangedEvent(this.user);
}

/// Event for when the user requests the forgot password page
final class AuthenticationForgotPasswordRequestEvent
    extends AuthenticationEvent {
  final String? email;

  AuthenticationForgotPasswordRequestEvent(this.email);
}
