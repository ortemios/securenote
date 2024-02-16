import 'package:http/http.dart';
import 'package:secure_note/api/api.dart';

export 'requests/note.dart';

class NotesApi extends Api {
  String? _token;

  @override
  String get host => "http://127.0.0.1:8000/api";

  void setToken(String? token) {
    _token = token;
  }

  @override
  Future<T> request<T extends ApiResponse>({
    required String path,
    Map<String, String> headers = const {},
    Map<String, String> params = const {},
    required T Function(JsonNode p1) mapper,
    required Future<Response> Function(Uri uri) request,
  }) {
    final token = _token;
    if (token != null) {
      headers['Authorization-Bearer'] = token;
    }
    return super.request(
      path: path,
      params: params,
      mapper: mapper,
      request: request,
    );
  }

  static final inst = NotesApi();
}
