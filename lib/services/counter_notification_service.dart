import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class CounterNotificationService {
  CounterNotificationService();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'counter_orders_channel';
  static const String _channelName = 'Counter - Orders';
  static const String _channelDesc = 'Notifications for new orders placed by waiters';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  Future<void> init() async {
    debugPrint('CounterNotificationService.init: starting');

    final androidInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse r) {
        debugPrint('CounterNotificationService: notification tapped payload=${r.payload}');
      },
    );

    final androidImpl = _fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      // create channel (safe even if previously created)
      final channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.max,
      );
      try {
        await androidImpl.createNotificationChannel(channel);
        debugPrint('CounterNotificationService: Android channel created');
      } catch (e, st) {
        debugPrint('CounterNotificationService: channel creation failed: $e\n$st');
      }
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.notification.status;
        debugPrint('CounterNotificationService: notification permission current status = $status');

        if (!status.isGranted) {
          final result = await Permission.notification.request();
          debugPrint('CounterNotificationService: permission.request result = $result');

          if (result.isPermanentlyDenied) {
            debugPrint('CounterNotificationService: permission permanently denied - user must enable in settings');
          }
        }
      }
    } catch (e, st) {
      debugPrint('CounterNotificationService: permission check/request failed: $e\n$st');
    }
  }

  Future<void> startListening() async {
    debugPrint('CounterNotificationService.startListening: registering listener');

    await _ordersSub?.cancel();

    final startTime = DateTime.now().subtract(const Duration(seconds: 5));

    _ordersSub = FirebaseFirestore.instance
        .collection('orders')
        .where('createdAt', isGreaterThan: startTime)
        .snapshots()
        .listen(_onOrdersSnapshot, onError: (e, st) {
      debugPrint('CounterNotificationService: orders listener error: $e\n$st');
    }, cancelOnError: false);
  }

  void _onOrdersSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.metadata.isFromCache) return;

    for (final change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final doc = change.doc;
        final data = doc.data();
        
        if (doc.metadata.hasPendingWrites) continue;

        final table = data?['tableNumber']?.toString() ?? '—';
        final orderNumber = data?['orderNumber'] ?? doc.id;
        final title = 'NEW ORDER • TABLE $table';
        final body = 'Order $orderNumber has been placed.';
        _showNotification(doc.id, title, body);
      }
    }
  }

  Future<void> stopListening() async {
    await _ordersSub?.cancel();
    _ordersSub = null;
    debugPrint('CounterNotificationService: stopped listening');
  }

  Future<void> _showNotification(String id, String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      final notifId = id.hashCode & 0x7fffffff;
      await _fln.show(notifId, title, body, details, payload: id);
      debugPrint('CounterNotificationService: notification shown for $id');
    } catch (e, st) {
      debugPrint('CounterNotificationService: show notification failed: $e\n$st');
    }
  }
}
