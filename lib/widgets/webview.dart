import 'package:feederr/utils/providers/themeprovider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  const CustomWebView({super.key, required this.url});
  final String url;
  @override
  CustomWebViewState createState() => CustomWebViewState();
}

class CustomWebViewState extends State<CustomWebView> {
  double webProgress = 0;
  bool isLoaded = false;
  late final webViewController;

  @override
  void initState() {
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // ..setBackgroundColor(
      //   Color(widget.theme.surfaceColor),
      // )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                webProgress = progress / 100;
                if (progress == 100) isLoaded = true;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          WebViewWidget(
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => VerticalDragGestureRecognizer(),
              ),
            },
            controller: webViewController,
          ),
          !isLoaded
              ? Selector<ThemeProvider, int>(
                  selector: (_, themeProvider) =>
                      themeProvider.theme.primaryColor,
                  builder: (context, primaryColor, child) {
                    return LinearProgressIndicator(
                      value: webProgress,
                      color: Color(primaryColor),
                      backgroundColor: Colors.transparent,
                    );
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
