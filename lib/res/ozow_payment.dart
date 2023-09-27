import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class FlutterOzow {
  String _apiKey = "";
  String _privateKey = "";
  String _siteCode = "";
  bool _isTest = true;

  init({
    required String apiKey,
    required String privateKey,
    required String siteCode,
    required bool isTest,
  }) {
    _apiKey = apiKey;
    _privateKey = privateKey;
    _siteCode = siteCode;
    _isTest = isTest;
  }

  Future<List<Map<String, dynamic>>> getTransactionReport(
      String startDate, String endDate) async {
    if (_apiKey.isEmpty || _siteCode.isEmpty || _privateKey.isEmpty) {
      return [
        {
          'errorMessage':
              "Please call init and pass in the correct API, Private key and Site Code"
        }
      ];
    } else {
      /*  
    example:
    https://api.ozow.com/GetTransactionReport?SiteCode=WDT-WDT-001&StartDate=2023-08-12&EndDate=2023-08-22
    */
      var request = http.Request(
          'GET',
          Uri.parse(
              'https://api.ozow.com/GetTransactionReport?SiteCode=$_siteCode&StartDate=$startDate&EndDate=$endDate'));

      request.headers.addAll(
        {
          'ApiKey': _apiKey,
          'Accept': 'application/json',
        },
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var json = await response.stream.bytesToString();
        return List<Map<String, dynamic>>.from(jsonDecode(json));
      } else {
        return [
          {'errorMessage': "Could not get the report from the server"}
        ];
      }
    }
  }

  Future<Map> generatePaymentLink({
    required double amount,
    required String successUrl,
    required String cancelUrl,
    required String errorUrl,
    required String notifyUrl,
  }) async {
    if (_apiKey.isEmpty || _siteCode.isEmpty || _privateKey.isEmpty) {
      return {
        'errorMessage':
            "Please call init and pass in the correct API, Private key and Site Code"
      };
    } else {
      var ref = _generateRandomString(6);

      var value = await generateRequestHash(
        amountP: amount,
        cancelUrlP: cancelUrl,
        successUrlP: successUrl,
        errorUrlP: errorUrl,
        notifyUrlP: notifyUrl,
        ref: ref,
      );

      var response =
          await http.post(Uri.parse("https://api.ozow.com/postpaymentrequest"),
              headers: {
                'Content-Type': 'application/json',
                'ApiKey': _apiKey,
                'Accept': "application/json",
              },
              body: jsonEncode({
                'countryCode': 'ZA',
                'amount': amount,
                'transactionReference': ref,
                'bankReference': ref,
                'cancelUrl': cancelUrl,
                'currencyCode': 'ZAR',
                'errorUrl': errorUrl,
                'isTest': _isTest,
                'notifyUrl': notifyUrl,
                'siteCode': _siteCode,
                'successUrl': successUrl,
                'hashCheck': value
              }));

      if (response.statusCode == 200) {
        Map map = await jsonDecode(response.body) as Map;
        return map;
      } else {
        return {
          "code": response.statusCode,
          "message": response.body,
        };
      }
    }
  }

  Future<String> generateRequestHash({
    required double amountP,
    required String successUrlP,
    required String cancelUrlP,
    required String errorUrlP,
    required String notifyUrlP,
    required String ref,
  }) async {
    final siteCode = _siteCode;
    const countryCode = "ZA";
    const currencyCode = "ZAR";
    final amount = amountP;
    final transactionReference = ref;
    final bankReference = ref;
    final cancelUrl = cancelUrlP;
    final errorUrl = errorUrlP;
    final successUrl = successUrlP;
    final notifyUrl = notifyUrlP;
    final privateKey = _privateKey;
    final isTest = _isTest;

    final inputString =
        "$siteCode$countryCode$currencyCode$amount$transactionReference$bankReference$cancelUrl$errorUrl$successUrl$notifyUrl$isTest$privateKey";

    return _generateRequestHashCheck(inputString);
  }

  static String _generateRequestHashCheck(String inputString) {
    final stringToHash = inputString.toLowerCase();
    return _getSha512Hash(stringToHash);
  }

  static String _getSha512Hash(String stringToHash) {
    final bytes = utf8.encode(stringToHash);
    final digest = sha512.convert(bytes);
    return digest.toString();
  }

  static String _generateRandomString(int length) {
    const characters =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const charactersLength = characters.length;
    final random = Random();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(characters[random.nextInt(charactersLength)]);
    }

    return buffer.toString();
  }
}
