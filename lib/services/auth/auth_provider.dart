import 'package:accounts/services/auth/auth_user.dart';

abstract class AuthProvider {
  // to initialize the application
  Future<void> initialize();
  // get the current user
  AuthUser? get currentUser;

  // all provider must have email and password (e.g. Facebook, email, twittter)
  Future<AuthUser> login({
    required String email,
    required String password,
  });

  // to create user
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  // to logout
  Future<void> logout();

  // to verify email
  Future<void> sendEmailVerification();
}
