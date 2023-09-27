// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class OzowPaymentUI extends StatefulWidget {
  String paymentLink;
  Widget successScreen;
  Widget failedScreen;
  Widget cancelScreen;

  OzowPaymentUI({
    super.key,
    required this.paymentLink,
    required this.successScreen,
    required this.failedScreen,
    required this.cancelScreen,
  });

  @override
  State<OzowPaymentUI> createState() => _OzowPaymentUIState();
}

class _OzowPaymentUIState extends State<OzowPaymentUI> {
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {},
              onUrlChange: (UrlChange change) => {
                if (change.url.toString().contains("success"))
                  {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => widget.successScreen,
                      ),
                    )
                  }
                else if (change.url.toString().contains("error"))
                  {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => widget.failedScreen,
                      ),
                    )
                  }
                else if (change.url.toString().contains("cancel"))
                  {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => widget.cancelScreen,
                      ),
                    )
                  }
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
            Uri.parse(
              widget.paymentLink,
            ),
          ));
  }
}
