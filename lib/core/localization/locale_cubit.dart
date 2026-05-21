import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../storage/local_storage_service.dart';
import '../storage/storage_keys.dart';
import 'supported_locales.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(this._storage) : super(readStored(_storage));

  final LocalStorageService _storage;

  static Locale readStored(LocalStorageService storage) {
    final saved =
        storage.getString(StorageKeys.currentLocale) ??
        StorageKeys.defaultLocale;
    final matched = SupportedLocales.values.where(
      (locale) => locale.languageCode == saved,
    );
    return matched.isNotEmpty ? matched.first : SupportedLocales.fallback;
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _storage.setString(StorageKeys.currentLocale, locale.languageCode);
  }
}
