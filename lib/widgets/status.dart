import 'package:blazefeeds/providers/status_provider.dart';
import 'package:blazefeeds/providers/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class Status extends StatelessWidget {
  const Status({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final status = Provider.of<StatusProvider>(context).status;
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(status),
      status != ""
          ? CupertinoActivityIndicator(
              color: Color(themeProvider.theme.primaryColor),
              radius: 10,
            )
          : Container()
    ]);
    // return Text(statusProvider.status);
  }
}
