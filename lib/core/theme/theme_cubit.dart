import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_storage_service.dart';
import '../storage/storage_keys.dart';

class ThemeModeCubit extends Cubit<ThemeMode> {
  ThemeModeCubit(this._storage) : super(readStored(_storage));

  final LocalStorageService _storage;

  static ThemeMode readStored(LocalStorageService storage) {
    final saved = storage.getString(StorageKeys.currentTheme);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    emit(mode);
    await _storage.setString(StorageKeys.currentTheme, mode.name);
  }
}
