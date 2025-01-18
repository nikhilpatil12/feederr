import 'package:feederr/models/app_theme.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme;
  FontSettings _fontSettings;

  ThemeProvider(this._theme, this._fontSettings);

  AppTheme get theme => _theme;
  FontSettings get fontSettings => _fontSettings;

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final surfaceColor = prefs.getInt('surfaceColor') ?? 0xff1f1f1f;
    final textColor = prefs.getInt('textColor') ?? 0xffffffff;
    final primaryColor = prefs.getInt('primaryColor') ?? 0xffff0000;
    final secondaryColor = prefs.getInt('secondaryColor') ?? 0xff3b3b3b;

    String articleFont = prefs.getString('articleFont') ?? "Chillax";
    double titleFontSize = prefs.getDouble('titleFontSize') ?? 20;
    String titleAlignmentStr = prefs.getString('titleAlignment') ?? "left";

    double articleFontSize = prefs.getDouble('articleFontSize') ?? 12;
    String articleAlignmentStr = prefs.getString('articleAlignment') ?? "left";
    double articleLineSpacing = prefs.getDouble('articleLineSpacing') ?? 1.5;
    double articleContentWidth = prefs.getDouble('articleContentWidth') ?? 5;

    _theme = AppTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      isDark: isDarkMode,
    );

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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (key) {
      case 'primaryColor':
        await prefs.setInt('primaryColor', value);
        _theme = _theme.copyWith(primaryColor: value);
        break;
      case 'secondaryColor':
        await prefs.setInt('secondaryColor', value);
        _theme = _theme.copyWith(secondaryColor: value);
        break;
      case 'surfaceColor':
        await prefs.setInt('surfaceColor', value);
        _theme = _theme.copyWith(surfaceColor: value);
        break;
      case 'textColor':
        await prefs.setInt('textColor', value);
        _theme = _theme.copyWith(textColor: value);
        break;
      case 'isDarkMode':
        await prefs.setBool('isDarkMode', value);
        _theme = _theme.copyWith(isDark: value);
        break;
      case 'articleFont':
        await prefs.setString('articleFont', value);
        _fontSettings = _fontSettings.copyWith(articleFont: value);
        break;
      case 'titleFontSize':
        await prefs.setDouble('titleFontSize', value);
        _fontSettings = _fontSettings.copyWith(titleFontSize: value);
        break;
      case 'articleFontSize':
        await prefs.setDouble('articleFontSize', value);
        _fontSettings = _fontSettings.copyWith(articleFontSize: value);
        break;
      case 'articleLineSpacing':
        await prefs.setDouble('articleLineSpacing', value);
        _fontSettings = _fontSettings.copyWith(articleLineSpacing: value);
        break;
      case 'articleContentWidth':
        await prefs.setDouble('articleContentWidth', value);
        _fontSettings = _fontSettings.copyWith(articleContentWidth: value);
        break;
      case 'titleAlignment':
        await prefs.setString('titleAlignment', value);
        _fontSettings =
            _fontSettings.copyWith(titleAlignment: _getAlignment(value));
        break;
      case 'articleAlignment':
        await prefs.setString('articleAlignment', value);
        _fontSettings =
            _fontSettings.copyWith(articleAlignment: _getAlignment(value));
        break;
      default:
        print('unknownn');
        return;
    }

    notifyListeners();
  }
}
