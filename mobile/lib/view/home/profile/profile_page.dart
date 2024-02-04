import 'package:flutter/material.dart';

import '../../../data/auth_repository.dart';
import '../../auth_flow/phone_input_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}
