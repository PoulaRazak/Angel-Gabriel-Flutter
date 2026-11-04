import 'dart:convert';
import 'package:http/http.dart' as http;
import '../cache/cache_helper.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;

  const ApiException(this.message, {this.statusCode = 400});

  @override
  String toString() => message;
}

class ApiClient {
  static const String baseUrl =
      'https://oatyiqiuyrxpfypiekhk.supabase.co/functions/v1/mobile-api';

  static const String publishableKey =
      'sb_publishable_9ad5sLij9x5YvtAD33pJdw_2ELU6E8y';

  static Map<String, String> _headers() {
    final token = CacheHelper.getToken();
    final userId = CacheHelper.getUserId();
    return {
      'Content-Type': 'application/json',
      'apikey': publishableKey,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (userId != null && userId.isNotEmpty) 'x-user-id': userId,
    };
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: _headers());
    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.put(
      uri,
      headers: _headers(),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final String rawBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (rawBody.isNotEmpty) {
      final dynamic jsonVal = jsonDecode(rawBody);
      if (jsonVal is Map<String, dynamic>) {
        decoded = jsonVal;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final String msg =
        (decoded['message'] ?? decoded['error'] ?? 'حدث خطأ في الاتصال بالخادم').toString();
    throw ApiException(msg, statusCode: response.statusCode);
  }
}
