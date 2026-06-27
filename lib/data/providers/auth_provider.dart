import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthProvider {
  final http.Client client;

  AuthProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> sendCode(String phone) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.sendCode}');
    return await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
      }),
    );
  }

  Future<http.Response> verifyCode(String phone, String code, {String? fcmToken}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyCode}');
    return await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'fcm_token': fcmToken ?? 'dummy_fcm_token',
      }),
    );
  }
}
