import 'package:secure_note/data/auth/rest_auth_repository.dart';

import 'local_auth_repository.dart';

enum AuthState { unauthorized, phoneValidated, authorized }

enum AuthMethod { none, fingerprint, password }

abstract class AuthRepository {

  Future<AuthState> getAuthState();

  Future<AuthMethod> getAuthMethod();

  Future<int> sendSms(String phone);

  Future<void> checkSms({
    required String phone,
    required String pin,
  });

  Future<void> login();

  Future<void> setFingerprintAuth();

  Future<void> setPasswordAuth(String password);

  Future<void> signInWithPassword(String password);

  Future<void> signInWithFingerprint();

  Future<void> logout();

  static final inst = RestAuthRepository();
}
