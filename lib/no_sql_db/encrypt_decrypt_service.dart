import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptAndDecryptService {
  static final key = encrypt.Key.fromLength(32);
  static final iv = encrypt.IV.fromLength(16);

  static final keyFernet =
      encrypt.Key.fromUtf8("my 32 length key................");
  static final fernet = encrypt.Fernet(keyFernet);
  static final encryptionForFernet = encrypt.Encrypter(fernet);

  static encryptionFernet(text) {
    final encrypted = encryptionForFernet.encrypt(text);
    return encrypted;
  }

  static decryptFernet(text) {
    return encryptionForFernet.decrypt64(text);
  }
}
