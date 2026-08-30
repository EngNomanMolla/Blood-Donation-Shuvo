import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class CallProvider {
  final http.Client client;

  CallProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getAgoraToken(int recipientId) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.agoraToken}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = jsonEncode({
      'recipient_id': recipientId,
    });

    return await client.post(url, headers: headers, body: body);
  }
}
