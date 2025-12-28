class Component {
  final int id;
  final String productId;
  final String category;
  final String name;
  final String brand;
  final double? priceBdt;
  final String? imageUrl;
  final String? availabilityStatus;
  final int? popularityScore;
  final bool? featured;
  final Map<String, dynamic>? specs;

  Component({
    required this.id,
    required this.productId,
    required this.category,
    required this.name,
    required this.brand,
    this.priceBdt,
    this.imageUrl,
    this.availabilityStatus,
    this.popularityScore,
    this.featured,
    this.specs,
  });

  factory Component.fromJson(Map<String, dynamic> json) {
    // Handle price field - API returns lowest_price_bdt
    double? price;
    if (json['lowest_price_bdt'] != null) {
      final priceValue = json['lowest_price_bdt'];
      price = priceValue is String ? double.tryParse(priceValue) : (priceValue as num?)?.toDouble();
    } else if (json['price_bdt'] != null) {
      final priceValue = json['price_bdt'];
      price = priceValue is String ? double.tryParse(priceValue) : (priceValue as num?)?.toDouble();
    } else if (json['price'] != null) {
      final priceValue = json['price'];
      price = priceValue is String ? double.tryParse(priceValue) : (priceValue as num?)?.toDouble();
    }

    // Generate a numeric ID from product_id if id is not present
    int numericId = json['id'] as int? ?? json['product_id'].hashCode.abs();

    // Handle popularityScore - can be String or int
    int? popularityScore;
    if (json['popularity_score'] != null) {
      final scoreValue = json['popularity_score'];
      if (scoreValue is String) {
        popularityScore = int.tryParse(scoreValue);
      } else if (scoreValue is num) {
        popularityScore = scoreValue.toInt();
      }
    }

    String? resolvedImageUrl;
    final rawImageUrl = json['image_url'];
    if (rawImageUrl is String && rawImageUrl.isNotEmpty) {
      resolvedImageUrl = rawImageUrl;
    } else {
      final primaryImage = json['primary_image_url'];
      if (primaryImage is String && primaryImage.isNotEmpty) {
        resolvedImageUrl = primaryImage;
      } else {
        final imageList = json['image_urls'];
        if (imageList is List && imageList.isNotEmpty) {
          final firstImage = imageList.first;
          if (firstImage != null) {
            resolvedImageUrl = firstImage.toString();
          }
        }
      }
    }

    return Component(
      id: numericId,
      productId: json['product_id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      priceBdt: price,
      imageUrl: resolvedImageUrl,
      availabilityStatus: json['availability_status'] as String?,
      popularityScore: popularityScore,
      featured: json['featured'] == 1 || json['featured'] == true,
      specs: _parseSpecs(json['specs'] ?? json['specifications']),
    );
  }

  static Map<String, dynamic>? _parseSpecs(dynamic rawSpecs) {
    if (rawSpecs == null) {
      return null;
    }

    if (rawSpecs is Map<String, dynamic>) {
      return Map<String, dynamic>.from(rawSpecs);
    }

    if (rawSpecs is Map) {
      return rawSpecs.map((key, value) => MapEntry(key.toString(), value));
    }

    if (rawSpecs is List) {
      final map = <String, dynamic>{};
      for (final item in rawSpecs) {
        if (item is Map) {
          final key = item['key'] ?? item['name'] ?? item['label'];
          final value = item['value'] ?? item['spec'] ?? item['details'];
          if (key != null && value != null) {
            map[key.toString()] = value;
          }
        }
      }
      return map.isEmpty ? null : map;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'category': category,
      'name': name,
      'brand': brand,
      'price_bdt': priceBdt,
      'image_url': imageUrl,
      'primary_image_url': imageUrl,
      'availability_status': availabilityStatus,
      'popularity_score': popularityScore,
      'featured': featured == true ? 1 : 0,
      'specs': specs,
    };
  }

  Component copyWith({
    int? id,
    String? productId,
    String? category,
    String? name,
    String? brand,
    double? priceBdt,
    String? imageUrl,
    String? availabilityStatus,
    int? popularityScore,
    bool? featured,
    Map<String, dynamic>? specs,
  }) {
    return Component(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      category: category ?? this.category,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      priceBdt: priceBdt ?? this.priceBdt,
      imageUrl: imageUrl ?? this.imageUrl,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      popularityScore: popularityScore ?? this.popularityScore,
      featured: featured ?? this.featured,
      specs: specs ?? this.specs,
    );
  }
}
