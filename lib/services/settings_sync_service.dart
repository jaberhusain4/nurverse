import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Syncs NurVerse's local settings with the signed-in Google/Firebase account.
///
/// Settings remain local and offline-first. Firestore is only used as the
/// account backup/sync layer when a user is signed in.
class SettingsSyncService {
  SettingsSyncService._();

  static final SettingsSyncService instance = SettingsSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<void> syncCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final DocumentReference<Map<String, dynamic>> ref =
        _users.doc(user.uid).collection('private').doc('settings');

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await ref.get();

      if (snapshot.exists && snapshot.data() != null) {
        await _restoreToLocal(prefs, snapshot.data()!);
      } else {
        await _saveLocalToCloud(prefs, ref);
      }
    } catch (_) {
      // Settings are still fully usable offline if cloud sync is unavailable.
    }
  }

  Future<void> _saveLocalToCloud(
    SharedPreferences prefs,
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final Map<String, dynamic> settings = <String, dynamic>{};

    for (final String key in prefs.getKeys()) {
      final Object? value = prefs.get(key);
      if (value is String ||
          value is bool ||
          value is int ||
          value is double ||
          value is List<String>) {
        settings[key] = value;
      }
    }

    await ref.set(<String, dynamic>{
      'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _restoreToLocal(
    SharedPreferences prefs,
    Map<String, dynamic> cloudDocument,
  ) async {
    final dynamic rawSettings = cloudDocument['settings'];
    if (rawSettings is! Map) return;

    for (final MapEntry<dynamic, dynamic> entry in rawSettings.entries) {
      final String key = entry.key.toString();
      final dynamic value = entry.value;

      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List) {
        final List<String> strings = value
            .whereType<String>()
            .toList(growable: false);
        if (strings.length == value.length) {
          await prefs.setStringList(key, strings);
        }
      }
    }
  }
}
