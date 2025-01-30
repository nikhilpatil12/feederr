import 'package:feederr/models/font_settings.dart';
import 'package:feederr/providers/api_provider.dart';
import 'package:feederr/providers/font_provider.dart';
import 'package:feederr/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:feederr/models/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = await ThemeProvider.create(
    AppTheme(),
  );
  final fontProvider = await FontProvider.create(
    FontSettings(),
  );
  final apiProvider = await ApiProvider.create(
    "",
  );
  runApp(
    MyApp(
      themeProvider: themeProvider,
      fontProvider: fontProvider,
      apiProvider: apiProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final FontProvider fontProvider;
  final ApiProvider apiProvider;
  const MyApp({
    super.key,
    required this.themeProvider,
    required this.fontProvider,
    required this.apiProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      themeProvider.loadTheme();
      fontProvider.loadSettings();
      apiProvider.loadApiKey();

      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeProvider),
          ChangeNotifierProvider(create: (_) => fontProvider),
          ChangeNotifierProvider(create: (_) => apiProvider),
        ],
        child: Selector<ThemeProvider, AppTheme>(
          selector: (_, themeProvider) => themeProvider.theme,
          builder: (_, theme, __) {
            // ThemeData themeData = theme.isDark
            //     ? ThemeData.from()
            //     : ThemeData.light();
            ThemeData themeData = ThemeData(
              canvasColor: Color(theme.surfaceColor),
              splashColor: Colors.transparent,
              // colorSchemeSeed: Color(theme.primaryColor),
              primaryColor: Color(theme.primaryColor),
              highlightColor: Colors.transparent,
              // colorSchemeSeed: Color(theme.primaryColor),
              // scaffoldBackgroundColor: Color(theme.surfaceColor),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: WidgetStateProperty.all(
                  Color(theme.primaryColor),
                ),
              ),
              colorScheme: ColorScheme(
                primary: Color(theme.primaryColor),
                brightness: theme.isDark ? Brightness.dark : Brightness.light,
                onPrimary: Color(theme.textColor),
                secondary: Color(theme.secondaryColor),
                onSecondary: Color.fromRGBO(255, 0, 183, 1),
                error: Color.fromRGBO(205, 0, 0, 1),
                onError: Color.fromRGBO(255, 255, 255, 1),
                surface: Color(theme.surfaceColor),
                // surfaceContainer: Color(theme.surfaceColor),
                // surfaceDim: Color(theme.surfaceColor),
                // surfaceBright: Color(theme.surfaceColor),
                onSurface: Color(theme.textColor),
                // primaryContainer: Color(theme.surfaceColor),
              ),
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  // Use PredictiveBackPageTransitionsBuilder to get the predictive back route transition!
                  TargetPlatform.android:
                      PredictiveBackPageTransitionsBuilder(),
                },
              ),
            );
            return MaterialApp(
              title: "Feederr",
              theme: themeData,
              home: HomeScreen(),
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
