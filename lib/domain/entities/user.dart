class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final int? createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.createdAt,
  });
}
