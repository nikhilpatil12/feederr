import 'package:feederr/models/font_settings.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:feederr/models/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final theme = ThemeProvider(AppTheme(), FontSettings());
      theme.loadSettings();
      return ChangeNotifierProvider(
        create: (_) => theme,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            // ThemeData themeData = themeProvider.theme.isDark
            //     ? ThemeData.from()
            //     : ThemeData.light();
            ThemeData themeData = ThemeData(
              canvasColor: Color(themeProvider.theme.surfaceColor),
              splashColor: Colors.transparent,
              primaryColor: Color(themeProvider.theme.primaryColor),
              highlightColor: Colors.transparent,
              // colorSchemeSeed: Color(themeProvider.theme.primaryColor),
              // scaffoldBackgroundColor: Color(themeProvider.theme.surfaceColor),
              colorScheme: ColorScheme(
                primary: Color(themeProvider.theme.primaryColor),
                brightness: themeProvider.theme.isDark
                    ? Brightness.dark
                    : Brightness.light,
                onPrimary: Color(themeProvider.theme.textColor),
                secondary: Color(themeProvider.theme.secondaryColor),
                onSecondary: Color.fromRGBO(255, 0, 183, 1),
                error: Color.fromRGBO(205, 0, 0, 1),
                onError: Color.fromRGBO(255, 255, 255, 1),
                surface: Color(themeProvider.theme.surfaceColor),
                // surfaceContainer: Color(themeProvider.theme.surfaceColor),
                // surfaceDim: Color(themeProvider.theme.surfaceColor),
                // surfaceBright: Color(themeProvider.theme.surfaceColor),
                onSurface: Color(themeProvider.theme.textColor),
                // primaryContainer: Color(themeProvider.theme.surfaceColor),
              ),
            );
            return MaterialApp(
              title: "Feederr",
              theme: themeData,
              home: HomeScreen(
                themeProvider: themeProvider,
              ),
            );
          },
        ),
      );
    });
  }
}
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late AppTheme theme;
//   late FontSettings fontSettings;
//   bool isLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const String appTitle = 'Feederr';
//     if (!isLoaded) {
//       return const MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//     }
//     return MaterialApp(
//       title: "Feederr",
//       theme: ThemeData(
//         splashColor: Colors.transparent,
//         highlightColor: Colors.transparent,
//         colorScheme: ColorScheme(
//           // background: Color.fromRGBO(205, 205, 205, 1),
//           primary: Color(theme.primaryColor),
//           // onBackground: Color.fromRGBO(205, 205, 205, 1),
//           brightness: theme.isDark ? Brightness.dark : Brightness.light,
//           onPrimary: Color(theme.textColor),
//           secondary: Color(theme.secondaryColor),
//           onSecondary: Color.fromRGBO(255, 0, 183, 1),
//           error: Color.fromRGBO(205, 0, 0, 1),
//           onError: Color.fromRGBO(255, 255, 255, 1),
//           surface: Color(theme.surfaceColor),
//           onSurface: Color.fromRGBO(255, 255, 255, 1),
//         ),
//       ),
//       home: HomeScreen(
//         title: appTitle,
//         theme: theme,
//         fontSettings: fontSettings,
//       ),
//     );
//   }
// }
