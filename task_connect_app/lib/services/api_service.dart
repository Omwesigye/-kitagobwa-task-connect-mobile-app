import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_connect_app/models/service_provider.dart';
import 'package:task_connect_app/models/booking_model.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // Fetch service providers
  static Future<List<ServiceProviderModel>> fetchProviders() async {
    final response = await http.get(Uri.parse('$baseUrl/service-providers'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body)['data'];
      return jsonData
          .map((json) => ServiceProviderModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load providers');
    }
  }

  // Fetch bookings for a user
  static Future<List<BookingModel>> fetchBookings(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(
        response.body,
      ); // Remove ['data']
      // Filter by user_id if backend doesn’t already
      final userBookings = jsonData
          .where((b) => b['user_id'] == userId)
          .toList();

      return userBookings.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }

  // Create a new booking (POST request)
  static Future<void> createBooking({
    required int userId,
    required int providerId,
    required String date,
    required String time,
  }) async {
    final url = Uri.parse('$baseUrl/bookings');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId, // include user ID
        'provider_id': providerId,
        'date': date,
        'time': time,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Booking failed: ${response.body}');
    }
  }
}
