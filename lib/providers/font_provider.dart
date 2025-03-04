import 'dart:developer';
import 'package:blazefeeds/models/font_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  FontSettings _fontSettings;
  late SharedPreferences _prefs;

  FontProvider._internal(this._fontSettings, this._prefs);

  static Future<FontProvider> create(
    FontSettings fontSettings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    return FontProvider._internal(fontSettings, prefs);
  }

  FontSettings get fontSettings => _fontSettings;

  Future<void> loadSettings() async {
    String articleFont = _prefs.getString('articleFont') ?? "Chillax";
    double titleFontSize = _prefs.getDouble('titleFontSize') ?? 28;
    String titleAlignmentStr = _prefs.getString('titleAlignment') ?? "left";

    double articleFontSize = _prefs.getDouble('articleFontSize') ?? 17;
    String articleAlignmentStr = _prefs.getString('articleAlignment') ?? "left";
    double articleLineSpacing = _prefs.getDouble('articleLineSpacing') ?? 1.5;
    double articleContentWidth = _prefs.getDouble('articleContentWidth') ?? 5;

    TextAlign titleAlignment = _getAlignment(titleAlignmentStr);
    TextAlign articleAlignment = _getAlignment(articleAlignmentStr);

    _fontSettings = FontSettings(
      articleFont: articleFont,
      titleFontSize: titleFontSize,
      titleAlignment: titleAlignment,
      articleFontSize: articleFontSize,
      articleAlignment: articleAlignment,
      articleLineSpacing: articleLineSpacing,
      articleContentWidth: articleContentWidth,
    );

    notifyListeners(); // Notify listeners when settings are loaded
  }

  TextAlign _getAlignment(String alignmentStr) {
    switch (alignmentStr) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  // Generic function to update a setting
  Future<void> updateSetting(String key, dynamic value) async {
    switch (key) {
      case 'articleFont':
        await _prefs.setString('articleFont', value);
        _fontSettings = _fontSettings.copyWith(articleFont: value);
        break;
      case 'titleFontSize':
        await _prefs.setDouble('titleFontSize', value);
        _fontSettings = _fontSettings.copyWith(titleFontSize: value);
        break;
      case 'articleFontSize':
        await _prefs.setDouble('articleFontSize', value);
        _fontSettings = _fontSettings.copyWith(articleFontSize: value);
        break;
      case 'articleLineSpacing':
        await _prefs.setDouble('articleLineSpacing', value);
        _fontSettings = _fontSettings.copyWith(articleLineSpacing: value);
        break;
      case 'articleContentWidth':
        await _prefs.setDouble('articleContentWidth', value);
        _fontSettings = _fontSettings.copyWith(articleContentWidth: value);
        break;
      case 'titleAlignment':
        await _prefs.setString('titleAlignment', value);
        _fontSettings = _fontSettings.copyWith(titleAlignment: _getAlignment(value));
        break;
      case 'articleAlignment':
        await _prefs.setString('articleAlignment', value);
        _fontSettings = _fontSettings.copyWith(articleAlignment: _getAlignment(value));
        break;
      default:
        log('unknownn');
        return;
    }

    notifyListeners();
  }
}
