import 'dart:math';

class StringUtil {
  static String generatePassword() {
    const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final rnd = Random();
    const passwordLength = 15;
    return String.fromCharCodes(
      Iterable.generate(
        passwordLength,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
  }
}
