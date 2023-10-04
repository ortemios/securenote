import 'package:flutter/material.dart';
import 'package:secure_note/view/fingerprint_input_page.dart';
import 'package:secure_note/view/password_input_page.dart';

class AuthMethodPage extends StatelessWidget {
  const AuthMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Выберите способ входа"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FingerprintInputPage()));
                },
                child: const Text("Отпечаток"),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const PasswordInputPage()));
                },
                child: const Text("Пароль"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
