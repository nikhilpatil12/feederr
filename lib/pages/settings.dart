import 'dart:ui';

import 'package:blazefeeds/pages/settings/add_server.dart';
import 'package:blazefeeds/pages/settings/ai.dart';
import 'package:blazefeeds/pages/settings/appearance.dart';
import 'package:blazefeeds/pages/settings/backup.dart';
import 'package:blazefeeds/utils/apiservice.dart';
import 'package:blazefeeds/utils/dbhelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Settings extends StatefulWidget {
  Settings({
    super.key,
  });
  final DatabaseService databaseService = DatabaseService();
  final APIService api = APIService();

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //TODO: Settings
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withAlpha(90),
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.fade,
        ),
        // flexibleSpace: ClipRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(
        //       sigmaX: 36,
        //       sigmaY: 36,
        //     ),
        //     child: Container(
        //       color: Colors.transparent,
        //     ),
        //   ),
        // ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: Icon(
              CupertinoIcons.person,
              size: 40,
            ),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            title: const Text('Accounts',
                style: TextStyle(fontVariations: [FontVariation.weight(500)])),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ServerList();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.paintbrush,
              size: 40,
            ),
            title: const Text('Appearance'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return AppearanceSettings();
                  },
                ),
              );
            },
          ),
          ListTile(
            // contentPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              CupertinoIcons.cloud,
              size: 40,
            ),
            title: const Text('Backup'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return BackupSettings();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.sparkles,
              size: 40,
            ),
            title: const Text('AI Summarization Settings'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      // extendBodyBehindAppBar: true,
                      appBar: AppBar(
                        backgroundColor: theme.colorScheme.surface.withAlpha(56),
                        elevation: 0,
                        title: Text(
                          'Summarization ',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                        // flexibleSpace: ClipRect(
                        //   child: BackdropFilter(
                        //     filter: ImageFilter.blur(
                        //       sigmaX: 36,
                        //       sigmaY: 36,
                        //     ),
                        //     child: Container(
                        //       color: Colors.transparent,
                        //     ),
                        //   ),
                        // ),
                      ),
                      body: AISettings(),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              CupertinoIcons.list_dash,
              size: 40,
            ),
            title: const Text('List Styles'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              size: 40,
            ),
            title: const Text('About'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: theme.colorScheme.onSurface,
            textColor: theme.colorScheme.onSurface,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
    // return Text("dataaaa");
    // });
  }
}
