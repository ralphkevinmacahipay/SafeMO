import 'package:accounts/services/auth/auth_exception.dart';
import 'package:accounts/services/auth/auth_provider.dart';
import 'package:accounts/services/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    // expecting false value
    test("should not be initialized to begin with", () {
      expect(provider.isEnitialize, false);
    });

    // expecting UserNotFoundAuthException
    test("Cannot logout if if not initialized", () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotEnitializedException>()));
    });
    // expecting the tre value after initialize function
    test('Should initialized after calling initialize function', () async {
      await provider.initialize();
      expect(provider.isEnitialize, true);
    });

    // user should remain null after initialize function
    test('User should be null after initialize function', () {
      expect(provider.currentUser, null);
    });

    // expecting error if cannot initialize within the allocated time (2 seconds)
    test(
      'Should initialize within the allocated time (2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isEnitialize, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    // expecting  User not found
    test("Should Throw UserNotFoundAuthException", () async {
      final bademail = provider.createUser(
          email: "testing@gmail.com", password: "password123");

      expect(bademail, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badpassword =
          provider.createUser(email: "admin@gmail.com", password: "password");

      expect(badpassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(
          email: "test@gmail.com", password: "testpassword");

      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test("expecting to get verified", () async {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to logout and login again', () async {
      await provider.logout();
      await provider.login(email: "email", password: 'password2');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotEnitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isEnitialize = false;
  // get the value;
  bool get isEnitialize => _isEnitialize;
  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isEnitialize) throw NotEnitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isEnitialize = true;
  }

  @override
  Future<AuthUser> login(
      {required String email, required String password}) async {
    // check for initialize
    if (!isEnitialize) throw NotEnitializedException();
    // we expect email and password will throw exception
    if (email == "testing@gmail.com") throw UserNotFoundAuthException();
    if (password == "password") throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'testing@gmail.com');
    _user = user;
    return Future.value(_user);
  }

  @override
  Future<void> logout() async {
    // check for initialize
    if (!isEnitialize) throw NotEnitializedException();
    //check if user already logged in
    if (_user == null) throw UserNotFoundAuthException();
    // fake waiting
    await Future.delayed(const Duration(seconds: 1));
    // set _user to null
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _user;
    if (!isEnitialize) throw NotEnitializedException();
    if (user == null) UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'testing@gmail.com');
    _user = newUser;
  }
}
