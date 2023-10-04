import 'package:secure_note/model/errors.dart';
import 'package:secure_note/util/string_util.dart';
import 'package:shared_preferences/shared_preferences.dart';


enum AuthState { unauthorized, phoneValidated, authorized }
enum AuthMethod { none, fingerprint, password }


abstract class AuthRepository {
  Future<AuthState> getAuthState();
  Future<AuthMethod> getAuthMethod();

  Future<void> sendSms(String phone);
  Future<void> checkSms(String pin);

  Future<void> setFingerprintAuth();
  Future<void> setPasswordAuth(String password);

  Future<void> signInWithPassword(String password);
  Future<void> signInWithFingerprint();

  Future<void> logout();

  static final inst = LocalAuthRepository();
}

class LocalAuthRepository extends AuthRepository {

  final _authMethodKey = "auth_method";
  final _authStateKey = "auth_state";
  final _passwordKey = "password";
  final _tokenKey = "token";

  var _shouldClearCache = false;

  @override
  getAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_shouldClearCache) {
      _shouldClearCache = false;
      await prefs.clear();
    }
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

  String _pin = "";
  final String _token = "123";

  @override
  sendSms(String phone) async {
    _pin = "1234";
  }

  @override
  checkSms(String pin) async {
    if (pin != _pin) throw AuthError("Код указан неверно");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_authStateKey, AuthState.phoneValidated.index);
    await prefs.setString(_tokenKey, _token);
  }

  @override
  signInWithFingerprint() async {
    if (await getAuthMethod() != AuthMethod.fingerprint) throw AuthError("Установлен другой метод авторизации");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_authStateKey, AuthState.authorized.index);
  }

  @override
  signInWithPassword(String password) async {
    if (await getAuthMethod() != AuthMethod.password) throw AuthError("Установлен другой метод авторизации");
    final prefs = await SharedPreferences.getInstance();
    if (password != prefs.getString(_passwordKey)) {
      throw AuthError("Неверный пароль");
    }
    prefs.setInt(_authStateKey, AuthState.authorized.index);
  }

  @override
  logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_authStateKey, AuthState.unauthorized.index);
  }
}