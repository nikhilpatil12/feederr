class AppTheme {
  int primaryColor;
  // onPrimary = textColor,

  int secondaryColor;
  // int onSecondary: Color.fromRGBO(255, 0, 183, 1),

  int textColor;
  // int textHighlightColor;

  int surfaceColor;
  bool isDark;

  AppTheme({
    this.primaryColor = 0xFF00E731,
    this.secondaryColor = 0xFF000341,
    this.textColor = 0xFFFFFFFF,
    // required this.textHighlightColor,
    this.surfaceColor = 0xFF000433,
    this.isDark = true,
  });

  AppTheme copyWith({
    int? primaryColor,
    int? secondaryColor,
    int? surfaceColor,
    int? textColor,
    bool? isDark,
  }) {
    return AppTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      isDark: isDark ?? this.isDark,
    );
  }
}
