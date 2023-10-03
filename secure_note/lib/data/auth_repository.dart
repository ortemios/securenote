import 'dart:ffi';

import 'package:secure_note/model/errors.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthRepository {

  Future<AuthMethod?> getAuthMethod();
  Future<void> setFingerprintAuth();
  Future<void> setPasswordAuth(String password);


  Future<void> sendSms(String phone);

  Future<void> checkPassword(String password);
  Future<void> checkFingerprint();

  Future<void> login(String phone, String pin);
  Future<void> loginWithToken();

  static final inst = LocalAuthRepository();
}

enum AuthMethod { fingerprint, password }

class LocalAuthRepository extends AuthRepository {

  final _authMethodKey = "auth_method";
  final _passwordKey = "password";
  final _tokenKey = "token";

  var _shouldClearCache = false;

  @override
  getAuthMethod() async {
    final prefs = await SharedPreferences.getInstance();
    if (_shouldClearCache) {
      _shouldClearCache = false;
      await prefs.clear();
    }
    final methodIndex = prefs.getInt(_authMethodKey);
    return methodIndex != null ? AuthMethod.values[methodIndex] : null;
  }

  @override
  setFingerprintAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_authMethodKey, AuthMethod.fingerprint.index);
  }

  @override
  setPasswordAuth(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, password);
    await prefs.setInt(_authMethodKey, AuthMethod.password.index);
  }

  String _phone = "", _pin = "";
  final String _token = "123";

  @override
  sendSms(String phone) async {
    await Future.delayed(const Duration(seconds: 2));
    _phone = phone;
    _pin = "1234";
  }

  @override
  login(String phone, String pin) async {
    await Future.delayed(const Duration(seconds: 2));
    if (phone != _phone) throw AuthError("Номер не существует");
    if (pin != _pin) throw AuthError("Код указан неверно");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, _token);
  }

  @override
  checkFingerprint() async {
    if (await getAuthMethod() != AuthMethod.fingerprint) throw AuthError("Установлен другой метод авторизации");
  }

  @override
  checkPassword(String password) async {
    if (await getAuthMethod() != AuthMethod.password) throw AuthError("Установлен другой метод авторизации");
    final prefs = await SharedPreferences.getInstance();
    if (password != prefs.getString(_passwordKey)) {
      throw AuthError("Неверный пароль");
    }
  }

  @override
  loginWithToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) throw AuthError("Токен отсутствует");
    if (token != _token) throw AuthError("Токен невалидный");
    //throw AuthError("Токен невалидный");
  }
}