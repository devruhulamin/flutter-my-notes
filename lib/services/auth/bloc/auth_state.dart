import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateInitilizing extends AuthState {
  const AuthStateInitilizing();
}

class AuthStateRegistering extends AuthState {
  final Exception exception;

  const AuthStateRegistering({required this.exception});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  const AuthStateLoggedIn({required this.authUser});
}

class AuthStateLoginFailure extends AuthState {
  final Exception exception;

  const AuthStateLoginFailure({required this.exception});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggenOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;

  const AuthStateLoggenOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}
