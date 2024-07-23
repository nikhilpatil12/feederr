import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  LoadingWidgetState createState() => LoadingWidgetState();
}

class LoadingWidgetState extends State<LoadingWidget> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      //TODO: Loading status: Downloading images, fetching feeds, etc
      child: Text("TODO"),
    );
  }
}
