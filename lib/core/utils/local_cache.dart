import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/visitor.dart';

/// Best-effort local storage; failures are swallowed so the app never
/// crashes because of the cache.
class LocalCache {
  LocalCache._();

  static const _visitorsKey = 'cached_visitors';
  static const _darkKey = 'dark_mode';

  static Future<void> saveVisitors(List<Visitor> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _visitorsKey,
        jsonEncode(list.map((v) => v.toCacheJson()).toList()),
      );
    } catch (_) {}
  }

  static Future<List<Visitor>> loadVisitors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_visitorsKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => Visitor.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> loadDarkMode() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_darkKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveDarkMode(bool v) async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_darkKey, v);
    } catch (_) {}
  }
}
