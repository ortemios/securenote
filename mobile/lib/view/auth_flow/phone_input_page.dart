import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_note/data/auth/auth_repository.dart';
import 'package:secure_note/util/messages.dart';
import 'package:secure_note/util/validators.dart';
import 'package:secure_note/view/auth_flow/pin_input_page.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
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
          const Text("Введите номер телефона (10 цифр без +7)"),
          TextFormField(
            controller: _textController,
            textAlign: TextAlign.center,
            enableSuggestions: false,
            validator: Validators.phone,
            keyboardType: TextInputType.phone,
            inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          ),
          MaterialButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final phone = _textController.text;
                  AuthRepository.inst.sendSms(phone).then((resendTime) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PinInputPage(
                          phone: phone,
                          resendTime: resendTime,
                        ),
                      ),
                    );
                  }).catchError((e) => Messages.showError(context, e));
                }
              },
              child: const Text("Далее"))
        ],
      ),
    ));
  }
}
