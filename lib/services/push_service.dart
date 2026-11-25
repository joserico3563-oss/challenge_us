import 'dart:async';

import 'api_service.dart';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushService {
  static bool _ready = false;
  static String? _registeredToken;
  static StreamSubscription<String>? _subscription;

  static Future<void> connectAccount() async {
    if (!_ready || !ApiService.hasSession) return;

    try {
      await _subscription?.cancel();
      final token = await getToken();

      if (token == null || !ApiService.hasSession) return;

      await ApiService.registerPush(token);
      _registeredToken = token;

      _subscription = tokenRefresh.listen((newToken) async {
        if (!ApiService.hasSession) return;

        try {
          final previous = _registeredToken;
          if (previous != null && previous != newToken) {
            await ApiService.unregisterPush(previous);
          }

          if (!ApiService.hasSession) return;

          await ApiService.registerPush(newToken);
          _registeredToken = newToken;
        } catch (_) {
          debugPrint('Push token refresh failed.');
        }
      });
    } catch (_) {
      debugPrint('Push registration failed.');
    }
  }

  static Future<void> disconnectAccount() async {
    if (!_ready) return;

    await _subscription?.cancel();
    _subscription = null;

    final token =
        _registeredToken ?? await FirebaseMessaging.instance.getToken();

    if (token != null && ApiService.hasSession) {
      await ApiService.unregisterPush(token);
    }

    _registeredToken = null;

    try {
      await deleteToken();
    } catch (_) {
      debugPrint('Push token deletion failed.');
    }
  }

  static bool get available => _ready;

  static Future<void> initialize() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await Firebase.initializeApp();
      _ready = true;
      debugPrint('Firebase push initialized.');
    } catch (error) {
      debugPrint('Firebase initialization failed.');
    }
  }

  static Future<String?> getToken() async {
    if (!_ready) return null;

    final messaging = FirebaseMessaging.instance;

    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (permission.authorizationStatus != AuthorizationStatus.authorized &&
        permission.authorizationStatus != AuthorizationStatus.provisional) {
      return null;
    }

    return messaging.getToken();
  }

  static Future<void> deleteToken() async {
    if (!_ready) return;
    await FirebaseMessaging.instance.deleteToken();
  }

  static Stream<String> get tokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;
}
