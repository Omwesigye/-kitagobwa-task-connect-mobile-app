# PayPal Integration Guide

This document explains how to configure and use PayPal payment functionality in the Task Connect app.

## Configuration

### Flutter App (Mobile)

PayPal credentials are configured using compile-time environment variables. Pass them when running the app:

```bash
flutter run --dart-define=PAYPAL_CLIENT_ID=your_client_id_here --dart-define=PAYPAL_SECRET=your_secret_here
```

For building:

```bash
flutter build apk --dart-define=PAYPAL_CLIENT_ID=your_client_id_here --dart-define=PAYPAL_SECRET=your_secret_here
```

### Laravel Backend

Add your PayPal credentials to the `.env` file:

```env
PAYPAL_CLIENT_ID=your_paypal_client_id
PAYPAL_SECRET=your_paypal_secret
PAYPAL_MODE=sandbox  # Use 'live' for production
```

## Usage

### Available Methods in ApiService

The following PayPal methods are available in `lib/services/api_service.dart`:

#### 1. Get PayPal Access Token
```dart
String accessToken = await ApiService.getPayPalAccessToken();
```

#### 2. Create PayPal Payment
```dart
Map<String, dynamic> order = await ApiService.createPayPalPayment(
  amount: 10.00,
  currency: 'USD',
  description: 'Service booking payment',
);
```

#### 3. Capture PayPal Payment
```dart
Map<String, dynamic> captureResult = await ApiService.capturePayPalPayment(orderId);
```

## Example Usage

Here's how to integrate PayPal payment into your booking flow:

```dart
try {
  // Create payment order
  final order = await ApiService.createPayPalPayment(
    amount: 50.00,
    currency: 'USD',
    description: 'Booking for ${provider.name}',
  );
  
  // Get approval URL
  final approvalUrl = order['links'].firstWhere(
    (link) => link['rel'] == 'approve'
  )['href'];
  
  // Open approval URL in browser/webview for user to approve
  // After user approves, capture the payment
  
  final orderId = order['id'];
  final captureResult = await ApiService.capturePayPalPayment(orderId);
  
  print('Payment successful: ${captureResult['status']}');
} catch (e) {
  print('Payment failed: $e');
}
```

## Getting PayPal Credentials

1. Go to [PayPal Developer Dashboard](https://developer.paypal.com/dashboard/)
2. Create a new app or use an existing one
3. Copy the Client ID and Secret from the app credentials
4. For testing, use Sandbox credentials
5. For production, use Live credentials and set `PAYPAL_MODE=live`

## Environment Configuration

The PayPal credentials are accessed through the `ApiConfig` class:

```dart
String clientId = ApiConfig.paypalClientId;
String secret = ApiConfig.paypalSecret;
```

These values are sourced from environment variables at compile time, ensuring credentials are not hardcoded in the source code.

## Security Notes

- Never commit PayPal credentials to version control
- Use sandbox mode for development and testing
- Keep your secret key secure
- For production, ensure credentials are properly configured in your deployment environment
