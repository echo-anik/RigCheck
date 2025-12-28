import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Represents a queued sync action
class SyncAction {
  final String id;
  final String type; // 'like', 'unlike', 'comment', 'view', 'delete_comment'
  final String endpoint;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final int retryCount;

  SyncAction({
    required this.id,
    required this.type,
    required this.endpoint,
    this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'] as String,
      type: json['type'] as String,
      endpoint: json['endpoint'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'endpoint': endpoint,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  SyncAction copyWith({
    String? id,
    String? type,
    String? endpoint,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    int? retryCount,
  }) {
    return SyncAction(
      id: id ?? this.id,
      type: type ?? this.type,
      endpoint: endpoint ?? this.endpoint,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service for managing offline sync queue
class SyncQueueService {
  static const String _syncQueueBoxName = 'sync_queue';
  static const int _maxRetries = 3;

  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  Box<Map>? _syncQueueBox;
  bool _isSyncing = false;

  /// Initialize the sync queue service
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_syncQueueBoxName)) {
        _syncQueueBox = await Hive.openBox<Map>(_syncQueueBoxName);
      } else {
        _syncQueueBox = Hive.box<Map>(_syncQueueBoxName);
      }

      _logger.i('SyncQueueService initialized successfully');

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        if (!result.contains(ConnectivityResult.none)) {
          _logger.d('Connectivity restored, processing sync queue');
          processSyncQueue();
        }
      });
    } catch (e) {
      _logger.e('Failed to initialize SyncQueueService: $e');
      rethrow;
    }
  }

  /// Add an action to the sync queue
  Future<bool> queueAction({
    required String type,
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _ensureBoxOpen();

      final action = SyncAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        endpoint: endpoint,
        data: data,
        timestamp: DateTime.now(),
      );

      await _syncQueueBox!.put(action.id, action.toJson());
      _logger.d('Queued sync action: $type for $endpoint');

      return true;
    } catch (e) {
      _logger.e('Failed to queue sync action: $e');
      return false;
    }
  }

  /// Get all pending sync actions
  Future<List<SyncAction>> getPendingActions() async {
    try {
      await _ensureBoxOpen();

      final actions = <SyncAction>[];
      for (var entry in _syncQueueBox!.values) {
        try {
          final action = SyncAction.fromJson(
            Map<String, dynamic>.from(entry),
          );
          actions.add(action);
        } catch (e) {
          _logger.w('Failed to parse sync action: $e');
        }
      }

      // Sort by timestamp (oldest first)
      actions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return actions;
    } catch (e) {
      _logger.e('Failed to get pending actions: $e');
      return [];
    }
  }

  /// Get count of pending sync actions
  Future<int> getPendingCount() async {
    try {
      await _ensureBoxOpen();
      return _syncQueueBox!.length;
    } catch (e) {
      _logger.e('Failed to get pending count: $e');
      return 0;
    }
  }

  /// Remove a sync action from the queue
  Future<bool> removeAction(String actionId) async {
    try {
      await _ensureBoxOpen();
      await _syncQueueBox!.delete(actionId);
      _logger.d('Removed sync action: $actionId');
      return true;
    } catch (e) {
      _logger.e('Failed to remove sync action: $e');
      return false;
    }
  }

  /// Update retry count for an action
  Future<bool> incrementRetryCount(SyncAction action) async {
    try {
      await _ensureBoxOpen();

      final updatedAction = action.copyWith(
        retryCount: action.retryCount + 1,
      );

      await _syncQueueBox!.put(action.id, updatedAction.toJson());
      _logger.d('Incremented retry count for action: ${action.id}');

      return true;
    } catch (e) {
      _logger.e('Failed to increment retry count: $e');
      return false;
    }
  }

  /// Process the sync queue
  /// This should be called by your API client or a sync manager
  Future<void> processSyncQueue() async {
    if (_isSyncing) {
      _logger.d('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;

    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _logger.d('No internet connection, skipping sync');
        _isSyncing = false;
        return;
      }

      final pendingActions = await getPendingActions();
      if (pendingActions.isEmpty) {
        _logger.d('No pending sync actions');
        _isSyncing = false;
        return;
      }

      _logger.i('Processing ${pendingActions.length} pending sync actions');

      // Note: Actual API calls should be made by the repository layer
      // This service just manages the queue
      // The actual syncing logic should be implemented in a separate sync manager
      // that uses this service

    } catch (e) {
      _logger.e('Error processing sync queue: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Clear all sync actions
  Future<bool> clearQueue() async {
    try {
      await _ensureBoxOpen();
      await _syncQueueBox!.clear();
      _logger.d('Cleared sync queue');
      return true;
    } catch (e) {
      _logger.e('Failed to clear sync queue: $e');
      return false;
    }
  }

  /// Get sync queue statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final actions = await getPendingActions();

      final stats = <String, int>{};
      for (var action in actions) {
        stats[action.type] = (stats[action.type] ?? 0) + 1;
      }

      return {
        'total': actions.length,
        'by_type': stats,
        'oldest': actions.isNotEmpty
            ? actions.first.timestamp.toIso8601String()
            : null,
      };
    } catch (e) {
      _logger.e('Failed to get sync stats: $e');
      return {
        'total': 0,
        'by_type': {},
        'oldest': null,
      };
    }
  }

  /// Check if there are failed actions (exceeded max retries)
  Future<List<SyncAction>> getFailedActions() async {
    try {
      final actions = await getPendingActions();
      return actions.where((a) => a.retryCount >= _maxRetries).toList();
    } catch (e) {
      _logger.e('Failed to get failed actions: $e');
      return [];
    }
  }

  /// Remove failed actions from queue
  Future<bool> clearFailedActions() async {
    try {
      final failedActions = await getFailedActions();
      for (var action in failedActions) {
        await removeAction(action.id);
      }
      _logger.d('Cleared ${failedActions.length} failed actions');
      return true;
    } catch (e) {
      _logger.e('Failed to clear failed actions: $e');
      return false;
    }
  }

  /// Ensure the box is open
  Future<void> _ensureBoxOpen() async {
    if (_syncQueueBox == null || !_syncQueueBox!.isOpen) {
      await init();
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    try {
      if (_syncQueueBox?.isOpen == true) {
        await _syncQueueBox!.close();
      }
      _logger.i('SyncQueueService disposed');
    } catch (e) {
      _logger.e('Failed to dispose SyncQueueService: $e');
    }
  }
}
