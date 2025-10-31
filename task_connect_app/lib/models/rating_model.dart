// A simple class to hold the customer's name
class RatingUser {
  final int id;
  final String name;

  RatingUser({required this.id, required this.name});

  factory RatingUser.fromJson(Map<String, dynamic> json) {
    return RatingUser(
      id: json['id'],
      name: json['name'] ?? 'Anonymous',
    );
  }
}

// The main model for an individual rating
class RatingModel {
  final int id;
  final int rating;
  final String? comment;
  final String createdAt;
  final RatingUser user;

  RatingModel({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.user,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
      user: RatingUser.fromJson(json['user'] ?? {}),
    );
  }
}
