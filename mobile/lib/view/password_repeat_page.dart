import 'package:flutter/material.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/view/home_page.dart';
import 'package:secure_note/view/phone_input_page.dart';

import '../util/messages.dart';
import '../util/validators.dart';

class PasswordRepeatPage extends StatefulWidget {
  final String password;

  const PasswordRepeatPage(this.password, {super.key});

  @override
  State<PasswordRepeatPage> createState() => _PasswordRepeatPageState();
}

class _PasswordRepeatPageState extends State<PasswordRepeatPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Повторите пароль"),
            TextFormField(
              controller: _controller,
              textAlign: TextAlign.center,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              validator: (value) {
                if (value != widget.password) {
                  return 'Пароли не совпадают';
                }
                return null;
              },
            ),
            MaterialButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  AuthRepository.inst.setPasswordAuth(widget.password).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }).catchError((e) => Messages.showError(context, e));
                }
              },
              child: const Text("Далее"),
            ),
          ],
        ),
      ),
    );
  }
}
