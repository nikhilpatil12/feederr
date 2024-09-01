import 'package:feederr/pages/add_server.dart';
import 'package:feederr/pages/settings/appearance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

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
            leading: Icon(CupertinoIcons.person),
            title: Text('Accounts'),
            trailing: Icon(CupertinoIcons.right_chevron),
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
            leading: Icon(CupertinoIcons.paintbrush),
            title: Text('Appearance'),
            trailing: Icon(CupertinoIcons.right_chevron),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Appearance'),
                      ),
                      body: const AppearanceSettings(),
                    );
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(CupertinoIcons.cloud),
            title: Text('Backup'),
            trailing: Icon(CupertinoIcons.right_chevron),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(CupertinoIcons.list_dash),
            title: Text('List Styles'),
            trailing: Icon(CupertinoIcons.right_chevron),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            trailing: Icon(CupertinoIcons.right_chevron),
            onTap: () {},
          ),
        ],
      ),
    );
    // return Text("dataaaa");
  }
}
