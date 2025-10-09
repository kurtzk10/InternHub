import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

enum InternetStatus { connected, disconnected }

class InternetProvider extends ChangeNotifier {
  InternetProvider() {
    _startMonitoring();
  }

  InternetStatus _status = InternetStatus.connected;
  InternetStatus get status => _status;

  void _startMonitoring() {
    InternetConnectionChecker().onStatusChange.listen((event) {
      final newStatus = event == InternetConnectionStatus.connected
          ? InternetStatus.connected
          : InternetStatus.disconnected;
      
      if (_status != newStatus) {
        _status = newStatus;
        notifyListeners();
      }
    });
  }
}
