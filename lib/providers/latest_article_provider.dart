import 'package:flutter/cupertino.dart';

class LatestArticleNotifier extends ChangeNotifier {
  int id = 0;

  void updateValue(int newValue) {
    id = newValue;
    notifyListeners();
  }
}
