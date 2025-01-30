import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiProvider extends ChangeNotifier {
  String _openaikey;
  late SharedPreferences _prefs;

  ApiProvider._internal(this._openaikey, this._prefs);

  String get openAiKey => _openaikey;
  static Future<ApiProvider> create(String openAiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return ApiProvider._internal(openAiKey, prefs);
  }

  Future<void> loadApiKey() async {
    String openaikey = _prefs.getString('openaikey') ?? "";
    _openaikey = openaikey;
    notifyListeners(); // Notify listeners when settings are loaded
  }

  Future<void> updateApiKey(String apiKey) async {
    // final SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('openaikey', apiKey);
    _openaikey = apiKey;
    notifyListeners();
  }
}
