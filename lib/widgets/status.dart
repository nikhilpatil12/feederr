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
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: status.isEmpty ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      secondChild: Container(),
      firstChild: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(status,
            style: TextStyle(
              fontSize: 12,
              fontVariations: [FontVariation.weight(300)],
            )),
        CupertinoActivityIndicator(
          color: Color(themeProvider.theme.primaryColor),
          radius: 10,
        )
      ]),
    );
  }
}
