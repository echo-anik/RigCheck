import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/build.dart';
import '../models/build_comment.dart';

class BuildRepository {
  final ApiClient _apiClient;

  BuildRepository(this._apiClient);

  /// Parse price from various formats
  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final sanitized = value.replaceAll(RegExp('[^0-9.]'), '');
      return double.tryParse(sanitized) ?? 0.0;
    }
    return 0.0;
  }

  /// Get user's builds
  Future<List<Build>> getMyBuilds({
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (page != null) {
        queryParams['page'] = page;
      }
      if (perPage != null) {
        queryParams['per_page'] = perPage;
      }

      final response = await _apiClient.get(
        ApiConstants.myBuilds,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        List<dynamic> data;
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          data = responseData['data'] as List;
        } else {
          print('Unexpected my builds response: ${responseData.runtimeType}');
          return [];
        }

        return data
            .map((json) {
              if (json is Map<String, dynamic>) {
                return Build.fromJson(json);
              } else if (json is Map) {
                return Build.fromJson(Map<String, dynamic>.from(json));
              }
              return null;
            })
            .whereType<Build>()
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching my builds: $e');
      rethrow;
    }
  }

  /// Get public builds (community feed)
  Future<List<Build>> getPublicBuilds({
    String? compatibilityStatus,
    String? useCase,
    String? search,
    double? minCost,
    double? maxCost,
    String? sortBy,
    String? sortOrder,
    int? page,
    int? perPage,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (compatibilityStatus != null) {
        queryParams['compatibility_status'] = compatibilityStatus;
      }
      if (useCase != null) {
        queryParams['use_case'] = useCase;
      }
      if (search != null) {
        queryParams['search'] = search;
      }
      if (minCost != null) {
        queryParams['min_cost'] = minCost;
      }
      if (maxCost != null) {
        queryParams['max_cost'] = maxCost;
      }
      if (sortBy != null) {
        queryParams['sort_by'] = sortBy;
      }
      if (sortOrder != null) {
        queryParams['sort_order'] = sortOrder;
      }
      if (page != null) {
        queryParams['page'] = page;
      }
      if (perPage != null) {
        queryParams['per_page'] = perPage;
      }

      final response = await _apiClient.get(
        ApiConstants.publicBuilds,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Handle different response structures
        List<dynamic> dataList;
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData['data'] != null) {
          dataList = responseData['data'] as List;
        } else {
          print('Unexpected response structure: ${responseData.runtimeType}');
          return [];
        }
        
        return dataList
            .map((json) {
              if (json is Map<String, dynamic>) {
                return Build.fromJson(json);
              } else if (json is Map) {
                return Build.fromJson(Map<String, dynamic>.from(json));
              } else {
                print('Invalid build data: ${json.runtimeType}');
                return null;
              }
            })
            .whereType<Build>()
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching public builds: $e');
      rethrow;
    }
  }

  /// Get build by ID
  Future<Build?> getBuildById(int id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.buildById(id),
      );

      if (response.statusCode == 200) {
        return Build.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error fetching build by ID: $e');
      rethrow;
    }
  }

  /// Create a new build
  /// New API expects components as array of objects with component_id, category, quantity, price_at_selection_bdt
  Future<Map<String, dynamic>> createBuild({
    required String buildName,
    String? description,
    required String useCase,
    required double budgetMaxBdt,
    String visibility = 'public',
    required List<Map<String, dynamic>> components,
  }) async {
    try {
      // Format components to match API expectations
      final formattedComponents = components.isNotEmpty
          ? components.map((comp) {
              // Extract numeric ID - try multiple fields
              dynamic componentId = comp['component_id'];
              if (componentId == null || componentId.toString().isEmpty) {
                componentId = comp['productId'] ?? comp['product_id'] ?? comp['id'];
              }
              
              // Ensure component_id is a numeric value or numeric string
              final idStr = componentId.toString();
              final id = int.tryParse(idStr) ?? idStr;

              return {
                'component_id': id,
                'category': comp['category'] ?? '',
                'quantity': comp['quantity'] ?? 1,
                'price_at_selection_bdt': _parsePrice(comp['price_at_selection_bdt'] ?? comp['price_bdt'] ?? comp['price']),
              };
            }).toList()
          : [];

      final response = await _apiClient.post(
        ApiConstants.builds,
        data: {
          'build_name': buildName,
          'description': description ?? '',
          'use_case': useCase,
          'budget_max_bdt': budgetMaxBdt,
          'visibility': visibility,
          'components': formattedComponents,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final build = Build.fromJson(
          response.data['build'] as Map<String, dynamic>,
        );
        return {
          'success': true,
          'build': build,
          'message': response.data['message'] as String? ?? 'Build created',
        };
      }

      return {
        'success': false,
        'message': 'Failed to create build',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Update an existing build
  /// Update an existing build (new API structure)
  Future<Map<String, dynamic>> updateBuild({
    required int id,
    String? buildName,
    String? description,
    String? useCase,
    double? budgetMaxBdt,
    String? visibility,
    List<Map<String, dynamic>>? components,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (buildName != null) data['build_name'] = buildName;
      if (description != null) data['description'] = description;
      if (useCase != null) data['use_case'] = useCase;
      if (budgetMaxBdt != null) data['budget_max_bdt'] = budgetMaxBdt;
      if (visibility != null) data['visibility'] = visibility;
      
      // Format components to match API expectations
      if (components != null && components.isNotEmpty) {
        data['components'] = components.map((comp) {
          // Extract numeric ID - try multiple fields
          dynamic componentId = comp['component_id'];
          if (componentId == null || componentId.toString().isEmpty) {
            componentId = comp['productId'] ?? comp['product_id'] ?? comp['id'];
          }
          
          // Ensure component_id is a numeric value or numeric string
          final idStr = componentId.toString();
          final id = int.tryParse(idStr) ?? idStr;

          return {
            'component_id': id,
            'category': comp['category'] ?? '',
            'quantity': comp['quantity'] ?? 1,
            'price_at_selection_bdt': _parsePrice(comp['price_at_selection_bdt'] ?? comp['price_bdt'] ?? comp['price']),
          };
        }).toList();
      }

      final response = await _apiClient.put(
        ApiConstants.buildById(id),
        data: data,
      );

      if (response.statusCode == 200) {
        final build = Build.fromJson(
          response.data['build'] as Map<String, dynamic>,
        );
        return {
          'success': true,
          'build': build,
          'message': response.data['message'] as String? ?? 'Build updated',
        };
      }

      return {
        'success': false,
        'message': 'Failed to update build',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete a build
  Future<bool> deleteBuild(int id) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.buildById(id),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete build: $e');
    }
  }

  /// Like a build
  Future<Map<String, dynamic>> likeBuild(int id) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.buildLike(id),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'like_count': response.data['like_count'] as int,
          'message': response.data['message'] as String,
        };
      }

      return {
        'success': false,
        'message': 'Failed to like build',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Unlike a build
  Future<Map<String, dynamic>> unlikeBuild(int id) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.buildLike(id),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'like_count': response.data['like_count'] as int,
          'message': response.data['message'] as String,
        };
      }

      return {
        'success': false,
        'message': 'Failed to unlike build',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Get comments for a build
  Future<List<BuildComment>> getBuildComments(int buildId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.buildComments(buildId),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data
            .map((json) => BuildComment.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Add a comment to a build
  Future<Map<String, dynamic>> addBuildComment({
    required int buildId,
    required String commentText,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.buildComments(buildId),
        data: {
          'comment_text': commentText,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final comment = BuildComment.fromJson(
          response.data['comment'] as Map<String, dynamic>,
        );
        return {
          'success': true,
          'comment': comment,
          'message': response.data['message'] as String? ?? 'Comment added',
        };
      }

      return {
        'success': false,
        'message': 'Failed to add comment',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(int commentId) async {
    try {
      final response = await _apiClient.delete(
        '/comments/$commentId',
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Increment view count for a build
  Future<bool> incrementViewCount(int buildId) async {
    try {
      final response = await _apiClient.post(
        '/builds/$buildId/view',
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Update build visibility
  Future<Map<String, dynamic>> updateVisibility({
    required int id,
    required String visibility,
  }) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.buildById(id),
        data: {
          'visibility': visibility,
        },
      );

      if (response.statusCode == 200) {
        final build = Build.fromJson(
          response.data['build'] as Map<String, dynamic>,
        );
        return {
          'success': true,
          'build': build,
          'message': response.data['message'] as String,
        };
      }

      return {
        'success': false,
        'message': 'Failed to update visibility',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
