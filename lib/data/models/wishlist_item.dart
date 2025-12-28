/// Model representing a wishlist item
/// Can be either a component or a build
class WishlistItem {
  final String id;
  final WishlistItemType type;
  final DateTime addedAt;

  WishlistItem({
    required this.id,
    required this.type,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      type: WishlistItemType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => WishlistItemType.component,
      ),
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'added_at': addedAt.toIso8601String(),
    };
  }

  WishlistItem copyWith({
    String? id,
    WishlistItemType? type,
    DateTime? addedAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WishlistItem && other.id == id && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

/// Type of wishlist item
enum WishlistItemType {
  component,
  build,
}
