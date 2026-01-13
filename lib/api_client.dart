import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:madcamp_lounge/state/auth_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

class ApiClient {
  ApiClient(this._ref, {FlutterSecureStorage? storage, String? baseUrl})
      : _storage = storage ?? const FlutterSecureStorage(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8080';

  final Ref _ref;
  final FlutterSecureStorage _storage;
  final String _baseUrl;

  Future<http.Response> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool useAuth = true,
  }) async {
    return _send(
      'POST',
      path,
      headers: headers,
      body: body,
      useAuth: useAuth,
    );
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    bool useAuth = true,
  }) async {
    return _send(
      'GET',
      path,
      headers: headers,
      useAuth: useAuth,
    );
  }

  Future<http.Response> patchJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool useAuth = true,
  }) async {
    return _send(
      'PATCH',
      path,
      headers: headers,
      body: body,
      useAuth: useAuth,
    );
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    bool useAuth = true,
  }) async {
    return _send(
      'DELETE',
      path,
      headers: headers,
      useAuth: useAuth,
    );
  }

  Future<bool> refreshSession() async {
    return _tryRefreshToken();
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool useAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    if (useAuth) {
      final accessToken = _ref.read(accessTokenProvider);
      if (accessToken != null && accessToken.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $accessToken';
      }
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    http.Response response;
    if (method == 'GET') {
      response = await http.get(url, headers: requestHeaders);
    } else if (method == 'POST') {
      response = await http.post(url, headers: requestHeaders, body: encodedBody);
    } else if (method == 'PATCH') {
      response = await http.patch(url, headers: requestHeaders, body: encodedBody);
    } else if (method == 'DELETE') {
      response = await http.delete(url, headers: requestHeaders, body: encodedBody);
    } else {
      throw UnsupportedError('Unsupported method: $method');
    }

    if (!useAuth || response.statusCode != 401) {
      return response;
    }

    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      return response;
    }

    final newAccessToken = _ref.read(accessTokenProvider);
    if (newAccessToken != null && newAccessToken.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $newAccessToken';
    } else {
      requestHeaders.remove('Authorization');
    }

    if (method == 'GET') {
      return http.get(url, headers: requestHeaders);
    }
    if (method == 'POST') {
      return http.post(url, headers: requestHeaders, body: encodedBody);
    }
    if (method == 'PATCH') {
      return http.patch(url, headers: requestHeaders, body: encodedBody);
    }
    return http.delete(url, headers: requestHeaders, body: encodedBody);
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );
    if (response.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accessToken = data['accessToken'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    _ref.read(accessTokenProvider.notifier).state = accessToken;
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _storage.write(key: 'refreshToken', value: newRefreshToken);
    }
    return true;
  }
}
