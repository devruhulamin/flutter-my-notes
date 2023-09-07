import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        throw EmailAlreadyInUseException();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailException();
      } else if (e.code == "weak-password") {
        throw WeakPasswordException();
      } else {
        throw GenericsAuthException();
      }
    } catch (_) {
      throw GenericsAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> login(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "wrong-password") {
        throw WrongPasswordException();
      } else if (e.code == "invalid-email") {
        throw InvalidEmailException();
      } else if (e.code == "user-not-found") {
        throw UserNotFoundException();
      } else {
        throw GenericsAuthException();
      }
    } catch (_) {
      throw GenericsAuthException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw GenericsAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      throw GenericsAuthException();
    }
  }
}
