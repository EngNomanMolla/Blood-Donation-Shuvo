import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class WalletProvider {
  final http.Client client;

  WalletProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> recharge({
    required String method,
    required double amount,
    required String transactionId,
    required String senderNumber,
    String? note,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.recharge}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = {
      'method': method,
      'amount': amount,
      'transaction_id': transactionId,
      'sender_number': senderNumber,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    return await client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getWallet() async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.wallet}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> getActiveSubscription() async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.activeSubscription}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> getVolunteerWallet() async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}/user/volunteer/wallet');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> getVolunteerPerformance() async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}/user/volunteer/performance');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> getSubscriptionPlans() async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.subscriptionPlans}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> volunteerWithdraw(Map<String, dynamic> body) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/volunteer/withdraw');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.post(url, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> getWithdrawals() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/volunteer/withdrawals?per_page=15');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(url, headers: headers);
  }

  Future<http.Response> purchaseSubscription(int planId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/subscriptions/$planId/purchase');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.post(url, headers: headers);
  }
}
