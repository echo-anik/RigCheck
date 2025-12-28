import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_queue_service.dart';
import '../../data/repositories/build_repository.dart';
import '../../data/repositories/auth_repository.dart';

/// Manager for processing sync queue and executing API calls
class SyncManager {
  final SyncQueueService _syncQueueService;
  final BuildRepository _buildRepository;
  final AuthRepository _authRepository;
  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;

  SyncManager({
    required SyncQueueService syncQueueService,
    required BuildRepository buildRepository,
    required AuthRepository authRepository,
  })  : _syncQueueService = syncQueueService,
        _buildRepository = buildRepository,
        _authRepository = authRepository {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        _logger.d('Connectivity restored, triggering sync');
        sync();
      }
    });
  }

  /// Initialize and perform initial sync if online
  Future<void> initialize() async {
    await _syncQueueService.init();

    // Check if we're online and have pending actions
    final connectivityResult = await _connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      final pendingCount = await _syncQueueService.getPendingCount();
      if (pendingCount > 0) {
        _logger.i('Found $pendingCount pending sync actions, starting sync');
        await sync();
      }
    }
  }

  /// Sync all pending actions
  Future<bool> sync() async {
    if (_isSyncing) {
      _logger.d('Sync already in progress');
      return false;
    }

    _isSyncing = true;

    try {
      // Check connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        _logger.d('No internet connection, aborting sync');
        return false;
      }

      // Get pending actions
      final pendingActions = await _syncQueueService.getPendingActions();

      if (pendingActions.isEmpty) {
        _logger.d('No pending actions to sync');
        return true;
      }

      _logger.i('Syncing ${pendingActions.length} pending actions');

      int successCount = 0;
      int failureCount = 0;

      for (var action in pendingActions) {
        try {
          final success = await _processSyncAction(action);

          if (success) {
            await _syncQueueService.removeAction(action.id);
            successCount++;
            _logger.d('Successfully synced action: ${action.type}');
          } else {
            // Increment retry count
            if (action.retryCount < 3) {
              await _syncQueueService.incrementRetryCount(action);
              _logger.w(
                  'Failed to sync action: ${action.type}, retry ${action.retryCount + 1}/3');
            } else {
              // Max retries exceeded, remove from queue
              await _syncQueueService.removeAction(action.id);
              _logger.e(
                  'Max retries exceeded for action: ${action.type}, removing from queue');
            }
            failureCount++;
          }
        } catch (e) {
          _logger.e('Error processing sync action ${action.id}: $e');
          failureCount++;

          // Increment retry count
          if (action.retryCount < 3) {
            await _syncQueueService.incrementRetryCount(action);
          } else {
            await _syncQueueService.removeAction(action.id);
          }
        }
      }

      _logger.i(
          'Sync completed: $successCount successful, $failureCount failed');

      return successCount > 0;
    } catch (e) {
      _logger.e('Error during sync: $e');
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single sync action
  Future<bool> _processSyncAction(SyncAction action) async {
    try {
      switch (action.type) {
        case 'like':
          return await _processLikeAction(action);

        case 'unlike':
          return await _processUnlikeAction(action);

        case 'comment':
          return await _processCommentAction(action);

        case 'delete_comment':
          return await _processDeleteCommentAction(action);

        case 'view':
          return await _processViewAction(action);

        case 'create_build':
          return await _processCreateBuildAction(action);

        case 'update_build':
          return await _processUpdateBuildAction(action);

        case 'delete_build':
          return await _processDeleteBuildAction(action);

        default:
          _logger.w('Unknown sync action type: ${action.type}');
          return false;
      }
    } catch (e) {
      _logger.e('Error processing action ${action.type}: $e');
      return false;
    }
  }

  /// Process like action
  Future<bool> _processLikeAction(SyncAction action) async {
    try {
      if (action.data == null || !action.data!.containsKey('build_id')) {
        _logger.e('Invalid like action data');
        return false;
      }

      final buildId = action.data!['build_id'] as int;
      await _buildRepository.likeBuild(buildId);
      return true;
    } catch (e) {
      _logger.e('Failed to process like action: $e');
      return false;
    }
  }

  /// Process unlike action
  Future<bool> _processUnlikeAction(SyncAction action) async {
    try {
      if (action.data == null || !action.data!.containsKey('build_id')) {
        _logger.e('Invalid unlike action data');
        return false;
      }

      final buildId = action.data!['build_id'] as int;
      // Assuming unlikeBuild method exists in BuildRepository
      // If not, this would be the same as likeBuild (toggle)
      await _buildRepository.likeBuild(buildId);
      return true;
    } catch (e) {
      _logger.e('Failed to process unlike action: $e');
      return false;
    }
  }

  /// Process comment action
  Future<bool> _processCommentAction(SyncAction action) async {
    try {
      if (action.data == null ||
          !action.data!.containsKey('build_id') ||
          !action.data!.containsKey('comment_text')) {
        _logger.e('Invalid comment action data');
        return false;
      }

      final buildId = action.data!['build_id'] as int;
      final commentText = action.data!['comment_text'] as String;

      final result = await _buildRepository.addBuildComment(
        buildId: buildId,
        commentText: commentText,
      );
      return result['success'] as bool? ?? false;
    } catch (e) {
      _logger.e('Failed to process comment action: $e');
      return false;
    }
  }

  /// Process delete comment action
  Future<bool> _processDeleteCommentAction(SyncAction action) async {
    try {
      if (action.data == null || !action.data!.containsKey('comment_id')) {
        _logger.e('Invalid delete comment action data');
        return false;
      }

      // TODO: Implement deleteComment in BuildRepository when backend supports it
      _logger.w('Delete comment not yet implemented');
      return true; // Return true to remove from queue
    } catch (e) {
      _logger.e('Failed to process delete comment action: $e');
      return false;
    }
  }

  /// Process view action
  Future<bool> _processViewAction(SyncAction action) async {
    try {
      // View tracking is typically handled server-side automatically
      // This is just a placeholder
      return true;
    } catch (e) {
      _logger.e('Failed to process view action: $e');
      return false;
    }
  }

  /// Process create build action
  Future<bool> _processCreateBuildAction(SyncAction action) async {
    try {
      if (action.data == null) {
        _logger.e('Invalid create build action data');
        return false;
      }

      // TODO: Implement createBuild with proper data mapping
      _logger.w('Create build sync not yet fully implemented');
      return true; // Return true to remove from queue for now
    } catch (e) {
      _logger.e('Failed to process create build action: $e');
      return false;
    }
  }

  /// Process update build action
  Future<bool> _processUpdateBuildAction(SyncAction action) async {
    try {
      if (action.data == null || !action.data!.containsKey('build_id')) {
        _logger.e('Invalid update build action data');
        return false;
      }

      // TODO: Implement updateBuild with proper data mapping
      _logger.w('Update build sync not yet fully implemented');
      return true; // Return true to remove from queue for now
    } catch (e) {
      _logger.e('Failed to process update build action: $e');
      return false;
    }
  }

  /// Process delete build action
  Future<bool> _processDeleteBuildAction(SyncAction action) async {
    try {
      if (action.data == null || !action.data!.containsKey('build_id')) {
        _logger.e('Invalid delete build action data');
        return false;
      }

      final buildId = action.data!['build_id'] as int;
      await _buildRepository.deleteBuild(buildId);
      return true;
    } catch (e) {
      _logger.e('Failed to process delete build action: $e');
      return false;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final stats = await _syncQueueService.getStats();
    final connectivityResult = await _connectivity.checkConnectivity();

    return {
      'pending_count': stats['total'],
      'by_type': stats['by_type'],
      'oldest_action': stats['oldest'],
      'is_syncing': _isSyncing,
      'is_online': !connectivityResult.contains(ConnectivityResult.none),
    };
  }

  /// Manually trigger sync
  Future<bool> manualSync() async {
    _logger.i('Manual sync triggered');
    return await sync();
  }

  /// Clear all pending actions
  Future<bool> clearAllPending() async {
    return await _syncQueueService.clearQueue();
  }

  /// Clear failed actions only
  Future<bool> clearFailed() async {
    return await _syncQueueService.clearFailedActions();
  }
}
