import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

@immutable
class AuthUser {
  final String id;
  final String email;
  final bool isEmailverified;

  const AuthUser(
      {required this.email, required this.isEmailverified, required this.id});

  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailverified: user.emailVerified,
      );
}
