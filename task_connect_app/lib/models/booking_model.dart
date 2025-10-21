import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://example.com/api';

class BookingModel {
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

  BookingModel({
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
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
  static Future<List<BookingModel>> fetchBookings(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/bookings?user_id=$userId'));

  // Print the raw response body to the console
  print('Raw API response: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body)['data'];
    return jsonData.map((json) => BookingModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load bookings');
  }
}
}


