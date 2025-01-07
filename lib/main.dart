import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home.dart';
import 'package:feederr/models/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void updateTheme(BuildContext context) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.loadTheme();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppTheme theme;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    //TODO: LOAD SETTINGS FROM LOCAL CONFIG
    final surfaceColor = await asyncPrefs.getInt('surfaceColor') ?? 0xff1f1f1f;
    final textColor = await asyncPrefs.getInt('textColor') ?? 0xffffffff;
    final primaryColor = await asyncPrefs.getInt('primaryColor') ?? 0xffff0000;
    final secondaryColor =
        await asyncPrefs.getInt('secondaryColor') ?? 0xff3b3b3b;
    // final textColor = await asyncPrefs.getInt('textColor') ?? 0xffffffff;
    // print(surfaceColor);
    theme = AppTheme(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      textHighlightColor: 0xff0000ff,
    );

    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Feederr';
    if (!isLoaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: "Feederr",
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme(
          // background: Color.fromRGBO(205, 205, 205, 1),
          primary: Color(theme.primaryColor),
          // onBackground: Color.fromRGBO(205, 205, 205, 1),
          brightness: Brightness.dark,
          onPrimary: Color(theme.textColor),
          secondary: Color(theme.secondaryColor),
          onSecondary: Color.fromRGBO(255, 0, 183, 1),
          error: Color.fromRGBO(205, 0, 0, 1),
          onError: Color.fromRGBO(255, 255, 255, 1),
          surface: Color(theme.surfaceColor),
          onSurface: Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
      home: HomeScreen(
        title: appTitle,
        theme: theme,
      ),
    );
  }
}
