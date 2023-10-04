import 'package:flutter/material.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/view/password_repeat_page.dart';
import 'package:secure_note/view/phone_input_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Вы в системе",
            textAlign: TextAlign.center,
          ),
          MaterialButton(
            onPressed: () => AuthRepository.inst.logout().then(
                  (value) => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PhoneInputPage()),
                    (route) => false,
                  ),
                ),
            child: const Text("Выйти"),
          ),
        ],
      ),
    );
  }
}
