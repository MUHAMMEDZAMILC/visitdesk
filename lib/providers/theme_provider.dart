import 'package:flutter/material.dart';

import '../core/utils/local_cache.dart';

class ThemeProvider extends ChangeNotifier {
  bool _dark = false;

  bool get isDark => _dark;
  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _dark = await LocalCache.loadDarkMode();
    notifyListeners();
  }

  Future<void> toggle() async {
    _dark = !_dark;
    notifyListeners();
    await LocalCache.saveDarkMode(_dark);
  }
}
