import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeModel with ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;
  ThemeModel(FlutterSecureStorage storage) {
    setInit(storage);
  }

  setInit(storage) async {
    var dark = await storage.read(key: "dark");
    if (dark != null) {
      toggleMode(ThemeMode.dark);
    }
  }

  void toggleMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
