import 'package:flutter/material.dart';
import 'package:internhub/checkInternet.dart';
import 'package:provider/provider.dart';

class InternetHelper {
  static DateTime? _lastDialogShown;
  static bool _isDialogShowing = false;

  static void monitor(BuildContext context) {
    final provider = context.read<InternetProvider>();

    checkAndShowDialog(context, provider);

    provider.addListener(() {
      checkAndShowDialog(context, provider);
    });
  }

  static Future<void> checkAndShowDialog(
    BuildContext context,
    InternetProvider provider,
  ) async {
    if (!context.mounted || _isDialogShowing) return;

    if (provider.status == InternetStatus.disconnected) {
      if (_lastDialogShown == null ||
          DateTime.now().difference(_lastDialogShown!) >
              const Duration(seconds: 3)) {
        _isDialogShowing = true;
        FocusScope.of(context).unfocus();

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'No internet connection!',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            content: const Text(
              'InternHub needs an internet connection to function.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isDialogShowing = false;
                  _lastDialogShown = null;
                  checkAndShowDialog(context, provider);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xffF5761A),
                ),
                child: const Text('Reconnect'),
              ),
            ],
          ),
        );

        _lastDialogShown = DateTime.now();
        _isDialogShowing = false;
      }
    }
  }
}
