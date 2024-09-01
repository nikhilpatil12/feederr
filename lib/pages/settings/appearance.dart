import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/widgets/theme_preview.dart';
import 'package:feederr/models/app_theme.dart';

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
  @override
  Widget build(BuildContext context) {
    //TODO: Settings
    return Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Colors'),
            onTap: () {},
            selectedTileColor: Colors.grey,
            selectedColor: Colors.grey,
            enableFeedback: true,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 260,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ThemePreview(
                        theme: AppTheme(
                          primaryColor: 0xff1f1f1f,
                          secondaryColor: 0xff3b3b3b,
                          accentColor: 0xff4b04d9,
                          textColor: 0xffffffff,
                          textHighlightColor: 0xff0000ff,
                        ),
                      ),
                      Container(
                        height: 20,
                        padding: EdgeInsets.all(2),
                        child: Text("Dark"),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      ThemePreview(
                          theme: AppTheme(
                        primaryColor: 0xffffffff,
                        secondaryColor: 0xff3b3b3b,
                        accentColor: 0xff4b04d9,
                        textColor: 0xff000000,
                        textHighlightColor: 0xff0000ff,
                      )),
                      Container(
                        height: 20,
                        padding: EdgeInsets.all(2),
                        child: Text("Light"),
                      ),
                    ],
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
                          accentColor: 0xff00ffff,
                          textColor: 0xffffffff,
                          textHighlightColor: 0xff0000ff,
                        ),
                      ),
                      Container(
                        height: 20,
                        padding: EdgeInsets.all(2),
                        child: Text("Custom"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(CupertinoIcons.textbox),
            title: Text('Fonts'),
            onTap: () {},
          ),
          CupertinoFormSection(
            header: const Text("TITLE"),
            children: [
              CupertinoFormRow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // titleTextSize -= 0.5;
                        })
                      },
                      child: const Icon(
                        Icons.text_decrease,
                        color: Colors.white,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // titleTextSize += 0.5;
                        })
                      },
                      child: const Icon(
                        Icons.text_increase,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoFormRow(
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
                        color: Colors.white,
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
                        color: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          CupertinoFormSection(
            header: const Text("ARTICLE"),
            children: [
              CupertinoFormRow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // articleTextSize -= 0.5;
                        })
                      },
                      child: const Icon(
                        Icons.text_decrease,
                        color: Colors.white,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // articleTextSize += 0.5;
                        })
                      },
                      child: const Icon(
                        Icons.text_increase,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoFormRow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // articleTextAlignment =
                          //     TextAlign.left;
                        })
                      },
                      child: const Icon(
                        CupertinoIcons.text_alignleft,
                        color: Colors.white,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // articleTextAlignment =
                          //     TextAlign.center;
                        })
                      },
                      child: const Icon(
                        CupertinoIcons.text_aligncenter,
                        color: Colors.white,
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => {
                        setState(() {
                          // articleTextAlignment =
                          //     TextAlign.right;
                        })
                      },
                      child: const Icon(
                        CupertinoIcons.text_alignright,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoFormRow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.height),
                        ),
                        Text("Line Spacing"),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(28, 253, 253, 253),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
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
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
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
              CupertinoFormRow(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.width_wide),
                        ),
                        Text("Content Width"),
                      ],
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(28, 253, 253, 253),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                            onPressed: () => {
                              setState(
                                () {
                                  // contentWidth += 5;
                                },
                              ),
                            },
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.all(0),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
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
            ],
          ),
          CupertinoFormSection(
            header: const Text("FONTS"),
            children: [
              ...List.generate(
                fonts.length,
                (index) => Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(20),
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
                        // fontSize: articleTextSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            leading: Icon(Icons.web_stories),
            title: Text('Layout'),
            onTap: () {},
          ),
        ],
      ),
    );
    // return Text("dataaaa");
  }
}
