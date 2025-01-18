import 'dart:ui';

import 'package:feederr/models/font_settings.dart';
import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/settings/appearance.dart';
import 'package:feederr/utils/apiservice.dart';
import 'package:feederr/utils/dbhelper.dart';
import 'package:feederr/utils/themeprovider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({
    super.key,
    required this.databaseService,
    required this.api,
  });
  final DatabaseService databaseService;
  final APIService api;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    //TODO: Settings
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(CupertinoIcons.person),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            title: const Text('Accounts'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      // extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        backgroundColor: Color(themeProvider.theme.surfaceColor)
                            .withAlpha(56),
                        elevation: 0,
                        title: Text(
                          'Accounts',
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
                      body: ServerList(
                        databaseService: widget.databaseService,
                        api: widget.api,
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.paintbrush),
            title: const Text('Appearance'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      // extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        backgroundColor: Color(themeProvider.theme.surfaceColor)
                            .withAlpha(56),
                        elevation: 0,
                        title: Text(
                          'Appearance',
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
                      body: AppearanceSettings(),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.cloud),
            title: const Text('Backup'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.list_dash),
            title: const Text('List Styles'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(themeProvider.theme.textColor),
            textColor: Color(themeProvider.theme.textColor),
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      );
    });
    // return Text("dataaaa");
  }
}
