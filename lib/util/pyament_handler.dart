// ignore_for_file: implementation_imports, avoid_print

import 'package:apple_shop/util/extenstions/string_extenstions.dart';
import 'package:apple_shop/util/url_handler.dart';
import 'package:uni_links/uni_links.dart';
import 'package:zarinpal/src/call_backs.dart';
import 'package:zarinpal/zarinpal.dart';

abstract class PaymentHandler {
  Future<void> initPaymentRequest(int finalPrice);
  Future<void> sendPaymentRequest();
  Future<void> verifyPaymentRequest();
}

class ZarinpalPaymentHandler extends PaymentHandler {
  final PaymentRequest _paymentRequest = PaymentRequest();
  final UrlHandler urlHandler;

  String? _authority;
  String? _status;

  ZarinpalPaymentHandler(this.urlHandler);

  @override
  Future<void> initPaymentRequest(int finalPrice) async {
    _paymentRequest.setIsSandBox(true); // Enable sandbox for testing
    _paymentRequest.setAmount(finalPrice);
    _paymentRequest.setDescription(
        'This is a test payment for the Apple Shop application.');
    _paymentRequest.setMerchantID('d645fba8-1b29-11ea-be59-000c295eb8fc');
    _paymentRequest.setCallbackURL('expertflutter://shop');

    // Listen for deep links to handle payment verification
    linkStream.listen((deeplink) {
      if (deeplink != null && deeplink.toLowerCase().contains('authority')) {
        _authority = deeplink.extractValueFromQuery('Authority');
        _status = deeplink.extractValueFromQuery('Status');
        verifyPaymentRequest();
      }
    });
  }

  @override
  Future<void> sendPaymentRequest() async {
    ZarinPal().startPayment(
      _paymentRequest,
      (status, paymentGatewayUri) {
        if (status == 100) {
          urlHandler.openUrl(paymentGatewayUri!);
        } else {
          print('Payment request failed with status: $status');
        }
      } as OnCallbackRequestPaymentListener,
    );
  }

  @override
  Future<void> verifyPaymentRequest() async {
    if (_authority == null || _status == null) {
      print('Error: Authority or Status is null.');
      return;
    }

    ZarinPal().verificationPayment(
      _status!,
      _authority!,
      _paymentRequest,
      (isPaymentSuccess, refID, paymentRequest) {
        if (isPaymentSuccess) {
          print('Payment successful! RefID: $refID');
        } else {
          print('Payment verification failed.');
        }
      } as OnCallbackVerificationPaymentListener,
    );
  }
}

class PayPalPaymentHandler extends PaymentHandler {
  @override
  Future<void> initPaymentRequest(int finalPrice) async {}

  @override
  Future<void> sendPaymentRequest() async {}

  @override
  Future<void> verifyPaymentRequest() async {}
}
