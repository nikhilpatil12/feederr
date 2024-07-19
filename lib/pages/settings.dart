import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Album'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Album'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
      ],
    );
    // return Text("dataaaa");
  }
}
