import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'api_service.dart';

class PayPalService {
  static String? _clientId;
  static String? _mode;
  static String? _currency;

  /// Fetch PayPal configuration from backend
  static Future<bool> initialize() async {
    try {
      final config = await ApiService.getPayPalConfig();
      _clientId = config['client_id'];
      _mode = config['mode'] ?? 'sandbox';
      _currency = config['currency'] ?? 'USD';
      return _clientId != null && _clientId!.isNotEmpty;
    } catch (e) {
      debugPrint('Error fetching PayPal config: $e');
      return false;
    }
  }

  /// Opens PayPal checkout
  /// Returns payment details if successful, null otherwise
  static Future<Map<String, dynamic>?> makePayment({
    required BuildContext context,
    required double amount,
    required String description,
  }) async {
    try {
            // Ensure PayPal is initialized
            if (_clientId == null) {
              final initialized = await initialize();
              if (!initialized) {
                throw Exception('Failed to initialize PayPal configuration');
              }
            }

      Map<String, dynamic>? result;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => PaypalCheckoutView(
            sandboxMode: _mode == 'sandbox',
            clientId: _clientId,
            secretKey: '', // Secret is only used server-side
            transactions: [
              {
                "amount": {
                  "total": amount.toStringAsFixed(2),
                  "currency": _currency ?? 'USD',
                  "details": {
                    "subtotal": amount.toStringAsFixed(2),
                    "shipping": "0",
                    "shipping_discount": 0
                  }
                },
                "description": description,
                "item_list": {
                  "items": [
                    {
                      "name": description,
                      "quantity": 1,
                      "price": amount.toStringAsFixed(2),
                      "currency": _currency ?? 'USD'
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your booking.",
            onSuccess: (Map params) async {
              debugPrint("PayPal payment successful: $params");
              result = Map<String, dynamic>.from(params);
              Navigator.pop(context);
            },
            onError: (error) {
              debugPrint("PayPal payment error: $error");
              Navigator.pop(context);
            },
            onCancel: () {
              debugPrint('PayPal payment cancelled by user');
              Navigator.pop(context);
            },
          ),
        ),
      );
      
      return result;
    } catch (e) {
      debugPrint('Error opening PayPal checkout: $e');
      return null;
    }
  }

  /// Validates if PayPal credentials are configured
  static bool isConfigured() {
    return _clientId != null && _clientId!.isNotEmpty;
  }
}
