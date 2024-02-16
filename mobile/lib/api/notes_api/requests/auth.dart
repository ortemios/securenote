import 'package:secure_note/api/api.dart';

extension AuthRequests on NotesApi {
  Future<AuthSendSmsResponse> authSendSms({required String phone}) => post(
        path: 'auth/send-sms',
        params: {},
        body: {
          'phone': phone,
        },
        mapper: (json) => AuthSendSmsResponse(json),
      );

  Future<AuthLoginResponse> authLogin({
    required String phone,
    required String pin,
  }) =>
      post(
        path: 'auth/login',
        params: {},
        body: {
          'phone': phone,
          'pin': pin,
        },
        mapper: (json) => AuthLoginResponse(json),
      );

  Future<AuthRefreshTokenResponse> authRefreshToken() => post(
        path: 'auth/refresh-token',
        params: {},
        body: {},
        mapper: (json) => AuthRefreshTokenResponse(json),
      );

  Future<AuthLogoutResponse> authLogout() => post(
        path: 'auth/logout',
        params: {},
        body: {},
        mapper: (json) => AuthLogoutResponse(json),
      );
}

class AuthSendSmsResponse extends ApiResponse {
  AuthSendSmsResponse(JsonNode json) : super(json);
}

class AuthLoginResponse extends ApiResponse {
  final String token;

  AuthLoginResponse(JsonNode json)
      : token = json.optString('token'),
        super(json);
}

class AuthRefreshTokenResponse extends ApiResponse {
  final String token;

  AuthRefreshTokenResponse(JsonNode json)
      : token = json.optString('token'),
        super(json);
}

class AuthLogoutResponse extends ApiResponse {
  AuthLogoutResponse(JsonNode json) : super(json);
}
