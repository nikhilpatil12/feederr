import 'package:feederr/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/widgets/theme_preview.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class AppearanceSettings extends StatefulWidget {
  const AppearanceSettings({super.key, required this.theme});
  final AppTheme theme;
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
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  @override
  Widget build(BuildContext context) {
    //TODO: Settings
    return Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Theme'),
            onTap: () {},
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            selectedTileColor: Colors.grey,
            selectedColor: Colors.grey,
            enableFeedback: true,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 268,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () async {
                    await asyncPrefs.setInt('surfaceColor', 0xff1f1f1f);
                    await asyncPrefs.setInt('textColor', 0xffffffff);
                    MyApp.updateTheme(context);
                  },
                  child: Container(
                    decoration: widget.theme.surfaceColor == 0xff1f1f1f
                        ? BoxDecoration(
                            border: Border.all(
                              color: Color(widget.theme.textColor),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ThemePreview(
                                theme: AppTheme(
                                  primaryColor: widget.theme.primaryColor,
                                  secondaryColor: 0xff3b3b3b,
                                  surfaceColor: 0xff0f0f0f,
                                  textColor: 0xffffffff,
                                  textHighlightColor: 0xff0000ff,
                                ),
                              ),
                              Container(
                                height: 25,
                                padding: EdgeInsets.all(2),
                                child: Text(
                                  "Dark",
                                  style: TextStyle(
                                    color: Color(widget.theme.textColor),
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
                    await asyncPrefs.setInt('surfaceColor', 0xffffffff);
                    await asyncPrefs.setInt('textColor', 0xff1f1f1f);

                    MyApp.updateTheme(context);
                    // widget.theme.surfaceColor = 0xffffffff;
                  },
                  child: Container(
                    decoration: widget.theme.surfaceColor == 0xffffffff
                        ? BoxDecoration(
                            border: Border.all(
                              color: Color(widget.theme.textColor),
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              ThemePreview(
                                  theme: AppTheme(
                                primaryColor: widget.theme.primaryColor,
                                secondaryColor: 0xff3b3b3b,
                                surfaceColor: 0xffffffff,
                                textColor: 0xff000000,
                                textHighlightColor: 0xff0000ff,
                              )),
                              Container(
                                height: 25,
                                padding: EdgeInsets.all(2),
                                child: Text(
                                  "Light",
                                  style: TextStyle(
                                    color: Color(widget.theme.textColor),
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
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ThemePreview(
                        theme: AppTheme(
                          primaryColor: 0xff1f1f1f,
                          secondaryColor: 0xff3b3b3b,
                          surfaceColor: 0xff00ffff,
                          textColor: 0xffffffff,
                          textHighlightColor: 0xff0000ff,
                        ),
                      ),
                      Container(
                        height: 25,
                        padding: EdgeInsets.all(2),
                        child: Text(
                          "Custom",
                          style: TextStyle(
                            color: Color(widget.theme.textColor),
                          ),
                        ),
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
            indent: 4,
            endIndent: 4,
            color: Color(widget.theme.textColor),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.paintbrush),
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
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
                    await asyncPrefs.setInt('primaryColor', 0xff4b0409);
                    // widget.theme.primaryColor = 0xff4b0409;
                    MyApp.updateTheme(context);
                  },
                  child: Container(
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xff4b0409),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(5),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await asyncPrefs.setInt('primaryColor', 0xff4bf4d9);
                    // widget.theme.primaryColor = 0xff4bf4d9;
                    MyApp.updateTheme(context);
                  },
                  child: Container(
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xff4bf4d9),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(5),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await asyncPrefs.setInt('primaryColor', 0xff0404d9);
                    // widget.theme.primaryColor = 0xff0404d9;
                    MyApp.updateTheme(context);
                  },
                  child: Container(
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xff0404d9),
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(5),
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color(widget.theme.surfaceColor),
                        shape: BoxShape.circle,
                      ),
                      margin: const EdgeInsets.all(5),
                      child: ColorIndicator(
                          // key:
                          width: 40,
                          height: 40,
                          borderRadius: 40,
                          color: Color(widget.theme.primaryColor),
                          elevation: 0,
                          onSelectFocus: false,
                          onSelect: () async {
                            // Wait for the dialog to return color selection result.
                            final Color newColor = await showColorPickerDialog(
                              // The dialog needs a context, we pass it in.
                              context,
                              // We use the dialogSelectColor, as its starting color.
                              Color(widget.theme.primaryColor),
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
                                copyButton: false,
                                pasteButton: false,
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
                            // We update the dialogSelectColor, to the returned result
                            // color. If the dialog was dismissed it actually returns
                            // the color we started with. The extra update for that
                            // below does not really matter, but if you want you can
                            // check if they are equal and skip the update below.
                            // setState(() {
                            // print(widget.theme.primaryColor);
                            widget.theme.primaryColor = newColor.value;
                            asyncPrefs.setInt('primaryColor', newColor.value);
                            MyApp.updateTheme(context);
                            // });
                          }),
                    ),
                    Container(
                      width: 40,
                      margin: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.color_lens,
                        size: 40,
                        color: Color(widget.theme.textColor),
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
            color: Color(widget.theme.textColor),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.textbox),
            title: const Text('Fonts'),
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "TITLE",
              style: TextStyle(
                color: Color(widget.theme.textColor),
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
                          color: Color(widget.theme.textColor)),
                    ),
                    Text(
                      "Font Size",
                      style: TextStyle(
                        color: Color(widget.theme.textColor),
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
                        onPressed: () => {
                          setState(
                            () {
                              // if ((lineSpacing - 0.2) > 1.5) {
                              //   lineSpacing -= 0.2;
                              // }
                            },
                          ),
                        },
                      ),
                      SizedBox(
                        child: Text(
                          "10",
                          style: TextStyle(
                            color: Color(widget.theme.textColor),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () => {
                          setState(
                            () {
                              // lineSpacing += 0.2;
                            },
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    CupertinoIcons.textformat,
                    color: Color(widget.theme.textColor),
                  ),
                ),
                Text(
                  "Text Alignement",
                  style: TextStyle(
                    color: Color(widget.theme.textColor),
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
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.left;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_alignleft,
                    // color: Colors.white,
                  ),
                ),
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.center;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_aligncenter,
                    // color: Colors.white,
                  ),
                ),
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.right;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_alignright,
                    // color: Colors.white,
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
            color: Color(widget.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "ARTICLE",
              style: TextStyle(
                color: Color(widget.theme.textColor),
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
                      padding: EdgeInsets.all(10),
                      child: Icon(CupertinoIcons.textformat_size,
                          color: Color(widget.theme.textColor)),
                    ),
                    Text(
                      "Font Size",
                      style: TextStyle(
                        color: Color(widget.theme.textColor),
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
                        onPressed: () => {
                          setState(
                            () {
                              // if ((lineSpacing - 0.2) > 1.5) {
                              //   lineSpacing -= 0.2;
                              // }
                            },
                          ),
                        },
                      ),
                      SizedBox(
                          child: Text(
                        "10",
                        style: TextStyle(
                          color: Color(widget.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () => {
                          setState(
                            () {
                              // lineSpacing += 0.2;
                            },
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    CupertinoIcons.textformat,
                    color: Color(widget.theme.textColor),
                  ),
                ),
                Text(
                  "Text Alignement",
                  style: TextStyle(
                    color: Color(widget.theme.textColor),
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
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.left;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_alignleft,
                    // color: Colors.white,
                  ),
                ),
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.center;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_aligncenter,
                    // color: Colors.white,
                  ),
                ),
                CupertinoButton(
                  onPressed: () => {
                    setState(() {
                      // titleTextAlignment =
                      //     TextAlign.right;
                    })
                  },
                  child: const Icon(
                    CupertinoIcons.text_alignright,
                    // color: Colors.white,
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
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.height,
                        color: Color(widget.theme.textColor),
                      ),
                    ),
                    Text(
                      "Line Spacing",
                      style: TextStyle(
                        color: Color(widget.theme.textColor),
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
                        onPressed: () => {
                          setState(
                            () {
                              // if ((lineSpacing - 0.2) > 1.5) {
                              //   lineSpacing -= 0.2;
                              // }
                            },
                          ),
                        },
                      ),
                      SizedBox(
                          child: Text(
                        "10",
                        style: TextStyle(
                          color: Color(widget.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () => {
                          setState(
                            () {
                              // lineSpacing += 0.2;
                            },
                          ),
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
                          color: Color(widget.theme.textColor)),
                    ),
                    Text(
                      "Content Width",
                      style: TextStyle(
                        color: Color(widget.theme.textColor),
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
                        onPressed: () => {
                          setState(
                            () {
                              // contentWidth += 5;
                            },
                          ),
                        },
                      ),
                      SizedBox(
                          child: Text(
                        "10",
                        style: TextStyle(
                          color: Color(widget.theme.textColor),
                        ),
                      )),
                      CupertinoButton(
                        padding: const EdgeInsets.all(0),
                        child: const Icon(
                          Icons.add,
                          // color: Colors.white,
                        ),
                        onPressed: () => {
                          setState(
                            () {
                              // if (contentWidth >= 5) {
                              //   contentWidth -= 5;
                              // }
                            },
                          ),
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
            color: Color(widget.theme.textColor),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "FONTS",
              style: TextStyle(
                color: Color(widget.theme.textColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                ...List.generate(
                  fonts.length,
                  (index) => Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () => setState(
                        () {
                          // fontFamily = fonts[index];
                        },
                      ),
                      child: Text(
                        fonts[index],
                        style: TextStyle(
                          fontFamily: fonts[index],
                          // fontSize: articleTextSize,,
                          color: Color(widget.theme.textColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // CupertinoFormSection(
          //   backgroundColor: Color(widget.theme.surfaceColor),
          //   header: const Text("TITLE"),
          //   children: [
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           const Row(
          //             children: [
          //               Padding(
          //                 padding: EdgeInsets.all(10),
          //                 child: Icon(
          //                   CupertinoIcons.textformat_size,
          //                 ),
          //               ),
          //               Text("Font Size"),
          //             ],
          //           ),
          //           Container(
          //             decoration: const BoxDecoration(
          //                 // color: Color.fromARGB(28, 253, 253, 253),
          //                 borderRadius: BorderRadius.all(Radius.circular(10))),
          //             child: Row(
          //               children: [
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.remove,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // if ((lineSpacing - 0.2) > 1.5) {
          //                         //   lineSpacing -= 0.2;
          //                         // }
          //                       },
          //                     ),
          //                   },
          //                 ),
          //                 SizedBox(child: Text("10")),
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.add,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // lineSpacing += 0.2;
          //                       },
          //                     ),
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // titleTextAlignment =
          //                 //     TextAlign.left;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_alignleft,
          //               // color: Colors.white,
          //             ),
          //           ),
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // titleTextAlignment =
          //                 //     TextAlign.center;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_aligncenter,
          //               // color: Colors.white,
          //             ),
          //           ),
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // titleTextAlignment =
          //                 //     TextAlign.right;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_alignright,
          //               // color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // CupertinoFormSection(
          //   header: const Text("ARTICLE"),
          //   children: [
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceAround,
          //         children: [
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // articleTextSize -= 0.5;
          //               })
          //             },
          //             child: const Icon(
          //               Icons.text_decrease,
          //               // color: Colors.white,
          //             ),
          //           ),
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // articleTextSize += 0.5;
          //               })
          //             },
          //             child: const Icon(
          //               Icons.text_increase,
          //               // color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // articleTextAlignment =
          //                 //     TextAlign.left;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_alignleft,
          //               // color: Colors.white,
          //             ),
          //           ),
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // articleTextAlignment =
          //                 //     TextAlign.center;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_aligncenter,
          //               // color: Colors.white,
          //             ),
          //           ),
          //           CupertinoButton(
          //             onPressed: () => {
          //               setState(() {
          //                 // articleTextAlignment =
          //                 //     TextAlign.right;
          //               })
          //             },
          //             child: const Icon(
          //               CupertinoIcons.text_alignright,
          //               // color: Colors.white,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           const Row(
          //             children: [
          //               Padding(
          //                 padding: EdgeInsets.all(10),
          //                 child: Icon(Icons.height),
          //               ),
          //               Text("Line Spacing"),
          //             ],
          //           ),
          //           Container(
          //             decoration: const BoxDecoration(
          //                 // color: Color.fromARGB(28, 253, 253, 253),
          //                 borderRadius: BorderRadius.all(Radius.circular(10))),
          //             child: Row(
          //               children: [
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.remove,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // if ((lineSpacing - 0.2) > 1.5) {
          //                         //   lineSpacing -= 0.2;
          //                         // }
          //                       },
          //                     ),
          //                   },
          //                 ),
          //                 SizedBox(child: Text("10")),
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.add,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // lineSpacing += 0.2;
          //                       },
          //                     ),
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     CupertinoFormRow(
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           const Row(
          //             children: [
          //               Padding(
          //                 padding: EdgeInsets.all(10),
          //                 child: Icon(Icons.width_wide),
          //               ),
          //               Text("Content Width"),
          //             ],
          //           ),
          //           Container(
          //             decoration: const BoxDecoration(
          //                 // color: Color.fromARGB(28, 253, 253, 253),
          //                 borderRadius: BorderRadius.all(Radius.circular(10))),
          //             child: Row(
          //               children: [
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.remove,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // contentWidth += 5;
          //                       },
          //                     ),
          //                   },
          //                 ),
          //                 SizedBox(child: Text("10")),
          //                 CupertinoButton(
          //                   padding: const EdgeInsets.all(0),
          //                   child: const Icon(
          //                     Icons.add,
          //                     // color: Colors.white,
          //                   ),
          //                   onPressed: () => {
          //                     setState(
          //                       () {
          //                         // if (contentWidth >= 5) {
          //                         //   contentWidth -= 5;
          //                         // }
          //                       },
          //                     ),
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // CupertinoFormSection(
          //   header: const Text("FONTS"),
          //   children: [
          //     ...List.generate(
          //       fonts.length,
          //       (index) => Container(
          //         alignment: Alignment.centerLeft,
          //         padding: const EdgeInsets.all(20),
          //         child: GestureDetector(
          //           onTap: () => setState(
          //             () {
          //               // fontFamily = fonts[index];
          //             },
          //           ),
          //           child: Text(
          //             fonts[index],
          //             style: TextStyle(
          //               fontFamily: fonts[index],
          //               // fontSize: articleTextSize,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          // ListTile(
          //   leading: Icon(Icons.web_stories),
          //   title: Text('Layout'),
          //   textColor: Color(widget.theme.textColor),
          //   onTap: () {},
          // ),
        ],
      ),
    );
    // return Text("dataaaa");
  }
}
