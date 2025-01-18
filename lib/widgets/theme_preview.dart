import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feederr/models/app_theme.dart';
import 'package:flutter/widgets.dart';

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
      // clipBehavior: Clip.antiAlias,
      width: 150,
      height: 204,
      decoration: BoxDecoration(
        color: Color(
          widget.theme.surfaceColor,
        ),
        border: Border.all(
          color: Color(widget.theme.primaryColor),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50,
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
              SizedBox(
                height: 50,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(widget.theme.primaryColor),
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
              SizedBox(
                height: 50,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(widget.theme.primaryColor),
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
            decoration: BoxDecoration(
              color: Color(widget.theme.secondaryColor),
              // border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Color(widget.theme.primaryColor),
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
                      color: Color(widget.theme.primaryColor),
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
                      color: Color(widget.theme.primaryColor),
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
