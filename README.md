Package Name: Flutter Ozow 

Best and easy way to INTEGRATE Ozow checkout in Flutter application, this package is not an official package from ozow.com
. Happy implementing this package into your app.

## Features

- Generate Payment Link
- Ozow Payment UI (Using WebView)
- Get Payment History

## Getting started (Required)

Prerequisites: 
You will need to have a valid Merchant account with Ozow.com to get the following info.
- SiteCode
- ApiKey
- PrivateKey

## Usage

Three easy steps to get started

**Step 1 - Initialize the package and connect to ozow**

```dart
 @override
void initState() {
  super.initState();
  
  flutterOzow.init(
    apiKey: "------------------",
    privateKey: "-----------------",
    siteCode: "--------",
    isTest: true,
  );
  
}
```

**Step 2 - Generating a payment link**

   - cancelUrl - will direct to cancelUrl if the payment process was cancelled
   - successUrl - will direct to successUrl if the payment process went through
   - errorUrl - will direct to errorUrl if the payment process went wrong
   - All these urls will have additional parameters when they are being returned into your app by ozow

```dart
  void generatePaymentLink() async {
    await flutterOzow
        .generatePaymentLink(
      amount: 0.10,  // Enter the amount you want for the customer to pay.
      successUrl: "https://dingi.icu/easyOzow/successLink.php",
      cancelUrl: "https://dingi.icu/easyOzow/cancelLink.php",
      errorUrl: "https://dingi.icu/easyOzow/errorLink.php",
      notifyUrl: "https://access.dingi.icu",
    ).then((value) {
      generatedPaymentUrl = value['url'];
    });
  }

```

The response url: 
- You simple update this information from your backend and write it in the db or update the order to paid

```text

https://dingi.icu/easyOzow/successLink.php?SiteCode=OOOP-OP-32&TransactionId=5bd36283-d36e-47e6-acf7-67b68c0913dc&TransactionReference=RZQIA2&Amount=0.10&Status=Complete&Optional1=&Optional2=&Optional3=&Optional4=&Optional5=&CurrencyCode=ZAR&IsTest=true&StatusMessage=Test+transaction+completed&Hash=8d60f5fb15ac27c830d15140cbde47e2d808ca219a69931c526f4249560775c293af86bdeafbb58c0ae72d578ac2323d4d32f58f6d2ecb7700382122fe7a5037

```

**Step 3** - Ozow Payment UI (WebView) Widget

- You just need to pass in the Payment link and three screens to redirect to once the payment process is done.

```dart
OzowPaymentUI( 
paymentLink: generatedPaymentUrl,
successScreen: const Success(),
failedScreen: const Failed(),
cancelScreen: const Cancel(),
)
```

## Additional information

Developers are welcome to contribute to this open source package and report any issues, explore it on github: [https://github.com/wdtheprovider/flutter_ozow](https://github.com/wdtheprovider/flutter_ozow)
