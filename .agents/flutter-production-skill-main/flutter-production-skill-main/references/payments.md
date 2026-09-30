# Payment Gateways — Stripe, PayPal & Local Methods

## Stripe

```yaml
dependencies:
  flutter_stripe: ^10.2.0
```

### Setup
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = AppConfig.stripePublishableKey;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}
```

### Payment Sheet (Recommended)
```dart
@lazySingleton
class StripeService {
  final DioClient _dio;
  StripeService(this._dio);

  /// Full payment flow using PaymentSheet
  Future<PaymentResult> processPayment({
    required int amountCents,
    required String currency,
    required String customerEmail,
  }) async {
    try {
      // 1. Create PaymentIntent on YOUR backend
      final response = await _dio.post('/payments/create-intent', data: {
        'amount': amountCents,
        'currency': currency,
        'customer_email': customerEmail,
      });

      final clientSecret = response['client_secret'] as String;
      final customerId = response['customer_id'] as String?;
      final ephemeralKey = response['ephemeral_key'] as String?;

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your App Name',
          customerId: customerId,
          customerEphemeralKeySecret: ephemeralKey,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF6C63FF),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // false in production
          ),
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'US',
          ),
        ),
      );

      // 3. Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      return PaymentResult.success;
    } on StripeException catch (e) {
      return switch (e.error.code) {
        FailureCode.Canceled => PaymentResult.cancelled,
        FailureCode.Failed => PaymentResult.failed,
        _ => PaymentResult.failed,
      };
    } catch (e) {
      log.e('Stripe payment failed', e);
      return PaymentResult.failed;
    }
  }

  /// Save card for future payments
  Future<bool> setupCard() async {
    try {
      final response = await _dio.post('/payments/setup-intent', data: {});
      final clientSecret = response['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: clientSecret,
          merchantDisplayName: 'Your App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      rethrow;
    }
  }
}

enum PaymentResult { success, failed, cancelled }
```

---

## PayPal

```yaml
dependencies:
  flutter_paypal_payment: ^1.0.5
```

```dart
Future<void> payWithPayPal({
  required BuildContext context,
  required double amount,
  required String currency,
}) async {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => UsePaypal(
        sandboxMode: !AppConfig.isProd,
        clientId: AppConfig.paypalClientId,
        secretKey: AppConfig.paypalSecretKey,
        returnURL: 'https://yourapp.com/payment/success',
        cancelURL: 'https://yourapp.com/payment/cancel',
        transactions: [
          {
            'amount': {
              'total': amount.toStringAsFixed(2),
              'currency': currency,
              'details': {
                'subtotal': amount.toStringAsFixed(2),
                'shipping': '0',
                'shipping_discount': '0',
              }
            },
            'description': 'Premium Subscription',
          }
        ],
        note: 'Contact us at support@yourapp.com',
        onSuccess: (params) {
          Navigator.pop(context);
          log.i('PayPal payment success: $params');
          // Verify on your backend: params['paymentId']
        },
        onError: (error) {
          Navigator.pop(context);
          log.e('PayPal error: $error');
        },
        onCancel: (params) {
          Navigator.pop(context);
          log.d('PayPal cancelled');
        },
      ),
    ),
  );
}
```

---

## Unified Payment Service

```dart
enum PaymentMethod { stripe, paypal, applePay, googlePay, inAppPurchase }

@lazySingleton
class PaymentService {
  final StripeService _stripe;
  final IAPService _iap;

  PaymentService(this._stripe, this._iap);

  /// Determine best payment method for platform
  List<PaymentMethod> getAvailableMethods() {
    if (Platform.isIOS) {
      return [PaymentMethod.applePay, PaymentMethod.stripe,
              PaymentMethod.inAppPurchase];
    }
    return [PaymentMethod.googlePay, PaymentMethod.stripe,
            PaymentMethod.inAppPurchase];
  }

  Future<PaymentResult> pay({
    required PaymentMethod method,
    required int amountCents,
    required String currency,
    String? customerEmail,
  }) async {
    switch (method) {
      case PaymentMethod.stripe:
      case PaymentMethod.applePay:
      case PaymentMethod.googlePay:
        return _stripe.processPayment(
          amountCents: amountCents,
          currency: currency,
          customerEmail: customerEmail ?? '',
        );
      case PaymentMethod.inAppPurchase:
        // Handled separately via IAPService
        throw UnsupportedError('Use IAPService for in-app purchases');
      case PaymentMethod.paypal:
        throw UnsupportedError('Open PayPal screen separately');
    }
  }
}
```

---

## Payment UI Pattern

```dart
class PaymentScreen extends ConsumerWidget {
  final int amountCents;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Column(
        children: [
          PriceDisplayCard(amountCents: amountCents, currency: currency),
          const Spacer(),
          if (Platform.isIOS)
            ApplePayButton(
              onPressed: () => ref.read(paymentNotifierProvider.notifier)
                  .pay(PaymentMethod.applePay),
            ),
          if (Platform.isAndroid)
            GooglePayButton(
              onPressed: () => ref.read(paymentNotifierProvider.notifier)
                  .pay(PaymentMethod.googlePay),
            ),
          const Divider(),
          AppButton(
            label: 'Pay with Card',
            isLoading: paymentState.isLoading,
            onTap: () => ref.read(paymentNotifierProvider.notifier)
                .pay(PaymentMethod.stripe),
          ),
        ],
      ),
    );
  }
}
```

---

## Security Notes

- **Never** process payments client-side only — always verify with your backend
- Always verify webhook signatures from Stripe/PayPal on your server
- Use `AppConfig.stripePublishableKey` (not secret key) in the app
- For subscriptions: prefer RevenueCat / App Store / Play Store IAP over direct Stripe for better compliance
- Store `paymentIntentId` from your backend for reconciliation
