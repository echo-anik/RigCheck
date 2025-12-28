class Post {
  final int id;
  final int userId;
  final String? userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final int? buildId;
  final String? buildName;
  final int likeCount;
  final int commentCount;
  final bool isLikedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.buildId,
    this.buildName,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLikedByUser = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      buildId: json['build_id'] as int?,
      buildName: json['build_name'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLikedByUser: json['is_liked_by_user'] == 1 || json['is_liked_by_user'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_url': imageUrl,
      'build_id': buildId,
      'build_name': buildName,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked_by_user': isLikedByUser,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    int? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    int? buildId,
    String? buildName,
    int? likeCount,
    int? commentCount,
    bool? isLikedByUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      buildId: buildId ?? this.buildId,
      buildName: buildName ?? this.buildName,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
