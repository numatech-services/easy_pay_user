import 'dart:async';

import 'package:flutter/material.dart';
import 'package:viserpay/core/utils/util.dart';
import 'package:viserpay/main.dart';

class InActivityTimer {
    static final InActivityTimer _instance = InActivityTimer._internal();

  factory InActivityTimer() => _instance;

  InActivityTimer._internal();

  Timer? _timer;
  DateTime? lastInteractionTime;

  void startTimer(BuildContext context) {
    lastInteractionTime = DateTime.now();
    _startInactivityTimer(context);
  }

  void _startInactivityTimer(BuildContext context) {
    print("start Inactivity timer is triggered");

    if (_timer != null && _timer!.isActive) {
      print("==========================OK========================");
      _timer!.cancel();
    }

    _timer = Timer(const Duration(minutes: 10), () {
      _restartApp(context);
    });
  }

    void onAppPaused(BuildContext context) {
      if (_timer != null) {
              print("==========================OK");
        _timer?.cancel();
       _timer = null;
    }
  }

  void _restartApp(BuildContext context) {
   MyUtils().showLogoutWarning();
  }

  void handleUserInteraction(BuildContext context) {
    print("Handling user interaction");
    lastInteractionTime = DateTime.now();
    _startInactivityTimer(context);
  }
}