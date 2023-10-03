import 'package:flutter/material.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/view/password_repeat_page.dart';
import 'package:secure_note/view/phone_input_page.dart';

import '../util/messages.dart';
import 'home_page.dart';

class FingerprintInputPage extends StatefulWidget {
  const FingerprintInputPage({super.key});

  @override
  State<FingerprintInputPage> createState() => _FingerprintInputPageState();
}

class _FingerprintInputPageState extends State<FingerprintInputPage> {

  var logged = false;

  @override
  void initState() {
    super.initState();
    AuthRepository.inst.getAuthMethod().then((method) {
      setState(() {
        logged = method == AuthMethod.fingerprint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Приложите палец к сенсору",
              textAlign: TextAlign.center,
            ),
            MaterialButton(
                onPressed: () {
                  if (logged) {
                    AuthRepository.inst.loginWithToken()
                        .then((value) => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage())))
                        .catchError((e) {
                          _toPhoneInput().then((value) =>
                              Messages.showError(context, e)
                          );
                    });
                  } else {
                    _toPhoneInput();
                  }
                },
                child: Text(logged ? "Войти" : "Далее")
            )
          ],
        )
    );
  }

  Future<void> _toPhoneInput() {
    return AuthRepository.inst.setFingerprintAuth().then(
            (value) => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhoneInputPage())
        )
    ).catchError((e) => Messages.showError(context, e));
  }
}