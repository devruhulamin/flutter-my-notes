import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitilize extends AuthEvent {
  const AuthEventInitilize();
}

class AuthEventSendEmailVerification extends AuthEvent {}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin({required this.email, required this.password});
}

class AuthEventRegisterUser extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegisterUser({required this.email, required this.password});
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class AuthEventResetPassword extends AuthEvent {
  final String? email;
  const AuthEventResetPassword({this.email});
}
