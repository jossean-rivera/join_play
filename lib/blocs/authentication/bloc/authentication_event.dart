part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

class AuthenticationLogoutEvent extends AuthenticationEvent {}

class AuthenticationLoginSuccessEvent extends AuthenticationEvent {}

class AuthenticationUserChangedEvent extends AuthenticationEvent {
  final User? user;
  AuthenticationUserChangedEvent(this.user);
}
