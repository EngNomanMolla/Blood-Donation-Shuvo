import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class ComplaintProvider {
  final http.Client client;

  ComplaintProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> submitComplaint({
    required String name,
    required String phone,
    String? address,
    required String message,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.complaints}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (Get.isRegistered<StorageService>()) {
      final storage = Get.find<StorageService>();
      final token = storage.userToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final body = {
      'name': name,
      'phone': phone,
      if (address != null && address.isNotEmpty) 'address': address,
      'message': message,
    };

    return await client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getComplaints({int page = 1}) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.complaints}?page=$page');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (Get.isRegistered<StorageService>()) {
      final storage = Get.find<StorageService>();
      final token = storage.userToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await client.get(url, headers: headers);
  }
}

