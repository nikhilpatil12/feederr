import 'package:blazefeeds/models/font_settings.dart';
import 'package:blazefeeds/providers/api_provider.dart';
import 'package:blazefeeds/providers/font_provider.dart';
import 'package:blazefeeds/providers/latest_article_provider.dart';
import 'package:blazefeeds/providers/status_provider.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home.dart';
import 'package:blazefeeds/models/app_theme.dart';

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

class MyApp extends StatefulWidget {
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
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.themeProvider.loadTheme();
    widget.fontProvider.loadSettings();
    widget.apiProvider.loadApiKey();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => widget.themeProvider),
          ChangeNotifierProvider(create: (_) => widget.fontProvider),
          ChangeNotifierProvider(create: (_) => widget.apiProvider),
          ChangeNotifierProvider(create: (_) => LatestArticleNotifier()),
          ChangeNotifierProvider(create: (_) => StatusProvider()),
        ],
        child: Selector<ThemeProvider, AppTheme>(
          selector: (_, themeProvider) => themeProvider.theme,
          builder: (_, theme, __) {
            final luminanceDifference = Color(theme.primaryColor).computeLuminance() -
                Color(theme.textColor).computeLuminance();
            // ThemeData themeData = theme.isDark
            //     ? ThemeData.from()
            //     : ThemeData.light();
            ThemeData inspo = ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Color(theme.primaryColor),
              // brightness: theme.isDark ? Brightness.dark : Brightness.light,
            );
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
              fontFamily: 'General Sans',
              textTheme: TextTheme(
                displayLarge: TextStyle(
                  fontSize: 48,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                displayMedium: TextStyle(
                  fontSize: 36,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                displaySmall: TextStyle(
                  fontSize: 24,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                headlineLarge: TextStyle(
                  fontSize: 17,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                headlineMedium: TextStyle(
                  fontSize: 15,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                headlineSmall: TextStyle(
                  fontSize: 13,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                titleLarge: TextStyle(
                  fontSize: 28,
                  fontVariations: const [
                    FontVariation('wght', 500),
                  ],
                ),
                titleMedium: TextStyle(
                  fontSize: 26,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                titleSmall: TextStyle(
                  fontSize: 24,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                bodyLarge: TextStyle(
                  fontSize: 17,
                  fontVariations: const [
                    FontVariation('wght', 500),
                  ],
                ),
                bodyMedium: TextStyle(
                  fontSize: 17,
                  fontVariations: const [
                    FontVariation('wght', 500),
                  ],
                ),
                bodySmall: TextStyle(
                  fontSize: 13,
                  fontVariations: const [
                    FontVariation('wght', 500),
                  ],
                ),
                labelLarge: TextStyle(
                  fontSize: 12,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                labelMedium: TextStyle(
                  fontSize: 11,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
                labelSmall: TextStyle(
                  fontSize: 10,
                  fontVariations: const [FontVariation('wght', 500)],
                ),
              ),
              colorScheme: ColorScheme(
                primary: Color(theme.primaryColor),
                // brightness: theme.isDark ? Brightness.dark : Brightness.light,
                brightness: Brightness.dark,
                onPrimary:
                    luminanceDifference >= 0.3 ? Color(theme.textColor) : Color(theme.surfaceColor),
                secondary: Color(theme.secondaryColor),
                onSecondary: inspo.colorScheme.onSecondary,
                error: inspo.colorScheme.error,
                onError: inspo.colorScheme.onError,
                surface: Color(theme.surfaceColor),
                // surfaceContainer: Color(theme.surfaceColor),
                // surfaceDim: Color(theme.surfaceColor),
                // surfaceBright: Color(theme.surfaceColor),
                onSurface: Color(theme.textColor),
                // primaryContainer: Color(theme.surfaceColor),
              ),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
                  TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
                  // You can mix and match with other platforms
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
              // const PageTransitionsTheme(
              //   builders: {
              //     // Use PredictiveBackPageTransitionsBuilder to get the predictive back route transition!
              //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
              //   },
              // ),
            );
            return MaterialApp(
              // Hides the debug banner in the top right corner of the app
              debugShowCheckedModeBanner: false,
              title: "Blaze Feeds",
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
