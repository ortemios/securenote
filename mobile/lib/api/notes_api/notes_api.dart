import 'package:http/http.dart';
import 'package:secure_note/api/api.dart';

export 'requests/notes.dart';

class NotesApi extends Api {
  String? _token;

  @override
  String get host => "http://127.0.0.1:8000/";

  void setToken(String? token) {
    _token = token;
  }

  @override
  Future<T> request<T extends ApiResponse>({
    required String path,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    required T Function(JsonNode p1) mapper,
    required Future<Response> Function(Uri uri, Map<String, String> headers) request,
  }) {
    final token = _token;
    headers = Map.from(headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    headers['Content-Type'] = 'application/json';
    return super.request(
      path: path,
      params: params,
      mapper: mapper,
      request: request,
      headers: headers,
    );
  }

  static final inst = NotesApi();
}
