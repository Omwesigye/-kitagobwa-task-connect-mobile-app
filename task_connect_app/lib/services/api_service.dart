import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/models/booking_model.dart';

// --- 1. USE THIS IMPORT INSTEAD ---
import 'package:flutter/foundation.dart';
// ----------------------------------

import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_connect_app/screens/api_config.dart'; 

class ApiService {
  static String get _baseUrl {
    // 'kIsWeb' will now be correctly found from the foundation.dart import
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

  // --- (fetchProviders is correct) ---
  static Future<List<ServiceProviderModel>> fetchProviders() async {
    final response = await http.get(Uri.parse('$_baseUrl/service-providers'));
    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = jsonDecode(response.body)['data'];
        return jsonData
            .map((json) => ServiceProviderModel.fromJson(json))
            .toList();
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
    } else {
      throw Exception('Failed to load providers (${response.statusCode})');
    }
  }

  // --- (fetchBookings is correct) ---
  static Future<List<BookingModel>> fetchBookings(int userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => BookingModel.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
    } else {
      throw Exception('Failed to load bookings (${response.statusCode})');
    }
  }

  // --- (createBooking is correct) ---
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
    final url = Uri.parse('$_baseUrl/bookings');

    final response = await http.post(
      url,
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
  
  // --- (Provider functions are all correct) ---
  static Future<List<BookingModel>> fetchProviderBookings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/bookings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => BookingModel.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
      try {
        return BookingModel.fromJson(jsonDecode(response.body)['data']);
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
      try {
        return BookingModel.fromJson(jsonDecode(response.body)['data']);
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
      try {
        return BookingModel.fromJson(jsonDecode(response.body)['data']);
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
  
  static Future<Map<String, dynamic>> getProviderProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
      try {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item.toString()).toList();
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
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
      body: jsonEncode({
        'filename': filename,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getProviderRatings() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/provider/ratings'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
    } else {
      throw Exception('Failed to load ratings (${response.statusCode})');
    }
  }

  // -----------------------------
  // PAYPAL PAYMENT METHODS
  // -----------------------------
  
  /// Get PayPal access token using client credentials from environment variables
  static Future<String> getPayPalAccessToken() async {
    final clientId = ApiConfig.paypalClientId;
    final secret = ApiConfig.paypalSecret;
    
    if (clientId.isEmpty || secret.isEmpty) {
      throw Exception('PayPal credentials not configured. Please set PAYPAL_CLIENT_ID and PAYPAL_SECRET environment variables.');
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
  
  /// Create a PayPal payment order
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
            'amount': {
              'currency_code': currency,
              'value': amount.toStringAsFixed(2),
            },
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
  
  /// Capture a PayPal payment
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
}

