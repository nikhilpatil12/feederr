import 'dart:ui';

import 'package:feederr/main.dart';
import 'package:feederr/models/font_settings.dart';
import 'package:feederr/pages/settings/custom_theme.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/widgets/theme_preview.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key});
  @override
  AppearanceSettingsState createState() => AppearanceSettingsState();
}

class AppearanceSettingsState extends State<AppearanceSettings> {
  List<String> fonts = [
    "Cabinet Grotesk",
    "Chillax",
    "Comico",
    "Clash Grotesk",
    "General Sans",
    "New Title",
    "Supreme"
  ];

  // String articleFont = "Chillax";
  // double titleFontSize = 20;
  // String titleAlignment = "left";

  // double articleFontSize = 12;
  // String articleAlignment = "left";
  // double articleLineSpacing = 1.5;
  // double articleContentWidth = 5;

  // final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  @override
  Widget build(BuildContext context) {
    //TODO: Settings
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            onTap: () {},
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            selectedTileColor: Colors.grey,
            selectedColor: Colors.grey,
            enableFeedback: true,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 270,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateSetting('surfaceColor', 0xff000000);
                    themeProvider.updateSetting('textColor', 0xffffffff);
                    themeProvider.updateSetting('secondaryColor', 0xff000000);
                    themeProvider.updateSetting('isDarkMode', true);
                    // setState(() {
                    //   themeProvider.theme.surfaceColor = 0xff000000;
                    //   themeProvider.theme.textColor = 0xffffffff;
                    // });
                  },
                  child: Container(
                    decoration: themeProvider.theme.surfaceColor == 0xff000000
                        ? BoxDecoration(
                            border: Border.all(
                              color: Color(themeProvider.theme.textColor),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ThemePreview(
                                theme: AppTheme(
                                  primaryColor:
                                      themeProvider.theme.primaryColor,
                                  secondaryColor: 0xff000000,
                                  surfaceColor: 0xff000000,
                                  textColor: 0xffffffff,
                                  isDark: true,
                                ),
                              ),
                              Container(
                                height: 25,
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  "Ultra Dark",
                                  style: TextStyle(
                                    color: Color(themeProvider.theme.textColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateSetting('surfaceColor', 0xff1f1f1f);
                    themeProvider.updateSetting('textColor', 0xffffffff);
                    themeProvider.updateSetting('secondaryColor', 0xff000000);
                    themeProvider.updateSetting('isDarkMode', true);
                  },
                  child: Container(
                    decoration: themeProvider.theme.surfaceColor == 0xff1f1f1f
                        ? BoxDecoration(
                            border: Border.all(
                              color: Color(themeProvider.theme.textColor),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ThemePreview(
                                theme: AppTheme(
                                  primaryColor:
                                      themeProvider.theme.primaryColor,
                                  secondaryColor: 0xff000000,
                                  surfaceColor: 0xff0f0f0f,
                                  textColor: 0xffffffff,
                                  isDark: true,
                                ),
                              ),
                              Container(
                                height: 25,
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  "Dark",
                                  style: TextStyle(
                                    color: Color(themeProvider.theme.textColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateSetting('surfaceColor', 0xffffffff);
                    themeProvider.updateSetting('textColor', 0xff1f1f1f);
                    themeProvider.updateSetting('secondaryColor', 0xffffffff);
                    themeProvider.updateSetting('isDarkMode', false);

                    // themeProvider.theme.surfaceColor = 0xffffffff;
                  },
                  child: Container(
                    decoration: themeProvider.theme.surfaceColor == 0xffffffff
                        ? BoxDecoration(
                            border: Border.all(
                              color: Color(themeProvider.theme.textColor),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ThemePreview(
                                  theme: AppTheme(
                                primaryColor: themeProvider.theme.primaryColor,
                                secondaryColor: 0xffffffff,
                                surfaceColor: 0xffffffff,
                                textColor: 0xff000000,
                                isDark: false,
                              )),
                              Container(
                                height: 25,
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  "Light",
                                  style: TextStyle(
                                    color: Color(themeProvider.theme.textColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return Scaffold(
                            // extendBodyBehindAppBar: true,
                            appBar: AppBar(
                              backgroundColor:
                                  Color(themeProvider.theme.surfaceColor)
                                      .withAlpha(56),
                              elevation: 0,
                              title: Text(
                                'Custom Theme',
                                style: TextStyle(
                                  color: Color(themeProvider.theme.textColor),
                                ),
                                overflow: TextOverflow.fade,
                              ),
                              flexibleSpace: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 36,
                                    sigmaY: 36,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                            body: CustomThemeSettings(),
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ThemePreview(
                          theme: AppTheme(
                            primaryColor: 0xff0000ff,
                            secondaryColor: 0xff00003b,
                            surfaceColor: 0xff000098,
                            textColor: 0xffffffff,
                            isDark: true,
                          ),
                        ),
                        Container(
                          height: 25,
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            "Custom",
                            style: TextStyle(
                              color: Color(themeProvider.theme.textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 0.1,
            indent: 4,
            endIndent: 4,
            color: Color(themeProvider.theme.textColor),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.paintbrush),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            title: const Text('Accent Color'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateSetting('primaryColor', 0xFFFF2B3A);
                    // themeProvider.theme.primaryColor = 0xFFFF2B3A;
                    // setState(
                    //   () => themeProvider.theme.primaryColor = 0xFFFF2B3A,
                    // );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF2B3A),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.primaryColor == 0xFFFF2B3A
                          ? const Center(
                              widthFactor: 1.5,
                              child: Icon(Icons.check, size: 30),
                            )
                          : Container(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // setState(
                    //   () =>
                    // );
                    themeProvider.updateSetting('primaryColor', 0xff4bf4d9);
                    // themeProvider.theme.primaryColor = 0xff4bf4d9;
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xff4bf4d9),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.primaryColor == 0xff4bf4d9
                          ? const Center(
                              widthFactor: 1.5,
                              child: Icon(Icons.check, size: 30),
                            )
                          : Container(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // setState(
                    // () =>
                    // themeProvider.theme.primaryColor = 0xff0404d9;
                    // );
                    themeProvider.updateSetting('primaryColor', 0xff0404d9);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xff0404d9),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.primaryColor == 0xff0404d9
                          ? const Center(
                              widthFactor: 1.5,
                              child: Icon(Icons.check, size: 30),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color(themeProvider.theme.surfaceColor),
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(5),
                      child: ColorIndicator(
                          // key:
                          width: 40,
                          height: 40,
                          borderRadius: 40,
                          color: Color(themeProvider.theme.primaryColor),
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(themeProvider.theme.primaryColor),
                              title: Text('Colors',
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              width: 40,
                              height: 40,
                              spacing: 0,
                              runSpacing: 0,
                              borderRadius: 0,
                              wheelDiameter: 300,
                              enableOpacity: false,
                              showColorCode: true,
                              colorCodeHasColor: true,
                              pickersEnabled: <ColorPickerType, bool>{
                                ColorPickerType.wheel: true,
                              },
                              copyPasteBehavior:
                                  const ColorPickerCopyPasteBehavior(
                                copyButton: true,
                                pasteButton: true,
                                longPressMenu: false,
                              ),
                              actionButtons: const ColorPickerActionButtons(
                                okButton: true,
                                closeButton: true,
                                dialogActionButtons: false,
                              ),
                              constraints: const BoxConstraints(
                                  minHeight: 480, minWidth: 300, maxWidth: 300),
                            );
                            // themeProvider.theme.primaryColor = newColor.value;
                            themeProvider.updateSetting(
                                'primaryColor', newColor.value);
                          }),
                    ),
                    // Container(
                    //   width: 40,
                    //   margin: const EdgeInsets.all(5),
                    //   child: Icon(
                    //     Icons.color_lens,
                    //     size: 40,
                    //     color: Color(themeProvider.theme.textColor),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 0.1,
            indent: 4,
            endIndent: 4,
            color: Color(themeProvider.theme.textColor),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.textbox),
            title: const Text('Fonts'),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "TITLE",
              style: TextStyle(
                color: Color(themeProvider.theme.textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(CupertinoIcons.textformat_size,
                          color: Color(themeProvider.theme.textColor)),
                    ),
                    Text(
                      "Font Size",
                      style: TextStyle(
                        color: Color(themeProvider.theme.textColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                      // color: Color.fromARGB(28, 253, 253, 253),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.remove,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.titleFontSize =
                                  double.parse((themeProvider
                                              .fontSettings.titleFontSize -
                                          0.5)
                                      .toStringAsFixed(2));
                            },
                          );
                          // // await asyncPrefs.setDouble('titleFontSize',
                          //     themeProvider.fontSettings.titleFontSize);
                        },
                      ),
                      SizedBox(
                        child: Text(
                          themeProvider.fontSettings.titleFontSize.toString(),
                          style: TextStyle(
                            color: Color(themeProvider.theme.textColor),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            themeProvider.fontSettings.titleFontSize =
                                double.parse(
                                    (themeProvider.fontSettings.titleFontSize +
                                            0.5)
                                        .toStringAsFixed(2));
                            // lineSpacing += 0.2;
                          });
                          // // await asyncPrefs.setDouble('titleFontSize',
                          //     themeProvider.fontSettings.titleFontSize);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    CupertinoIcons.textformat,
                    color: Color(themeProvider.theme.textColor),
                  ),
                ),
                Text(
                  "Text Alignement",
                  style: TextStyle(
                    color: Color(themeProvider.theme.textColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: themeProvider.fontSettings.titleAlignment ==
                          TextAlign.left
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.titleAlignment =
                            TextAlign.left;
                      });
                      // // await asyncPrefs.setString('titleAlignment', 'left');
                    },
                    child: const Icon(
                      CupertinoIcons.text_alignleft,
                      // color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: themeProvider.fontSettings.titleAlignment ==
                          TextAlign.center
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.titleAlignment =
                            TextAlign.center;
                        // titleTextAlignment =
                        //     TextAlign.center;
                      });
                      // // await asyncPrefs.setString('titleAlignment', 'center');
                    },
                    child: const Icon(
                      CupertinoIcons.text_aligncenter,
                      // color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: themeProvider.fontSettings.titleAlignment ==
                          TextAlign.right
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.titleAlignment =
                            TextAlign.right;
                        // titleTextAlignment =
                        //     TextAlign.right;
                      });
                      // // await asyncPrefs.setString('titleAlignment', 'right');
                    },
                    child: const Icon(
                      CupertinoIcons.text_alignright,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: Color(themeProvider.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "ARTICLE",
              style: TextStyle(
                color: Color(themeProvider.theme.textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(CupertinoIcons.textformat_size,
                          color: Color(themeProvider.theme.textColor)),
                    ),
                    Text(
                      "Font Size",
                      style: TextStyle(
                        color: Color(themeProvider.theme.textColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                      // color: Color.fromARGB(28, 253, 253, 253),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.remove,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleFontSize =
                                  double.parse((themeProvider
                                              .fontSettings.articleFontSize -
                                          0.5)
                                      .toStringAsFixed(2));
                            },
                          );
                          // // await asyncPrefs.setDouble('articleFontSize',
                          // themeProvider.fontSettings.articleFontSize);
                        },
                      ),
                      SizedBox(
                          child: Text(
                        themeProvider.fontSettings.articleFontSize.toString(),
                        style: TextStyle(
                          color: Color(themeProvider.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleFontSize =
                                  double.parse((themeProvider
                                              .fontSettings.articleFontSize +
                                          0.5)
                                      .toStringAsFixed(2));
                            },
                          );
                          // // await asyncPrefs.setDouble('articleFontSize',
                          //     themeProvider.fontSettings.articleFontSize);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    CupertinoIcons.textformat,
                    color: Color(themeProvider.theme.textColor),
                  ),
                ),
                Text(
                  "Text Alignement",
                  style: TextStyle(
                    color: Color(themeProvider.theme.textColor),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: themeProvider.fontSettings.articleAlignment ==
                          TextAlign.left
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.articleAlignment =
                            TextAlign.left;
                        // titleTextAlignment =
                        //     TextAlign.right;
                      });
                      // await asyncPrefs.setString('articleAlignment', 'left');
                    },
                    child: const Icon(
                      CupertinoIcons.text_alignleft,
                      // color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: themeProvider.fontSettings.articleAlignment ==
                          TextAlign.center
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.articleAlignment =
                            TextAlign.center;
                      });
                      // await asyncPrefs.setString('articleAlignment', 'center');
                    },
                    child: const Icon(
                      CupertinoIcons.text_aligncenter,
                      // color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  decoration: themeProvider.fontSettings.articleAlignment ==
                          TextAlign.right
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 0.5,
                            color: Color(themeProvider.theme.primaryColor),
                          ),
                        )
                      : null,
                  child: CupertinoButton(
                    onPressed: () async {
                      setState(() {
                        themeProvider.fontSettings.articleAlignment =
                            TextAlign.right;
                        // titleTextAlignment =
                        //     TextAlign.right;
                      });
                      // await asyncPrefs.setString('articleAlignment', 'right');
                    },
                    child: const Icon(
                      CupertinoIcons.text_alignright,
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.height,
                        color: Color(themeProvider.theme.textColor),
                      ),
                    ),
                    Text(
                      "Line Spacing",
                      style: TextStyle(
                        color: Color(themeProvider.theme.textColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                      // color: Color.fromARGB(28, 253, 253, 253),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.remove,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleLineSpacing =
                                  double.parse((themeProvider
                                              .fontSettings.articleLineSpacing -
                                          0.1)
                                      .toStringAsFixed(2));
                            },
                          );
                          // await asyncPrefs.setDouble('articleLineSpacing',
                          // themeProvider.fontSettings.articleLineSpacing);
                        },
                      ),
                      SizedBox(
                          child: Text(
                        (themeProvider.fontSettings.articleLineSpacing)
                            .toStringAsFixed(2),
                        style: TextStyle(
                          color: Color(themeProvider.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleLineSpacing =
                                  double.parse((themeProvider
                                              .fontSettings.articleLineSpacing +
                                          0.1)
                                      .toStringAsFixed(2));
                            },
                          );
                          // await asyncPrefs.setDouble('articleLineSpacing',
                          // themeProvider.fontSettings.articleLineSpacing);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.width_wide,
                          color: Color(themeProvider.theme.textColor)),
                    ),
                    Text(
                      "Content Width",
                      style: TextStyle(
                        color: Color(themeProvider.theme.textColor),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                      // color: Color.fromARGB(28, 253, 253, 253),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.remove,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleContentWidth =
                                  double.parse((themeProvider.fontSettings
                                              .articleContentWidth -
                                          5)
                                      .toStringAsFixed(2));
                            },
                          );
                          // await asyncPrefs.setDouble('articleContentWidth',
                          // themeProvider.fontSettings.articleContentWidth);
                        },
                      ),
                      SizedBox(
                          child: Text(
                        (themeProvider.fontSettings.articleContentWidth)
                            .toStringAsFixed(2),
                        style: TextStyle(
                          color: Color(themeProvider.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              themeProvider.fontSettings.articleContentWidth =
                                  double.parse((themeProvider.fontSettings
                                              .articleContentWidth +
                                          5)
                                      .toStringAsFixed(2));
                            },
                          );
                          // await asyncPrefs.setDouble('articleContentWidth',
                          // themeProvider.fontSettings.articleContentWidth);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 5,
            thickness: 0.1,
            indent: 20,
            endIndent: 20,
            color: Color(themeProvider.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "FONTS",
              style: TextStyle(
                color: Color(themeProvider.theme.textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(8), // First column width
                1: FlexColumnWidth(2), // Second column width
              },
              children: [
                // Header row
                TableRow(
                  decoration: const BoxDecoration(color: Colors.grey),
                  children: [
                    Container(),
                    Container(),
                  ],
                ),
                ...List.generate(
                  fonts.length,
                  (index) => TableRow(
                    // alignment: Alignment.centerLeft,
                    // padding: const EdgeInsets.all(10),
                    children: [
                      TableCell(
                        child: GestureDetector(
                          onTap: () async {
                            setState(
                              () {
                                themeProvider.fontSettings.articleFont =
                                    fonts[index];
                                // fontFamily = fonts[index];
                              },
                            );
                            // await asyncPrefs.setString('articleFont',
                            // themeProvider.fontSettings.articleFont);
                          },
                          child: Text(
                            fonts[index],
                            style: TextStyle(
                              fontFamily: fonts[index],
                              fontSize: 20,
                              color: Color(themeProvider.theme.textColor),
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        child: GestureDetector(
                          onTap: () async {
                            setState(
                              () {
                                themeProvider.fontSettings.articleFont =
                                    fonts[index];
                                // fontFamily = fonts[index];
                              },
                            );
                            // await asyncPrefs.setString('articleFont',
                            // themeProvider.fontSettings.articleFont);
                          },
                          child: themeProvider.fontSettings.articleFont ==
                                  fonts[index]
                              ? const Icon(Icons.check)
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
