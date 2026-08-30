import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

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

  Future<http.Response> volunteerSendCode(String phone) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/volunteer/send-code');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;
    return await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
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
