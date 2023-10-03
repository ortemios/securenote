import 'package:flutter/material.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/util/validators.dart';
import 'package:secure_note/view/home_page.dart';
import 'package:secure_note/view/password_repeat_page.dart';

import '../util/messages.dart';

class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  State<PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends State<PasswordInputPage> {

  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var logged = false;

  @override
  void initState() {
    super.initState();
    AuthRepository.inst.getAuthMethod().then((method) {
      setState(() {
        logged = method == AuthMethod.password;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Введите пароль"),
              TextFormField(
                controller: _controller,
                textAlign: TextAlign.center,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                validator: Validators.password,
              ),
              MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final password = _controller.text;
                      if (logged) {
                        AuthRepository.inst.checkPassword(password)
                            .then((value) => AuthRepository.inst.loginWithToken())
                            .then((value) => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                const HomePage())
                            )).catchError((e) => _toPasswordRepeatPage()
                            .then((value) => Messages.showError(context, e))
                        );
                      } else {
                        _toPasswordRepeatPage();
                      }
                    }
                  },
                  child: Text(logged ? "Войти" : "Далее")
              )
            ],
          ),
        )
    );
  }

  Future<void> _toPasswordRepeatPage() async {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PasswordRepeatPage(_controller.text)),
            (_) => true
    ).then((e) => null);
  }
}