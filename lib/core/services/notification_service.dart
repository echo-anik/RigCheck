import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smart notification service for social interactions
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _firebaseMessaging;

  final StreamController<Map<String, dynamic>> _notificationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  /// Initialize all notification services
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _loadNotificationsFromStorage();
  }

  /// Initialize Flutter Local Notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    const AndroidNotificationChannel socialChannel = AndroidNotificationChannel(
      'social_channel',
      'Social Notifications',
      description: 'Notifications for likes, comments, and shares',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel commentChannel = AndroidNotificationChannel(
      'comment_channel',
      'Comment Notifications',
      description: 'Notifications for new comments',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel buildChannel = AndroidNotificationChannel(
      'build_channel',
      'Build Updates',
      description: 'Notifications for build updates',
      importance: Importance.defaultImportance,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(socialChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(commentChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(buildChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      _notificationStreamController.add(data);
    }
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFirebaseMessaging() async {
    try {
      // Try to get Firebase Messaging instance
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Request permission
      await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM token
      final token = await _firebaseMessaging!.getToken();
      print('✅ FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      print('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      print('⚠️ Firebase Messaging not available - push notifications disabled');
      print('Error: $e');
      _firebaseMessaging = null;
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _showLocalNotification({
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': notification.title ?? 'New Notification',
        'body': notification.body ?? '',
        'type': data['type'] ?? 'general',
        ...data,
      });
    }
  }

  /// Handle background message tap
  void _handleBackgroundMessage(RemoteMessage message) {
    _notificationStreamController.add(message.data);
  }

  /// Show local notification
  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    final type = data['type'] as String;
    String channelKey = 'social_channel';
    String emoji = '🔔';

    switch (type) {
      case 'like':
        channelKey = 'social_channel';
        emoji = '❤️';
        break;
      case 'comment':
        channelKey = 'comment_channel';
        emoji = '💬';
        break;
      case 'share':
        channelKey = 'social_channel';
        emoji = '🔗';
        break;
      case 'build_update':
        channelKey = 'build_channel';
        emoji = '🔧';
        break;
      default:
        channelKey = 'social_channel';
    }

    const androidDetails = AndroidNotificationDetails(
      'social_channel',
      'Social Notifications',
      channelDescription: 'Notifications for social interactions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      data['id'].hashCode,
      '$emoji ${data['title']}',
      data['body'],
      details,
      payload: jsonEncode({
        'type': type,
        'buildId': data['buildId']?.toString() ?? '',
        'senderId': data['senderId']?.toString() ?? '',
      }),
    );

    // Add to internal list
    _addNotification(NotificationModel.fromMap(data));
  }

  /// Add notification to internal list
  void _addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    _saveNotificationsToStorage();
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      await _saveNotificationsToStorage();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    await _saveNotificationsToStorage();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      _notifications.removeAt(index);
      await _saveNotificationsToStorage();
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    _unreadCount = 0;
    await _saveNotificationsToStorage();
    await _localNotifications.cancelAll();
  }

  /// Load notifications from storage
  Future<void> _loadNotificationsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('notifications');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _notifications = jsonList.map((json) => NotificationModel.fromMap(json)).toList();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  /// Save notifications to storage
  Future<void> _saveNotificationsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_notifications.map((n) => n.toMap()).toList());
      await prefs.setString('notifications', jsonString);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  /// Group notifications by date
  Map<String, List<NotificationModel>> groupByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeek = today.subtract(const Duration(days: 7));

    final Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Older': [],
    };

    for (final notification in _notifications) {
      final notificationDate = DateTime(
        notification.timestamp.year,
        notification.timestamp.month,
        notification.timestamp.day,
      );

      if (notificationDate.isAtSameMomentAs(today)) {
        grouped['Today']!.add(notification);
      } else if (notificationDate.isAtSameMomentAs(yesterday)) {
        grouped['Yesterday']!.add(notification);
      } else if (notificationDate.isAfter(thisWeek)) {
        grouped['This Week']!.add(notification);
      } else {
        grouped['Older']!.add(notification);
      }
    }

    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  void dispose() {
    _notificationStreamController.close();
  }
}

/// Notification Model
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String? buildId;
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.buildId,
    this.senderId,
    this.senderName,
    this.senderAvatar,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'general',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      buildId: map['buildId'],
      senderId: map['senderId'],
      senderName: map['senderName'],
      senderAvatar: map['senderAvatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'buildId': buildId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? buildId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      buildId: buildId ?? this.buildId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  String get timeAgo {
    final duration = DateTime.now().difference(timestamp);
    if (duration.inSeconds < 60) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays < 7) return '${duration.inDays}d ago';
    if (duration.inDays < 30) return '${(duration.inDays / 7).floor()}w ago';
    return '${(duration.inDays / 30).floor()}mo ago';
  }

  String get icon {
    switch (type) {
      case 'like':
        return '❤️';
      case 'comment':
        return '💬';
      case 'share':
        return '🔗';
      case 'build_update':
        return '🔧';
      default:
        return '🔔';
    }
  }
}
