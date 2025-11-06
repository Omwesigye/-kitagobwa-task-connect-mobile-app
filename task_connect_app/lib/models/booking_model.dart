import 'dart:convert';
import 'package:http/http.dart' as http;

// This baseUrl is not used by your app, but we'll leave it
const String baseUrl = 'https://example.com/api';

class BookingModel {
  final int? id;
  final int? userId;
  final int providerId;
  final String providerName;
  final String providerImageUrl;
  final String service;
  final String date;
  final String time;
  final String location;
  final String userStatus;
  final String providerStatus;
  
  // --- 1. ADD THE USER FIELD ---
  // This will hold the nested user object (e.g., {"id": 1, "name": "Swale"})
  final Map<String, dynamic>? user; 

  BookingModel({
    this.id,
    this.userId,
    required this.providerId,
    required this.providerName,
    required this.providerImageUrl,
    required this.service,
    required this.date,
    required this.time,
    required this.location,
    required this.userStatus,
    required this.providerStatus,
    // --- 2. ADD TO CONSTRUCTOR ---
    this.user,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      providerId: json['provider_id'] is int
          ? json['provider_id']
          : int.parse(json['provider_id'].toString()),
      providerName: json['provider_name'] ?? '',
      providerImageUrl: json['provider_image_url'] ?? '',
      service: json['service'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      userStatus: json['user_status'] ?? 'pending',
      providerStatus: json['provider_status'] ?? 'pending',
      // --- 3. PARSE THE NESTED USER OBJECT ---
      user: json['user'] != null ? json['user'] as Map<String, dynamic> : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'provider_id': providerId,
      'provider_name': providerName,
      'provider_image_url': providerImageUrl,
      'service': service,
      'date': date,
      'time': time,
      'location': location,
      'user_status': userStatus,
      'provider_status': providerStatus,
      // We don't need to send the 'user' object back to the server
    };
  }

  // This static method is in your file, but it's better
  // to have all API calls in ApiService.
  static Future<List<BookingModel>> fetchBookings(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings?user_id=$userId'));

    print('Raw API response: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonData = jsonDecode(response.body)['data'];
        return jsonData.map((json) => BookingModel.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Invalid JSON response from server. The server may have returned an HTML error page.');
      }
    } else {
      throw Exception('Failed to load bookings (${response.statusCode})');
    }
  }
}
