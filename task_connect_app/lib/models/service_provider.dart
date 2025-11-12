import 'dart:convert';

class ServiceProviderModel {
  final int id;
  final int userId;
  final String name;
  final String service;
  final String description;
  final List<String> images;
  final double rating;
  final String telnumber;

  ServiceProviderModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.service,
    required this.description,
    required this.images,
    required this.rating,
    required this.telnumber,
  });

  factory ServiceProviderModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final imagesJson = json['images'];
    final ratingValue = json['rating'];

    return ServiceProviderModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? (user != null ? user['id'] ?? 0 : 0),
      name: (user != null && user['name'] != null)
          ? user['name'].toString()
          : 'No Name',
      service: json['service']?.toString() ?? 'Unknown Service',
      description: json['description']?.toString() ?? '',
      images: _parseImages(imagesJson),
      rating: ratingValue != null
          ? double.tryParse(ratingValue.toString()) ?? 4.5
          : 4.5,
      telnumber: json['telnumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'service': service,
      'description': description,
      'images': images,
      'rating': rating,
      'telnumber': telnumber,
    };
  }

  static List<String> _parseImages(dynamic rawImages) {
    if (rawImages == null) return [];

    if (rawImages is List) {
      return rawImages
          .map((img) => img?.toString() ?? '')
          .where((img) => img.isNotEmpty)
          .toList();
    }

    if (rawImages is String) {
      final value = rawImages.trim();
      if (value.isEmpty) return [];

      // Try to decode JSON list string (e.g. '["a","b"]')
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded
              .map((img) => img?.toString() ?? '')
              .where((img) => img.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // Ignore and fallback to other parsing strategies
      }

      // Handle comma-separated values (e.g. "a,b")
      if (value.contains(',')) {
        return value
            .split(',')
            .map((img) => _stripWrappingQuotes(img.trim()))
            .where((img) => img.isNotEmpty)
            .toList();
      }

      // Handle single filename or URL
      final single = _stripWrappingQuotes(value);
      return single.isEmpty ? [] : [single];
    }

    return [];
  }

  static String _stripWrappingQuotes(String input) {
    if (input.length >= 2) {
      final first = input[0];
      final last = input[input.length - 1];
      if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
        return input.substring(1, input.length - 1);
      }
    }
    return input;
  }
}
