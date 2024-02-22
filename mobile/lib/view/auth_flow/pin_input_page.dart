import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:secure_note/api/api.dart';
import 'package:secure_note/data/auth/auth_repository.dart';
import 'package:secure_note/view/auth_flow/auth_method_page.dart';
import 'package:secure_note/view/auth_flow/fingerprint_input_page.dart';
import 'package:secure_note/view/auth_flow/password_input_page.dart';
import '../../util/messages.dart';

class PinInputPage extends StatefulWidget {
  final String phone;
  final int resendTime;

  const PinInputPage({
    super.key,
    required this.phone,
    required this.resendTime,
  });

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  late int _resendTime;
  late Timer _timer;

  @override
  void initState() {
    _resendTime = widget.resendTime;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {});
      },
    );
    super.initState();
  }

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
              maxLength: 6,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
            ),
            MaterialButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final pin = _textController.text;
                    AuthRepository.inst
                        .checkSms(
                          phone: widget.phone,
                          pin: pin,
                        )
                        .then((v) => AuthRepository.inst.getAuthMethod())
                        .then((method) {
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
            _resendView,
          ],
        ),
      ),
    );
  }

  Widget get _resendView {
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int delta = _resendTime - now;
    if (delta > 0) {
      return Text("Повторно код можно отправить через $delta сек.");
    } else {
      return MaterialButton(
        onPressed: () {
          AuthRepository.inst.sendSms(widget.phone).then((value) {
            setState(() {
              _resendTime = value;
            });
          }).catchError((e) => Messages.showError(context, e));
        },
        child: const Text("Отправить повторно"),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
