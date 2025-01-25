import 'dart:developer';

import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme;
  late SharedPreferences _prefs;

  ThemeProvider._internal(this._theme, this._prefs);

  static Future<ThemeProvider> create(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeProvider._internal(theme, prefs);
  }

  AppTheme get theme => _theme;

  Future<void> loadTheme() async {
    final bool isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    final surfaceColor = _prefs.getInt('surfaceColor') ?? 0xff1f1f1f;
    final textColor = _prefs.getInt('textColor') ?? 0xffffffff;
    final primaryColor = _prefs.getInt('primaryColor') ?? 0xffff0000;
    final secondaryColor = _prefs.getInt('secondaryColor') ?? 0xff3b3b3b;

    _theme = AppTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      isDark: isDarkMode,
    );

    notifyListeners(); // Notify listeners when settings are loaded
  }

  // Generic function to update a setting
  Future<void> updateTheme(String key, dynamic value) async {
    switch (key) {
      case 'primaryColor':
        await _prefs.setInt('primaryColor', value);
        _theme = _theme.copyWith(primaryColor: value);
        break;
      case 'secondaryColor':
        await _prefs.setInt('secondaryColor', value);
        _theme = _theme.copyWith(secondaryColor: value);
        break;
      case 'surfaceColor':
        await _prefs.setInt('surfaceColor', value);
        _theme = _theme.copyWith(surfaceColor: value);
        break;
      case 'textColor':
        await _prefs.setInt('textColor', value);
        _theme = _theme.copyWith(textColor: value);
        break;
      case 'isDarkMode':
        await _prefs.setBool('isDarkMode', value);
        _theme = _theme.copyWith(isDark: value);
        break;
      default:
        log('unknownn');
        return;
    }

    notifyListeners();
  }
}
