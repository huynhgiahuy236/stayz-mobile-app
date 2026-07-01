import 'dart:convert';

import 'package:flutter/services.dart';

class MockJsonLoader {
  const MockJsonLoader();

  Future<List<Map<String, dynamic>>> loadCollection(String collectionName) async {
    final rawJson = await rootBundle.loadString('assets/mock/$collectionName.json');
    final decoded = jsonDecode(rawJson) as List<dynamic>;

    return decoded.cast<Map<String, dynamic>>();
  }
}
