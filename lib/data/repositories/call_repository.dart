import 'dart:convert';
import 'package:blood_donation/modules/call/models/call_model.dart';
import '../providers/call_provider.dart';

class CallRepository {
  final CallProvider callProvider;

  CallRepository(this.callProvider);

  Future<AgoraTokenData> getAgoraToken(int recipientId) async {
    final response = await callProvider.getAgoraToken(recipientId);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data = decoded['data'] as Map<String, dynamic>;
      return AgoraTokenData.fromJson(data);
    } else {
      final decoded = jsonDecode(response.body);
      final errorMsg = decoded['message'] ?? 'Failed to generate call token (${response.statusCode})';
      throw Exception(errorMsg);
    }
  }
}
