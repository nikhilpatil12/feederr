import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/settings/appearance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.theme});
  final AppTheme theme;

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    //TODO: Settings
    return Container(
      child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          ListTile(
            leading: const Icon(CupertinoIcons.person),
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            title: const Text('Accounts'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Accounts'),
                      ),
                      body: const ServerList(),
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
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        leading: Container(),
                        flexibleSpace: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                CupertinoButton(
                                  child: const Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.back,
                                      ),
                                      Text('Back')
                                    ],
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop(),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        title: Text(
                          'Appearance',
                          style: TextStyle(
                            color: Color(widget.theme.textColor),
                          ),
                        ),
                      ),
                      body: AppearanceSettings(
                        theme: widget.theme,
                      ),
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
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.list_dash),
            title: const Text('List Styles'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(CupertinoIcons.right_chevron),
            iconColor: Color(widget.theme.textColor),
            textColor: Color(widget.theme.textColor),
            onTap: () {},
          ),
        ],
      ),
    );
    // return Text("dataaaa");
  }
}
