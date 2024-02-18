import 'package:local_auth/local_auth.dart';
import 'package:secure_note/api/api.dart';
import 'package:secure_note/api/notes_api/requests/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/errors.dart';
import '../../util/string_util.dart';
import 'auth_repository.dart';

class RestAuthRepository extends AuthRepository {
  final _authMethodKey = "auth_method";
  final _authStateKey = "auth_state";
  final _passwordKey = "password";
  final _tokenKey = "token";

  @override
  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      NotesApi.inst.setToken(token);
      // await NotesApi.inst.authRefreshToken().then((resp) async {
      //   NotesApi.inst.setToken(resp.token);
      //   await prefs.setString(_tokenKey, token);
      // });
    }
  }

  @override
  getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_authStateKey) ?? AuthState.unauthorized.index;
    return AuthState.values[index];
  }

  @override
  getAuthMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_authMethodKey) ?? AuthMethod.none.index;
    return AuthMethod.values[index];
  }

  @override
  setFingerprintAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, StringUtil.generatePassword());
    await prefs.setInt(_authMethodKey, AuthMethod.fingerprint.index);
    await prefs.setInt(_authStateKey, AuthState.authorized.index);
  }

  @override
  setPasswordAuth(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
    await prefs.setInt(_authMethodKey, AuthMethod.password.index);
    await prefs.setInt(_authStateKey, AuthState.authorized.index);
  }

  @override
  Future<void> sendSms(String phone) async {
    return NotesApi.inst.authSendSms(phone: phone).then((value) => null);
  }

  @override
  Future<void> checkSms({
    required String phone,
    required String pin,
  }) async {
    return NotesApi.inst.authLogin(phone: phone, pin: pin).then((value) async {
      NotesApi.inst.setToken(value.token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_authStateKey, AuthState.phoneValidated.index);
      await prefs.setString(_tokenKey, value.token);
    }, onError: (e) {
      throw AuthError("Код указан неверно");
    });
  }

  @override
  Future<void> signInWithFingerprint() async {
    await setFingerprintAuth();
    if (await getAuthMethod() != AuthMethod.fingerprint) throw AuthError("Установлен другой метод авторизации");

    //final auth = LocalAuthentication();
    try {
      // assert(
      //   await auth.authenticate(
      //     localizedReason: "Приложите палец к сканеру",
      //     options: const AuthenticationOptions(useErrorDialogs: true),
      //   ),
      // );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_authStateKey, AuthState.authorized.index);
    } catch (e) {
      throw "Авторизация не удалась.";
    }
  }

  @override
  Future<void> signInWithPassword(String password) async {
    if (await getAuthMethod() != AuthMethod.password) throw AuthError("Установлен другой метод авторизации");
    final prefs = await SharedPreferences.getInstance();
    if (password != prefs.getString(_passwordKey)) {
      throw AuthError("Неверный пароль");
    }
    prefs.setInt(_authStateKey, AuthState.authorized.index);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    NotesApi.inst.setToken(null);
    await prefs.remove(_authStateKey);
    await prefs.remove(_authMethodKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_tokenKey);
  }
}
