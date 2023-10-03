import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:secure_note/model/errors.dart';

class Messages {

  static showError(BuildContext context, Object error) {
    var text = 'Что-то пошло не так...';
    if (error is AuthError) {
      text = error.message;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text))
      );
    });
  }
}
