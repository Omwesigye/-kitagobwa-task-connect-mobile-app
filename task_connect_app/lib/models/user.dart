class User {
  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      passwordHash: map['passwordHash'],
    );
  }
}
