import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Feederr';
    return MaterialApp(
      title: "App",
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: const ColorScheme(
            primary: Color.fromRGBO(76, 2, 232, 1),
            brightness: Brightness.dark,
            onPrimary: Color.fromRGBO(205, 205, 205, 1),
            secondary: Color.fromRGBO(60, 254, 207, 1),
            onSecondary: Color.fromRGBO(255, 0, 183, 1),
            error: Color.fromRGBO(205, 0, 0, 1),
            onError: Color.fromRGBO(255, 255, 255, 1),
            surface: Color.fromRGBO(8, 8, 8, 1),
            onSurface: Color.fromRGBO(255, 255, 255, 1)),
      ),
      home: const HomeScreen(title: appTitle),
    );
  }
}
