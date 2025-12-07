
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  static const String _key = 'isDarkMode';
  final GetStorage _box = GetStorage();

  /// Reactive dark mode boolean
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read<bool>(_key) ?? false;
  }

  /// Current theme mode
  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  /// Switch & persist theme
  void switchTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(themeMode);
    _box.write(_key, isDarkMode.value);
  }

  /// Icon used in AppBar/Menu
  IconData get themeIcon =>
      isDarkMode.value ? Icons.light_mode : Icons.dark_mode;
}
