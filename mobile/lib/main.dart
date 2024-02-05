import 'package:flutter/material.dart';
import 'package:secure_note/data/auth_repository.dart';
import 'package:secure_note/view/auth_flow/auth_method_page.dart';
import 'package:secure_note/view/auth_flow/fingerprint_input_page.dart';
import 'package:secure_note/view/auth_flow/password_input_page.dart';
import 'package:secure_note/view/auth_flow/phone_input_page.dart';
import 'package:secure_note/view/poster.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    AuthRepository.inst.getAuthState().then((state) async {
      return switch (state) {
        AuthState.unauthorized => const PhoneInputPage(),
        _ => switch (await AuthRepository.inst.getAuthMethod()) {
            AuthMethod.none => const AuthMethodPage(),
            AuthMethod.password => const PasswordInputPage(),
            AuthMethod.fingerprint => const FingerprintInputPage(),
          }
      };
    }).then((page) {
      final context = _navigatorKey.currentContext;
      if (context != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => page),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Secure Note',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Poster(),
    );
  }
}
