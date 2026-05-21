import 'package:flutter/material.dart';

class SupportedLocales {
  SupportedLocales._();

  static const defaultLanguageCode = 'en';
  static const fallback = Locale('en');
  static const values = <Locale>[Locale('en'), Locale('bn')];
}
