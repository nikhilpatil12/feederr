import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/models/app_theme.dart';

class ThemePreview extends StatefulWidget {
  const ThemePreview({super.key, required this.theme});
  final AppTheme theme;
  @override
  ThemePreviewState createState() => ThemePreviewState();
}

class ThemePreviewState extends State<ThemePreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        color: Color(widget.theme.primaryColor),
      ),
      clipBehavior: Clip.antiAlias,
      width: 150,
      height: 200,
      child: Column(
        children: [
          Container(
            height: 50,
            color: Color(
              widget.theme.primaryColor,
            ),
            child: Center(
              child: Container(
                width: 120,
                height: 10,
                color: Color(widget.theme.textColor),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 50,
                color: Color(
                  widget.theme.primaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(widget.theme.accentColor),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 80,
                          height: 5,
                          color: Color(widget.theme.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 50,
                color: Color(
                  widget.theme.primaryColor,
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(widget.theme.accentColor),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 80,
                          height: 5,
                          color: Color(widget.theme.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 50,
            color: Color(
              widget.theme.primaryColor,
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(widget.theme.accentColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(widget.theme.accentColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(widget.theme.accentColor),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
