import 'package:easy_ozow/easy_ozow.dart';
import 'package:example/failed.dart';
import 'package:example/success.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:onepref/onepref.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cancel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  EasyOzow easyOzow = EasyOzow();

  String url = "";
  String generatedPaymentUrl = "";
  bool paymentLinkFound = false;
  bool paymentLinkGenerated = false;
  bool payWithOzow = false;
  bool linkRequested = false;

  final _messangerKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    easyOzow.init(
      apiKey: "--",
      privateKey: "--",
      siteCode: "---",
      isTest: true,
    );
  }

  void createPayment(int button) async {
    await easyOzow
        .generatePaymentLink(
      amount: double.tryParse(_controller.text) ??
          0.10, // convert string to double, if null use R0.10c
      successUrl: "https://dingi.icu/easyOzow/successLink.php",
      cancelUrl: "https://dingi.icu/easyOzow/cancelLink.php",
      errorUrl: "https://dingi.icu/easyOzow/errorLink.php",
      notifyUrl: "https://access.dingi.icu",
    )
        .then((value) {
      setState(() {
        if (button == 1) {
          paymentLinkGenerated = true;
          generatedPaymentUrl = value['url'];
        } else {
          paymentLinkFound = true;
          url = value['url'];
        }
      });
    });
  }

  Future<void> openUrlBrowser(String link) async {
    final Uri url = Uri.parse(link.trim());
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Ozow',
      scaffoldMessengerKey: _messangerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Flutter Ozow"),
            backgroundColor: Colors.greenAccent,
          ),
          body: payWithOzow
              ? initPayment()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      paymentLinkGenerated
                          ? Column(
                              children: [
                                Center(
                                    child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 20.0, left: 20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.greenAccent.withOpacity(0.2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        generatedPaymentUrl,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      OnClickAnimation(
                                        onTap: () => {
                                          if (generatedPaymentUrl
                                              .contains("pay.ozow.com"))
                                            {
                                              openUrlBrowser(
                                                  generatedPaymentUrl)
                                            },
                                        },
                                        child: const Text(
                                          "Open Link",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      OnClickAnimation(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(
                                                  text: generatedPaymentUrl))
                                              .then((_) {
                                            _messangerKey.currentState!
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Payment Link copied to clipboard")));
                                          });
                                        },
                                        child: const Text(
                                          "Copy Link",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Visibility(
                              visible: linkRequested,
                              child: const CircularProgressIndicator()),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: const EdgeInsets.all(30),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Amount",
                            helperText: "e.g 12.00",
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => {
                          setState(() {
                            linkRequested = true;
                          }),
                          createPayment(1)
                        },
                        child: const Text(
                          "Generate Payment Link",
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      GestureDetector(
                        onTap: () => {
                          setState(() {
                            payWithOzow = true;
                          }),
                          createPayment(2)
                        },
                        child: Container(
                          color: Colors.greenAccent,
                          padding: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                            top: 5,
                            bottom: 5,
                          ),
                          child: const Text(
                            "Pay with Ozow",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget initPayment() {
    return paymentLinkFound
        ? OzowPaymentUI(
            paymentLink: url,
            successScreen: const Success(),
            failedScreen: const Failed(),
            cancelScreen: const Cancel(),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
