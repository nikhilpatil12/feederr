import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class FontSettings {
  String articleFont;
  double titleFontSize;
  TextAlign titleAlignment;

  double articleFontSize;
  TextAlign articleAlignment;
  double articleLineSpacing;
  double articleContentWidth;

  FontSettings({
    this.articleFont = "Chillax",
    this.titleFontSize = 28,
    this.titleAlignment = TextAlign.left,
    this.articleFontSize = 17,
    this.articleAlignment = TextAlign.left,
    this.articleLineSpacing = 1.5,
    this.articleContentWidth = 5,
  });
  FontSettings copyWith({
    String? articleFont,
    double? titleFontSize,
    TextAlign? titleAlignment,
    double? articleFontSize,
    TextAlign? articleAlignment,
    double? articleLineSpacing,
    double? articleContentWidth,
  }) {
    return FontSettings(
      articleFont: articleFont ?? this.articleFont,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      titleAlignment: titleAlignment ?? this.titleAlignment,
      articleFontSize: articleFontSize ?? this.articleFontSize,
      articleAlignment: articleAlignment ?? this.articleAlignment,
      articleLineSpacing: articleLineSpacing ?? this.articleLineSpacing,
      articleContentWidth: articleContentWidth ?? this.articleContentWidth,
    );
  }
}
