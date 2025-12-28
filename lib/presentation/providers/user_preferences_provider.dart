import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../../core/services/local_storage_service.dart';
import 'component_provider.dart';

/// User Preferences State
class UserPreferencesState {
  final String currency;
  final String language;
  final bool notificationsEnabled;
  final bool priceAlertsEnabled;
  final bool buildCommentsEnabled;
  final bool buildLikesEnabled;
  final bool offlineMode;
  final bool autoDownloadImages;
  final DateTime? lastSyncTime;
  final bool isLoading;

  UserPreferencesState({
    this.currency = 'BDT',
    this.language = 'English',
    this.notificationsEnabled = true,
    this.priceAlertsEnabled = true,
    this.buildCommentsEnabled = true,
    this.buildLikesEnabled = true,
    this.offlineMode = false,
    this.autoDownloadImages = true,
    this.lastSyncTime,
    this.isLoading = false,
  });

  UserPreferencesState copyWith({
    String? currency,
    String? language,
    bool? notificationsEnabled,
    bool? priceAlertsEnabled,
    bool? buildCommentsEnabled,
    bool? buildLikesEnabled,
    bool? offlineMode,
    bool? autoDownloadImages,
    DateTime? lastSyncTime,
    bool? isLoading,
  }) {
    return UserPreferencesState(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
      buildCommentsEnabled: buildCommentsEnabled ?? this.buildCommentsEnabled,
      buildLikesEnabled: buildLikesEnabled ?? this.buildLikesEnabled,
      offlineMode: offlineMode ?? this.offlineMode,
      autoDownloadImages: autoDownloadImages ?? this.autoDownloadImages,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'language': language,
      'notifications_enabled': notificationsEnabled,
      'price_alerts_enabled': priceAlertsEnabled,
      'build_comments_enabled': buildCommentsEnabled,
      'build_likes_enabled': buildLikesEnabled,
      'offline_mode': offlineMode,
      'auto_download_images': autoDownloadImages,
    };
  }
}

/// User Preferences Notifier
class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  static const String _currencyKey = 'currency';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _priceAlertsKey = 'price_alerts_enabled';
  static const String _buildCommentsKey = 'build_comments_enabled';
  static const String _buildLikesKey = 'build_likes_enabled';
  static const String _offlineModeKey = 'offline_mode';
  static const String _autoDownloadImagesKey = 'auto_download_images';

  final LocalStorageService _localStorageService;
  final Logger _logger = Logger();

  UserPreferencesNotifier(this._localStorageService)
      : super(UserPreferencesState()) {
    _loadPreferences();
  }

  /// Load all preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSync = await _localStorageService.getLastSyncTime();

      state = UserPreferencesState(
        currency: prefs.getString(_currencyKey) ?? 'BDT',
        language: prefs.getString(_languageKey) ?? 'English',
        notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
        priceAlertsEnabled: prefs.getBool(_priceAlertsKey) ?? true,
        buildCommentsEnabled: prefs.getBool(_buildCommentsKey) ?? true,
        buildLikesEnabled: prefs.getBool(_buildLikesKey) ?? true,
        offlineMode: prefs.getBool(_offlineModeKey) ?? false,
        autoDownloadImages: prefs.getBool(_autoDownloadImagesKey) ?? true,
        lastSyncTime: lastSync,
      );
    } catch (e) {
      _logger.e('Failed to load preferences: $e');
    }
  }

  /// Set currency preference
  Future<void> setCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
      state = state.copyWith(currency: currency);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to set currency: $e');
    }
  }

  /// Set language preference
  Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      state = state.copyWith(language: language);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to set language: $e');
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
      state = state.copyWith(notificationsEnabled: enabled);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to toggle notifications: $e');
    }
  }

  /// Toggle price alerts
  Future<void> togglePriceAlerts(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_priceAlertsKey, enabled);
      state = state.copyWith(priceAlertsEnabled: enabled);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to toggle price alerts: $e');
    }
  }

  /// Toggle build comments notifications
  Future<void> toggleBuildComments(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_buildCommentsKey, enabled);
      state = state.copyWith(buildCommentsEnabled: enabled);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to toggle build comments: $e');
    }
  }

  /// Toggle build likes notifications
  Future<void> toggleBuildLikes(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_buildLikesKey, enabled);
      state = state.copyWith(buildLikesEnabled: enabled);

      // Sync with API when online
      _syncPreferencesWithAPI();
    } catch (e) {
      _logger.e('Failed to toggle build likes: $e');
    }
  }

  /// Toggle offline mode
  Future<void> toggleOfflineMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_offlineModeKey, enabled);
      await _localStorageService.setOfflineMode(enabled);
      state = state.copyWith(offlineMode: enabled);
    } catch (e) {
      _logger.e('Failed to toggle offline mode: $e');
    }
  }

  /// Toggle auto-download images
  Future<void> toggleAutoDownloadImages(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoDownloadImagesKey, enabled);
      state = state.copyWith(autoDownloadImages: enabled);
    } catch (e) {
      _logger.e('Failed to toggle auto-download images: $e');
    }
  }

  /// Update last sync time
  Future<void> updateLastSyncTime() async {
    try {
      final lastSync = await _localStorageService.getLastSyncTime();
      state = state.copyWith(lastSyncTime: lastSync);
    } catch (e) {
      _logger.e('Failed to update last sync time: $e');
    }
  }

  /// Sync preferences with API (when online)
  Future<void> _syncPreferencesWithAPI() async {
    // TODO: Implement API sync when backend endpoint is available
    // This would call PATCH /api/user/preferences with preferences data
    // For now, we just store locally
    _logger.d('Preferences updated (API sync not yet implemented)');
  }

  /// Sync preferences with API (public method for manual sync)
  Future<void> syncPreferencesWithAPI() async {
    if (state.offlineMode) {
      _logger.d('Offline mode enabled, skipping API sync');
      return;
    }

    // TODO: Implement API sync
    // try {
    //   final response = await apiClient.patch('/user/preferences', data: state.toJson());
    //   if (response.statusCode == 200) {
    //     _logger.d('Preferences synced with API successfully');
    //   }
    // } catch (e) {
    //   _logger.e('Failed to sync preferences with API: $e');
    // }
  }

  /// Refresh all preferences
  Future<void> refresh() async {
    await _loadPreferences();
  }
}

// Note: localStorageServiceProvider is now defined in component_provider.dart
// Import it from there to avoid duplication

/// User Preferences Provider
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return UserPreferencesNotifier(localStorageService);
});
