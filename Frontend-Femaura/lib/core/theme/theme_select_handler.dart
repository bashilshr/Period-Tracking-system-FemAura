import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeSelectHandlerProvider =
    StateNotifierProvider<ThemeSelectHandler, ThemeMode>((ref) {
      return ThemeSelectHandler();
    });

class ThemeSelectHandler extends StateNotifier<ThemeMode> {
  ThemeSelectHandler() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
