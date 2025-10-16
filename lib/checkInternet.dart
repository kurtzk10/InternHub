import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum InternetStatus { connected, disconnected }

class InternetProvider extends ChangeNotifier {
  InternetProvider() {
    _startMonitoring();
  }

  InternetStatus _status = InternetStatus.connected;
  InternetStatus get status => _status;

  void _startMonitoring() {
    // For web platform, assume internet is always connected
    // since the internet_connection_checker package has issues on web
    if (kIsWeb) {
      _status = InternetStatus.connected;
      notifyListeners();
      return;
    }
    
    // For mobile platforms, you can implement proper internet checking here
    // For now, we'll assume connected to avoid the error
    _status = InternetStatus.connected;
    notifyListeners();
  }
}
