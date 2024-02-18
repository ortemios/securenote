import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'json_node.dart';
export 'notes_api/notes_api.dart';
export 'json_node.dart';

abstract class Api {
  Future<T> get<T extends ApiResponse>({
    required String path,
    required Map<String, String> params,
    required T Function(JsonNode) mapper,
  }) async {
    return request(
      path: path,
      params: params,
      mapper: mapper,
      request: (uri, headers) => http.get(
        uri,
        headers: headers,
      ),
    );
  }

  Future<T> post<T extends ApiResponse>({
    required String path,
    required Map<dynamic, dynamic> body,
    required Map<String, String> params,
    required T Function(JsonNode) mapper,
  }) async {
    return request(
      path: path,
      params: params,
      mapper: mapper,
      request: (uri, headers) {
        debugPrint('Body: ${jsonEncode(body)}');
        return http.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      },
    );
  }

  Future<T> patch<T extends ApiResponse>({
    required String path,
    required Map<dynamic, dynamic> body,
    required Map<String, String> params,
    required T Function(JsonNode) mapper,
  }) async {
    return request(
      path: path,
      params: params,
      mapper: mapper,
      request: (uri, headers) {
        debugPrint('Body: ${jsonEncode(body)}');
        return http.patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
      },
    );
  }

  Future<T> delete<T extends ApiResponse>({
    required String path,
    required Map<String, String> params,
    required T Function(JsonNode) mapper,
  }) async {
    return request(
      path: path,
      params: params,
      mapper: mapper,
      request: (uri, headers) => http.delete(
        uri,
        headers: headers,
      ),
    );
  }

  Future<T> request<T extends ApiResponse>({
    required String path,
    Map<String, String> params = const {},
    Map<String, String> headers = const {},
    required T Function(JsonNode) mapper,
    required Future<http.Response> Function(Uri uri, Map<String, String> headers) request,
  }) async {
    try {
      final uri = Uri.parse(host + path).replace(queryParameters: params);
      debugPrint('Request URL: ${uri.toString()}');
      final response = await request(uri, headers);
      final body = response.body.isNotEmpty ? response.body : '{}';
      debugPrint('Response: $body');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = JsonNode(jsonDecode(body));
        final resp = mapper(json);
        if (resp.error == 0 && resp.status == 0) {
          return resp;
        } else {
          throw resp;
        }
      } else {
        throw response;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  String get host;
}

class ApiResponse {
  final int error, status;
  final String errorDescription, statusDescription;

  ApiResponse(JsonNode json)
      : error = json.optInt('error'),
        status = json.optInt('status'),
        errorDescription = json.optString('error_description'),
        statusDescription = json.optString('status_description');
}
