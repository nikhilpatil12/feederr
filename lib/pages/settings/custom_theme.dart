import 'dart:developer';

import 'package:blazefeeds/models/app_theme.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:blazefeeds/utils/utils.dart';
import 'package:blazefeeds/widgets/theme_preview.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomThemeSettings extends StatefulWidget {
  const CustomThemeSettings({
    super.key,
  });

  @override
  CustomThemeSettingsState createState() => CustomThemeSettingsState();
}

class CustomThemeSettingsState extends State<CustomThemeSettings> {
  List<String> fonts = [];
  late final AppUtils utils;
  @override
  void initState() {
    super.initState();
    utils = AppUtils(); // Using singleton instance
    initializeFonts();
  }

  Future<void> initializeFonts() async {
    try {
      List<String> loadedFonts = await utils.loadFonts();
      setState(() {
        fonts = loadedFonts; // Update UI after loading fonts
      });
    } catch (e) {
      // Handle the exception, e.g., log it or show a message to the user
      fonts = [];
      log('Failed to load fonts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (_, themeProvider, __) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme Preview'),
            onTap: () {},
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            selectedTileColor: Colors.grey,
            selectedColor: Colors.grey,
            enableFeedback: true,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 268,
            child: SizedBox(
              child: Center(
                child: ThemePreview(
                  theme: AppTheme(
                    primaryColor: themeProvider.theme.primaryColor,
                    secondaryColor: themeProvider.theme.secondaryColor,
                    surfaceColor: themeProvider.theme.surfaceColor,
                    textColor: themeProvider.theme.textColor,
                    // isDark: true,
                  ),
                ),
              ),
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
                    themeProvider.updateTheme('primaryColor', 0xFFFF2B3A);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xFFFF2B3A),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.primaryColor == 0xFFFF2B3A
                          ? Center(
                              widthFactor: 1.5,
                              child: const Icon(
                                Icons.check,
                                size: 30,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateTheme('primaryColor', 0xff4bf4d9);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
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
                    themeProvider.updateTheme('primaryColor', 0xff0404d9);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
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
                          width: 40,
                          height: 40,
                          borderRadius: 40,
                          color: Color(themeProvider.theme.primaryColor),
                          // color: Colors.transparent,
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(themeProvider.theme.primaryColor),
                              title: Text('Colors', style: Theme.of(context).textTheme.titleLarge),
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
                              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
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
                            themeProvider.updateTheme('primaryColor', newColor.value32bit);
                          }),
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.color_lens_outlined,
                          size: 40,
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
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
            leading: const Icon(CupertinoIcons.paintbrush),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            title: const Text('Surface Color'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateTheme('surfaceColor', 0xFFFFFFFF);
                    // MyApp.updateTheme(context);
                    // themeProvider.theme.surfaceColor = 0xFFFF2B3A;
                    // setState(
                    //   () => themeProvider.theme.surfaceColor = 0xFFFF2B3A,
                    // );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.surfaceColor == 0xFFFFFFFF
                          ? Center(
                              widthFactor: 1.5,
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Color(themeProvider.theme.textColor),
                              ),
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
                    themeProvider.updateTheme('surfaceColor', 0xff1f1f1f);
                    // themeProvider.theme.surfaceColor = 0xff4bf4d9;
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xff1f1f1f),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.surfaceColor == 0xff1f1f1f
                          ? Center(
                              widthFactor: 1.5,
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Color(themeProvider.theme.textColor),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // setState(
                    // () =>
                    // themeProvider.theme.surfaceColor = 0xff0404d9;
                    // );
                    themeProvider.updateTheme('surfaceColor', 0xff000000);
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color.fromARGB(255, 0, 0, 0),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.surfaceColor == 0xff000000
                          ? Center(
                              widthFactor: 1.5,
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Color(themeProvider.theme.textColor),
                              ),
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
                          color: Color(themeProvider.theme.surfaceColor),
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(themeProvider.theme.surfaceColor),
                              title: Text('Colors', style: Theme.of(context).textTheme.titleLarge),
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
                              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
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
                            // themeProvider.theme.surfaceColor = newColor.value;
                            themeProvider.updateTheme('surfaceColor', newColor.value);
                            // MyApp.updateTheme(context);
                          }),
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.color_lens_outlined,
                          size: 40,
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
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
            leading: const Icon(CupertinoIcons.paintbrush),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            title: const Text('Text Color'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateTheme('textColor', 0xFFFFFFFF);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xFFFFFFFF),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.textColor == 0xFFFFFFFF
                          ? Center(
                              widthFactor: 1.5,
                              child: Icon(
                                Icons.check,
                                size: 30,
                                color: Color(themeProvider.theme.secondaryColor),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // setState(
                    // () =>
                    // themeProvider.theme.textColor = 0xff0404d9;
                    // );
                    themeProvider.updateTheme('textColor', 0xff000000);
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xff000000),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.textColor == 0xff000000
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
                    themeProvider.updateTheme('textColor', 0xff4bf4d9);
                    // themeProvider.theme.textColor = 0xff4bf4d9;
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xff4bf4d9),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.textColor == 0xff4bf4d9
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
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(5),
                      child: ColorIndicator(
                          // key:
                          width: 40,
                          height: 40,
                          borderRadius: 40,
                          color: Color(themeProvider.theme.textColor),
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(themeProvider.theme.textColor),
                              title: Text('Colors', style: Theme.of(context).textTheme.titleLarge),
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
                              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
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
                            // themeProvider.theme.textColor = newColor.value;
                            themeProvider.updateTheme('textColor', newColor.value);
                            // MyApp.updateTheme(context);
                          }),
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.color_lens_outlined,
                          size: 40,
                          color: Color(themeProvider.theme.secondaryColor),
                        ),
                      ),
                    ),
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
            leading: const Icon(CupertinoIcons.paintbrush),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            title: const Text('Secondary Color'),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    themeProvider.updateTheme('secondaryColor', 0xFFFF2B3A);
                    // MyApp.updateTheme(context);
                    // themeProvider.theme.secondaryColor = 0xFFFF2B3A;
                    // setState(
                    //   () => themeProvider.theme.secondaryColor = 0xFFFF2B3A,
                    // );
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xFFFF2B3A),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.secondaryColor == 0xFFFF2B3A
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
                    themeProvider.updateTheme('secondaryColor', 0xff4bf4d9);
                    // themeProvider.theme.secondaryColor = 0xff4bf4d9;
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xff4bf4d9),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.secondaryColor == 0xff4bf4d9
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
                    // themeProvider.theme.secondaryColor = 0xff0404d9;
                    // );
                    themeProvider.updateTheme('secondaryColor', 0xff0404d9);
                    // MyApp.updateTheme(context);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          color: Color(0xff0404d9),
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.all(5),
                      ),
                      themeProvider.theme.secondaryColor == 0xff0404d9
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
                          color: Color(themeProvider.theme.secondaryColor),
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(themeProvider.theme.secondaryColor),
                              title: Text('Colors', style: Theme.of(context).textTheme.titleLarge),
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
                              copyPasteBehavior: const ColorPickerCopyPasteBehavior(
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
                            // themeProvider.theme.secondaryColor = newColor.value;
                            themeProvider.updateTheme('secondaryColor', newColor.value);
                            // MyApp.updateTheme(context);
                          }),
                    ),
                    IgnorePointer(
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.color_lens_outlined,
                          size: 40,
                          color: Color(themeProvider.theme.textColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // MergeSemantics(
          //   child: CupertinoListTile(
          //     title: const Text('Lights'),
          //     trailing: CupertinoSwitch(
          //       value: themeProvider.theme.isDark,
          //       onChanged: (bool value) {
          //         themeProvider.updateSetting('isDarkMode', value);
          //       },
          //     ),
          //     // onTap: () { setState(() { _lights = !_lights; }); },
          //   ),
          // ),
          // ListTile(
          //   leading: const Icon(CupertinoIcons.sun_haze),
          //   iconColor: Color(themeProvider.theme.textColor),
          //   textColor: Color(themeProvider.theme.textColor),
          //   title: const Text('Dark Mode'),
          //   trailing: Switch(
          //       value: themeProvider.theme.isDark,
          //       onChanged: (v) {
          //         themeProvider.updateTheme('isDarkMode', v);
          //       }),
          // ),

          // SegmentedButton(segments: segments, selected: selected)
        ],
      );
    });
  }
}
