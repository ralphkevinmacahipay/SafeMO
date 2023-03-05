import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

// tinatawag ang firebase to verify the email
@immutable
class AuthUser {
  final bool isEmailVerified;
  final String? email;
  const AuthUser({required this.email, required this.isEmailVerified});
  // to get the value of emailVerified (return the instance of itself)
  factory AuthUser.fromfirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
