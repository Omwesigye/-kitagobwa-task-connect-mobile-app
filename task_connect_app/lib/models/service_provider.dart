class ServiceProviderModel {
  final int id;
  // --- 1. ADD THIS FIELD ---
  final int userId;
  // -----------------------
  final String name;
  final String service;
  final String description;
  final List<String> images;
  final double rating;
  final String telnumber;

  ServiceProviderModel({
    required this.id,
    // --- 2. ADD TO CONSTRUCTOR ---
    required this.userId,
    // ---------------------------
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
      // --- 3. PARSE THE user_id ---
      // This line finds the user ID from your API
      userId: json['user_id'] ?? (user != null ? user['id'] : 0),
      // ----------------------------
      name: user != null ? (user['name']?.toString() ?? 'No Name') : 'No Name',
      service: json['service']?.toString() ?? 'Unknown Service',
      description: json['description']?.toString() ?? '',
      images: imagesJson is List
          ? imagesJson.map((img) => img.toString()).toList()
          : [],
      rating: ratingValue != null
          ? double.tryParse(ratingValue.toString()) ?? 4.5
          : 4.5,
      telnumber: json['telnumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // --- 4. ADD TO toJson ---
      'name': name,
      'service': service,
      'description': description,
      'images': images,
      'rating': rating,
      'telnumber': telnumber,
    };
  }
}