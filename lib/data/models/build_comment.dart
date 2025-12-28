class BuildComment {
  final int? id;
  final int buildId;
  final int? userId;
  final String userName;
  final String? userAvatar;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPending; // For offline sync

  BuildComment({
    this.id,
    required this.buildId,
    this.userId,
    required this.userName,
    this.userAvatar,
    required this.commentText,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPending = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BuildComment.fromJson(Map<String, dynamic> json) {
    return BuildComment(
      id: json['id'] as int?,
      buildId: json['build_id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String?,
      commentText: json['comment_text'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      isPending: json['is_pending'] == 1 || json['is_pending'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'build_id': buildId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_pending': isPending ? 1 : 0,
    };
  }

  BuildComment copyWith({
    int? id,
    int? buildId,
    int? userId,
    String? userName,
    String? userAvatar,
    String? commentText,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPending,
  }) {
    return BuildComment(
      id: id ?? this.id,
      buildId: buildId ?? this.buildId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPending: isPending ?? this.isPending,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
}
