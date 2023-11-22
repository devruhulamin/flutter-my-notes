import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show immutable;
import 'package:mynotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool loading;
  final String? loadingText;
  const AuthState(
      {required this.loading, this.loadingText = 'Please Wait White Loaing'});
}

class AuthStateInitilizing extends AuthState {
  const AuthStateInitilizing({required super.loading});
}

class AuthStateRegistering extends AuthState {
  final Exception exception;

  const AuthStateRegistering({required this.exception, required super.loading});
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser authUser;

  const AuthStateLoggedIn({required this.authUser, required super.loading});
}

class AuthStateLoginFailure extends AuthState {
  final Exception exception;

  const AuthStateLoginFailure(
      {required this.exception, required super.loading});
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.loading});
}

class AuthStateLoggenOut extends AuthState with EquatableMixin {
  final Exception? exception;

  const AuthStateLoggenOut({
    required this.exception,
    required super.loading,
    super.loadingText,
  });

  @override
  List<Object?> get props => [exception, loading];
}
