class Validators {
  static var password = (String? value) {
    value = value ?? '';
    if (value.length < 8) {
      return 'Пароль слишком короткий';
    }
    if (value.length > 16) {
      return 'Пароль слишком длинный';
    }
    return null;
  };

  static var phone = (String? value) {
    value = value ?? '';

    if (value.length != 10) {
      return 'Номер должен состоять из 10 цифр (без +7)';
    }
    return null;
  };
}
