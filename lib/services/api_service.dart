import 'dart:convert';
import 'dart:io';

class ApiService {
  const ApiService({
    this.baseUrl = const String.fromEnvironment(
      'STAYZ_API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000/api',
    ),
  });

  final String baseUrl;

  Uri get baseUri => Uri.parse(baseUrl);

  String resolveAssetUrl(String value) {
    if (value.isEmpty) return value;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;

    final origin = baseUri.replace(path: '', query: '', fragment: '');
    final path = value.startsWith('/') ? value : '/$value';
    return origin.replace(path: path).toString();
  }

  Future<dynamic> get(String path, {String? bearerToken}) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();

    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      }

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('GET $uri failed: ${response.statusCode} $body', uri: uri);
      }

      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return decoded['metaData'];
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();

    try {
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      }
      request.write(jsonEncode(body ?? const <String, dynamic>{}));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic> ? decoded['message']?.toString() : null;
        throw HttpException(message ?? 'POST $uri failed: ${response.statusCode}', uri: uri);
      }

      if (decoded is Map<String, dynamic>) return decoded['metaData'];
      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> delete(String path, {String? bearerToken}) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();

    try {
      final request = await client.deleteUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic> ? decoded['message']?.toString() : null;
        throw HttpException(message ?? 'DELETE $uri failed: ${response.statusCode}', uri: uri);
      }

      if (decoded is Map<String, dynamic>) return decoded['metaData'];
      return decoded;
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();

    try {
      final request = await client.patchUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (bearerToken != null && bearerToken.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
      }
      request.write(jsonEncode(body ?? const <String, dynamic>{}));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = responseBody.isEmpty ? null : jsonDecode(responseBody);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic> ? decoded['message']?.toString() : null;
        throw HttpException(message ?? 'PATCH $uri failed: ${response.statusCode}', uri: uri);
      }

      if (decoded is Map<String, dynamic>) return decoded['metaData'];
      return decoded;
    } finally {
      client.close(force: true);
    }
  }
}
