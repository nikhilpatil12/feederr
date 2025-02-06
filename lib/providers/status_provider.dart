import 'package:flutter/cupertino.dart';

class StatusProvider extends ChangeNotifier {
  String status = "";

  void updateStatus(String newValue) {
    status = newValue;
    notifyListeners();
  }
}
