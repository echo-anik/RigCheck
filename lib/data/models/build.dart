import 'component.dart';

class Build {
  final int? id;
  final String? uuid;
  final String name;
  final String? description;
  final String? useCase;
  final double totalCost;
  final int? totalTdp;
  final String compatibilityStatus;
  final bool isFavorite;
  final String visibility;
  final Map<String, Component> components;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Social features
  final String? shareToken;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isLikedByUser;
  final String? userName;
  final String? userAvatar;

  Build({
    this.id,
    this.uuid,
    required this.name,
    this.description,
    this.useCase,
    required this.totalCost,
    this.totalTdp,
    this.compatibilityStatus = 'valid',
    this.isFavorite = false,
    this.visibility = 'private',
    this.components = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.shareToken,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isLikedByUser = false,
    this.userName,
    this.userAvatar,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Build.empty() {
    return Build(
      name: 'New Build',
      totalCost: 0.0,
      components: {},
    );
  }

  factory Build.fromJson(Map<String, dynamic> json) {
    final components = _parseComponents(json['components']);

    return Build(
      id: json['id'] as int?,
      uuid: json['uuid'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      useCase: json['use_case'] as String?,
      totalCost: _parseDouble(json['total_cost'] ?? json['total_cost_bdt'] ?? json['budget_max_bdt']),
      totalTdp: _parseInt(json['total_tdp']),
      compatibilityStatus: (json['compatibility_status'] ?? json['status']) as String? ?? 'valid',
      isFavorite: json['is_favorite'] == 1 || json['is_favorite'] == true,
      visibility: json['visibility'] as String? ?? 'private',
      components: components,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      shareToken: json['share_token'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      isLikedByUser: json['is_liked_by_user'] == 1 || json['is_liked_by_user'] == true,
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
    );
  }

  static Map<String, Component> _parseComponents(dynamic rawComponents) {
    final parsedComponents = <String, Component>{};

    if (rawComponents is Map) {
      for (final entry in rawComponents.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        final componentMap = _ensureComponentMap(value);
        if (componentMap != null) {
          try {
            parsedComponents[key.isEmpty ? 'component_${parsedComponents.length}' : key] = Component.fromJson(componentMap);
          } catch (_) {
            // Ignore malformed component entries from older payloads.
          }
        }
      }
      return parsedComponents;
    }

    if (rawComponents is List) {
      for (final item in rawComponents) {
        final componentMap = _ensureComponentMap(item);
        if (componentMap == null) {
          continue;
        }

        // Fall back to category in wrapper when missing on the component itself.
        final wrapperCategory = _extractCategory(item);
        componentMap.putIfAbsent('category', () => wrapperCategory ?? componentMap['category'] ?? 'unknown');

        final category = componentMap['category']?.toString() ?? 'component_${parsedComponents.length}';
        try {
          parsedComponents[category] = Component.fromJson(componentMap);
        } catch (_) {
          // Skip invalid component.
        }
      }
    }

    return parsedComponents;
  }

  static Map<String, dynamic>? _ensureComponentMap(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is Map || raw is Map<String, dynamic>) {
      final map = raw is Map<String, dynamic>
          ? Map<String, dynamic>.from(raw)
          : (raw as Map).map((key, value) => MapEntry(key.toString(), value));

      for (final nestedKey in ['component', 'component_data', 'component_details']) {
        final nestedValue = map[nestedKey];
        if (nestedValue is Map || nestedValue is Map<String, dynamic>) {
          final nestedMap = _ensureComponentMap(nestedValue);
          if (nestedMap != null) {
            map.remove(nestedKey);
            for (final entry in map.entries) {
              nestedMap.putIfAbsent(entry.key, () => entry.value);
            }
            return nestedMap;
          }
        }
      }

      if (!map.containsKey('product_id')) {
        final fallbackId = map['component_id'] ?? map['id'];
        if (fallbackId != null) {
          map['product_id'] = fallbackId.toString();
        }
      }

      return map;
    }

    if (raw is List) {
      // Some payloads return a list of key/value pairs; attempt to convert.
      final map = <String, dynamic>{};
      for (final item in raw) {
        if (item is Map && item.containsKey('key') && item.containsKey('value')) {
          map[item['key'].toString()] = item['value'];
        }
      }
      return map.isEmpty ? null : map;
    }

    return null;
  }

  static String? _extractCategory(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return (raw['category'] ?? raw['component_category'] ?? raw['component_type'])?.toString();
    }
    if (raw is Map) {
      final dynamic category = raw['category'] ?? raw['component_category'] ?? raw['component_type'];
      return category?.toString();
    }
    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final sanitized = value.replaceAll(RegExp('[^0-9\.]'), '');
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final sanitized = value.replaceAll(RegExp('[^0-9]'), '');
      return int.tryParse(sanitized);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'description': description,
      'use_case': useCase,
      'total_cost': totalCost,
      'total_tdp': totalTdp,
      'compatibility_status': compatibilityStatus,
      'is_favorite': isFavorite ? 1 : 0,
      'visibility': visibility,
      'components': components.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'share_token': shareToken,
      'like_count': likeCount,
      'comment_count': commentCount,
      'view_count': viewCount,
      'is_liked_by_user': isLikedByUser ? 1 : 0,
      'user_name': userName,
      'user_avatar': userAvatar,
    };
  }

  /// Convert components to API format (array of objects with component_id, category, quantity, price)
  List<Map<String, dynamic>> getComponentsForApi() {
    return components.entries
        .map((entry) {
          final category = entry.key;
          final component = entry.value;
          return {
            'component_id': component.productId,
            'category': category,
            'quantity': 1,
            'price_at_selection_bdt': component.priceBdt,
          };
        })
        .toList();
  }

  Build copyWith({
    int? id,
    String? uuid,
    String? name,
    String? description,
    String? useCase,
    double? totalCost,
    int? totalTdp,
    String? compatibilityStatus,
    bool? isFavorite,
    String? visibility,
    Map<String, Component>? components,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shareToken,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isLikedByUser,
    String? userName,
    String? userAvatar,
  }) {
    return Build(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      useCase: useCase ?? this.useCase,
      totalCost: totalCost ?? this.totalCost,
      totalTdp: totalTdp ?? this.totalTdp,
      compatibilityStatus: compatibilityStatus ?? this.compatibilityStatus,
      isFavorite: isFavorite ?? this.isFavorite,
      visibility: visibility ?? this.visibility,
      components: components ?? this.components,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shareToken: shareToken ?? this.shareToken,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  int get componentCount => components.length;

  bool get isValid => compatibilityStatus == 'valid';

  bool? get isPublic => visibility == 'public';

  bool hasComponent(String category) => components.containsKey(category);

  Component? getComponent(String category) => components[category];

  Build addComponent(String category, Component component) {
    final newComponents = Map<String, Component>.from(components);
    newComponents[category] = component;

    final newCost = totalCost + (component.priceBdt ?? 0);
    final newTdp = _calculateTdp(newComponents);

    return copyWith(
      components: newComponents,
      totalCost: newCost,
      totalTdp: newTdp,
      updatedAt: DateTime.now(),
    );
  }

  Build removeComponent(String category) {
    if (!hasComponent(category)) return this;

    final newComponents = Map<String, Component>.from(components);
    final removedComponent = newComponents.remove(category);

    final newCost = totalCost - (removedComponent?.priceBdt ?? 0);
    final newTdp = _calculateTdp(newComponents);

    return copyWith(
      components: newComponents,
      totalCost: newCost,
      totalTdp: newTdp,
      updatedAt: DateTime.now(),
    );
  }

  int _calculateTdp(Map<String, Component> components) {
    int tdp = 0;

    // Add CPU TDP
    final cpu = components['cpu'];
    if (cpu?.specs?['tdp'] != null) {
      final cpuTdp = cpu!.specs!['tdp'];
      tdp += cpuTdp is int ? cpuTdp : int.tryParse(cpuTdp.toString()) ?? 0;
    }

    // Add GPU TDP (estimate based on model or from specs)
    final gpu = components['video-card'];
    if (gpu != null) {
      if (gpu.specs?['tdp'] != null) {
        final gpuTdp = gpu.specs!['tdp'];
        tdp += gpuTdp is int ? gpuTdp : int.tryParse(gpuTdp.toString()) ?? 250;
      } else {
        tdp += 250; // Default GPU TDP
      }
    }

    // Add other components (motherboard, RAM, storage, etc.)
    tdp += components.length * 10; // ~10W per additional component

    return tdp;
  }

  int get recommendedPsuWattage {
    if (totalTdp == null || totalTdp == 0) return 500;
    return ((totalTdp! + 100) * 1.2).ceil();
  }
}
