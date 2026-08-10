import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<bool> get enabled async => true;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    debugPrint("NurVerse Notification Service Initialized");
  }

  Future<void> setEnabled(bool enabled, dynamic prayers) async {
    debugPrint("Notification setEnabled: $enabled");
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint("Notification Sent: $title - $body");
  }
}
