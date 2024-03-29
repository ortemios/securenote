import 'package:flutter/material.dart';
import 'package:secure_note/data/auth/auth_repository.dart';
import 'package:secure_note/view/auth_flow/password_repeat_page.dart';
import 'package:secure_note/view/auth_flow/phone_input_page.dart';

import '../../util/messages.dart';
import '../home/home_page.dart';

class FingerprintInputPage extends StatefulWidget {
  const FingerprintInputPage({super.key});

  @override
  State<FingerprintInputPage> createState() => _FingerprintInputPageState();
}

class _FingerprintInputPageState extends State<FingerprintInputPage> {
  //var logged = false;

  @override
  void initState() {
    super.initState();
    // AuthRepository.inst.getAuthMethod().then((method) {
    //   setState(() {
    //     logged = method == AuthMethod.fingerprint;
    //   });
    // });
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
              //AuthRepository.inst.setFingerprintAuth().then((value) => ).
              AuthRepository.inst
                  .signInWithFingerprint()
                  .then(
                    (value) => Navigator.pushReplacement(context, HomePage.route()),
                  )
                  .catchError((e) => Messages.showError(context, e));
              // } else {
              //   _toPhoneInput();
              // }
            },
            child: Text("*приложить*"),
          ),
        ],
      ),
    );
  }
}
