import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/view/auth_flow/auth_method_page.dart';
import 'package:secure_note/view/auth_flow/fingerprint_input_page.dart';
import 'package:secure_note/view/auth_flow/password_input_page.dart';
import '../../util/messages.dart';

class PinInputPage extends StatefulWidget {
  final String phone;

  const PinInputPage(this.phone, {super.key});

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Введите код из SMS на номер ${widget.phone}"),
            TextField(
              controller: _textController,
              textAlign: TextAlign.center,
              enableSuggestions: false,
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            ),
            MaterialButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final pin = _textController.text;
                    AuthRepository.inst.checkSms(pin).then((v) => AuthRepository.inst.getAuthMethod()).then((method) {
                      final page = switch (method) {
                        AuthMethod.none => const AuthMethodPage(),
                        AuthMethod.password => const PasswordInputPage(),
                        AuthMethod.fingerprint => const FingerprintInputPage(),
                      };
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => page),
                        (route) => false,
                      );
                    }).catchError((e) => Messages.showError(context, e));
                  }
                },
                child: const Text("Далее")),
            // const Text("Повторно код можно отправить через 60с"),
            // MaterialButton(onPressed: () {}, child: const Text("Отправить повторно")),
          ],
        ),
      ),
    );
  }
}
