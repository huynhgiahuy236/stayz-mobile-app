import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { vi, en }

/// Bo dieu khien ngon ngu toan app.
///
/// Doi ngon ngu -> notifyListeners -> MaterialApp (boc trong ListenableBuilder)
/// rebuild lai toan bo cay widget, nen moi cho dung `tr(...)` deu cap nhat.
/// Lua chon duoc luu vao SharedPreferences nen mo lai app van giu.
class AppLocale extends ChangeNotifier {
  AppLocale._();
  static final AppLocale instance = AppLocale._();

  static const _prefsKey = 'appLanguage';

  AppLanguage _language = AppLanguage.vi;
  AppLanguage get language => _language;
  bool get isVietnamese => _language == AppLanguage.vi;

  Locale get locale => _language == AppLanguage.vi ? const Locale('vi') : const Locale('en');

  String get label => _language == AppLanguage.vi ? 'Tiếng Việt' : 'English';

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

  /// Chon chuoi theo ngon ngu hien tai: `tr('Xin chào', 'Hello')`.
  String t(String vi, String en) => _language == AppLanguage.vi ? vi : en;
}

/// Ham tat cho nhanh, dung o bat ky dau: `tr('Xin chào', 'Hello')`.
String tr(String vi, String en) => AppLocale.instance.t(vi, en);
