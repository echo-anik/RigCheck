class User {
  final int id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? locationCity;
  final String? preferredCurrency;
  final String? theme;
  final String? role; // 'user' or 'admin'
  final DateTime? lastLogin;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.locationCity,
    this.preferredCurrency,
    this.theme,
    this.role,
    this.lastLogin,
    this.createdAt,
  });

  // Helper getter for display name with fallback
  String get name => displayName ?? username;

  // Check if user is an admin
  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: (json['username'] ?? json['name']) as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      locationCity: json['location_city'] as String?,
      preferredCurrency: json['preferred_currency'] as String?,
      theme: json['theme'] as String?,
      role: json['role'] as String?, // admin or user
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': username,
      'username': username,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location_city': locationCity,
      'preferred_currency': preferredCurrency,
      'theme': theme,
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? locationCity,
    String? preferredCurrency,
    String? theme,
    String? role,
    DateTime? lastLogin,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      locationCity: locationCity ?? this.locationCity,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      theme: theme ?? this.theme,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
