import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { vi, en }

class AppLocale extends ChangeNotifier {
  AppLocale._();
  static final AppLocale instance = AppLocale._();

  static const _prefsKey = 'appLanguage';

  AppLanguage _language = AppLanguage.vi;
  AppLanguage get language => _language;
  bool get isVietnamese => _language == AppLanguage.vi;
  Locale get locale => isVietnamese ? const Locale('vi') : const Locale('en');
  String get label => isVietnamese ? 'Tiếng Việt' : 'English';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_prefsKey) == 'en' ? AppLanguage.en : AppLanguage.vi;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language == AppLanguage.en ? 'en' : 'vi');
  }

  String t(String vi, String en) => repairMojibake(isVietnamese ? vi : en);
}

/// Repairs the common legacy case where UTF-8 Vietnamese was decoded as
/// Latin-1. Correct Vietnamese text is returned unchanged.
String repairMojibake(String value) {
  final looksBroken =
      value.contains('Ã') || value.contains('Â') || value.contains('áº') || value.contains('á»');
  if (!looksBroken) return value;

  try {
    final repaired = utf8.decode(latin1.encode(value));
    return repaired.contains('\uFFFD') ? value : repaired;
  } catch (_) {
    return value;
  }
}

String tr(String vi, String en) => AppLocale.instance.t(vi, en);
