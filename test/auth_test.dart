import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/services/auth/auth_exception.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';

class NotInitilizeException implements Exception {}

void main() {
  group("Mock Authprovider Test", () {
    final provider = MockAuthProvider();
    test("should be false for first time initilization", () {
      expect(provider._initilize, false);
    });
    test("Can not be loggedout if not initilized", () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitilizeException>()));
    });
    test("should be initilized", () async {
      await provider.initialize();
      expect(provider.isInitilize, true);
    });
    test("user should be null after initilization", () {
      expect(provider._user, null);
    });
    test("should be initilize less than 2 second", () async {
      await provider.initialize();
      expect(provider._initilize, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test("create user should delegate to login function", () async {
      final badEmail = await provider.createUser(
          email: "foo@gmail.com", password: "random password");
      expect(badEmail, const TypeMatcher<UserNotFoundException>());
      final badPassword = await provider.createUser(
          email: "any@gmail.com", password: "foobarbaz");
      expect(badPassword, const TypeMatcher<WrongPasswordException>());
      final goodUser = await provider.createUser(
          email: "example@gmail.com", password: "xxzz");
      expect(provider.currentUser, goodUser);
      expect(goodUser.isEmailverified, false);
    });
    test("logged user should be verifi their email", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailverified, true);
    });
    test("user should able to logout and login", () async {
      await provider.logout();
      final user = provider.login(email: "dkfjdf", password: "dfdkfjdkfj");
      expect(user, isNotNull);
    });
  });
}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  bool _initilize = false;
  bool get isInitilize => _initilize;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitilize) throw NotInitilizeException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _initilize = true;
  }

  @override
  Future<AuthUser> login(
      {required String email, required String password}) async {
    if (!isInitilize) throw NotInitilizeException();
    if (email == "foo@gmail.com") throw UserNotFoundException();
    if (password == "foobarbaz") throw WrongPasswordException();
    const user = AuthUser(email: 'foo@gmail.com', isEmailverified: false);
    return user;
  }

  @override
  Future<void> logout() async {
    if (!isInitilize) throw NotInitilizeException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitilize) throw NotInitilizeException();
    if (_user == null) throw UserNotFoundException();
    _user = const AuthUser(email: 'foo@gmail.com', isEmailverified: true);
  }
}
