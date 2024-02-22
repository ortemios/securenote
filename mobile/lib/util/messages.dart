import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:secure_note/model/errors.dart';

class Messages {
  static showError(BuildContext context, Object? error) {
    var text = 'Что-то пошло не так...';
    if (error is AuthError) {
      text = error.message;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    });
  }

  static void showErrorAlert(
    BuildContext context, {
    void Function()? onRetry,
    String message = 'Ошибка при выполнении запроса',
  }) {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            //title: const Text('Ошибка'),
            content: Text(message),
            actions: <Widget>[
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                    onRetry();
                  },
                  child: const Text('Повторить'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
            ],
          ),
        );
      },
    );
  }
}
