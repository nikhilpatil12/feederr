import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blazefeeds/models/app_theme.dart';
import 'package:flutter/widgets.dart';

class MiniThemePreview extends StatefulWidget {
  const MiniThemePreview({super.key, required this.theme});
  final AppTheme theme;
  @override
  MiniThemePreviewState createState() => MiniThemePreviewState();
}

class MiniThemePreviewState extends State<MiniThemePreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // clipBehavior: Clip.antiAlias,
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Color(
          widget.theme.surfaceColor,
        ),
        border: Border.all(
          color: Color(widget.theme.primaryColor),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
