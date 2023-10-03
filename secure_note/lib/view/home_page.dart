import 'package:flutter/material.dart';
import 'package:secure_note/view/password_repeat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Вы в системе",
              textAlign: TextAlign.center,
            ),
          ],
        )
    );
  }
}