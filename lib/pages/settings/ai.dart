import 'dart:developer';
import 'dart:ui';

import 'package:feederr/models/app_theme.dart';
import 'package:feederr/pages/settings/custom_theme.dart';
import 'package:feederr/utils/providers/apiprovider.dart';
import 'package:feederr/utils/providers/themeprovider.dart';
import 'package:feederr/widgets/theme_preview.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AISettings extends StatefulWidget {
  const AISettings({
    super.key,
  });

  @override
  AISettingsState createState() => AISettingsState();
}

class AISettingsState extends State<AISettings> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (_, themeProvider, __) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('OpenAI API Key'),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            selectedTileColor: Colors.grey,
            selectedColor: Colors.grey,
            enableFeedback: true,
          ),
          Consumer<ApiProvider>(builder: (_, apiProvider, __) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 270,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    CupertinoTextField(
                      obscureText: true,
                      focusNode: FocusNode(),
                      style: TextStyle(
                          color: Color(themeProvider.theme.textColor)),
                      controller: _controller,
                      onSubmitted: (String value) async {
                        log(value);
                        await apiProvider.updateApiKey(value);
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CupertinoButton.filled(
                        child: Text(
                          "Save",
                          style: TextStyle(
                            color: Color(themeProvider.theme.textColor),
                          ),
                        ),
                        onPressed: () async {
                          var value = _controller.text;
                          log(value);
                          await apiProvider.updateApiKey(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          // SegmentedButton(segments: segments, selected: selected)
        ],
      );
    });
  }
}
