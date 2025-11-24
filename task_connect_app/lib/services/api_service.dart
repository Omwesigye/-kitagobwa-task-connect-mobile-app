import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/models/booking_model.dart';
import 'package:task_connect_app/screens/api_config.dart';

class ApiService {
  static const Map<String, String> _publicJsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static String get _baseUrl {
    return kIsWeb ? "http://127.0.0.1:8000/api" : "http://10.0.2.2:8000/api";
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _getUploadHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ------------------------
  // SERVICE PROVIDERS
  // ------------------------
  static Future<List<ServiceProviderModel>> fetchProviders() async {
    final response = await http.get(Uri.parse('$_baseUrl/service-providers'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body)['data'];
      return jsonData.map((json) => ServiceProviderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load providers (${response.statusCode})');
    }
  }

  // ------------------------
  // BOOKINGS
  // ------------------------
  static Future<List<BookingModel>> fetchBookings(int userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings (${response.statusCode})');
    }
  }

  static Future<void> createBooking({
    required int providerId,
    required String providerName,
    required String providerImageUrl,
    required String service,
    required String date,
    required String time,
    required String location,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: headers,
      body: jsonEncode({
        'provider_id': providerId,
        'provider_name': providerName,
        'provider_image_url': providerImageUrl,
        'service': service,
        'date': date,
        'time': time,
        'location': location,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Booking failed: ${response.body}');
    }
  }

  static Future<List<BookingModel>> fetchProviderBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/bookings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load provider bookings (${response.statusCode})');
    }
  }

  static Future<BookingModel> acceptBooking(int bookingId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings/$bookingId/accept'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to accept booking (${response.statusCode})');
    }
  }

  static Future<BookingModel> declineBooking(int bookingId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings/$bookingId/decline'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to decline booking (${response.statusCode})');
    }
  }

  static Future<BookingModel> completeBooking(int bookingId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings/$bookingId/complete'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return BookingModel.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to complete booking (${response.statusCode})');
    }
  }

  static Future<void> logout() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      print('Failed to logout on server: ${response.body}');
    }
  }

  // ------------------------
  // PROVIDER PROFILE
  // ------------------------
  static Future<Map<String, dynamic>> getProviderProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile (${response.statusCode})');
    }
  }

  static Future<void> updateProviderProfile(Map<String, String> profileData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/provider/profile'),
      headers: headers,
      body: jsonEncode(profileData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  static Future<List<String>> getPhotos() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/photos'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => item.toString()).toList();
    } else {
      throw Exception('Failed to load photos (${response.statusCode})');
    }
  }

  static Future<void> uploadPhoto(XFile imageFile) async {
    final headers = await _getUploadHeaders();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/provider/photos'),
    );

    request.headers.addAll(headers);

    if (kIsWeb) {
      var bytes = await imageFile.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: imageFile.name,
      );
      request.files.add(multipartFile);
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Failed to upload photo: ${response.body}');
    }
  }

  static Future<void> deletePhoto(String filename) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/provider/photos/delete'),
      headers: headers,
      body: jsonEncode({'filename': filename}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo: ${response.body}');
    }
  }

  // ------------------------
  // RATINGS
  // ------------------------
  static Future<Map<String, dynamic>> getProviderRatings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/ratings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ratings (${response.statusCode})');
    }
  }

  // ------------------------
  // PAYPAL PAYMENT METHODS
  // ------------------------
  static Future<String> getPayPalAccessToken() async {
    final clientId = ApiConfig.paypalClientId;
    final secret = ApiConfig.paypalSecret;

    if (clientId.isEmpty || secret.isEmpty) {
      throw Exception('PayPal credentials not configured.');
    }

    final credentials = base64Encode(utf8.encode('$clientId:$secret'));
    final response = await http.post(
      Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get PayPal access token: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createPayPalPayment({
    required double amount,
    required String currency,
    required String description,
  }) async {
    final accessToken = await getPayPalAccessToken();

    final response = await http.post(
      Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'amount': {'currency_code': currency, 'value': amount.toStringAsFixed(2)},
            'description': description,
          }
        ],
        'application_context': {
          'return_url': 'https://example.com/return',
          'cancel_url': 'https://example.com/cancel',
        }
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create PayPal payment: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> capturePayPalPayment(String orderId) async {
    final accessToken = await getPayPalAccessToken();

    final response = await http.post(
      Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders/$orderId/capture'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to capture PayPal payment: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required double amount,
    required String paymentMethod,
    String? paypalOrderId,
    String? paypalPayerId,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/process'),
      headers: headers,
      body: jsonEncode({
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        'paypal_order_id': paypalOrderId,
        'paypal_payer_id': paypalPayerId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process payment (${response.statusCode}): ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getPaymentStatus(int bookingId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/status/$bookingId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get payment status (${response.statusCode})');
    }
  }

  // ------------------------
  // PASSWORD RESET
  // ------------------------
  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/forgot'),
      headers: _publicJsonHeaders,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to request reset.');
    }
  }

  static Future<void> verifyResetCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/verify'),
      headers: _publicJsonHeaders,
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode != 200) {
      throw Exception('Invalid or expired code.');
    }
  }

  static Future<void> resetPassword(
    String email,
    String code,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/password/reset'),
      headers: _publicJsonHeaders,
      body: jsonEncode({
        'email': email,
        'code': code,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to reset password.');
    }
  }
}
