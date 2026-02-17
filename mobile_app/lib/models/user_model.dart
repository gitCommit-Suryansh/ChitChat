class User {
  final String id;
  final String name;
  final String email;
  final String pic;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.pic,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pic: json['pic'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'pic': pic,
      'token': token,
    };
  }
}
