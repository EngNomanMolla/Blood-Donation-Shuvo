import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class HomeProvider {
  final http.Client client;

  HomeProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getBanners() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.banners}');
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

  Future<http.Response> getNotifications() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/notifications');
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

  Future<http.Response> markNotificationAsRead(String id) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/user/notifications/$id/read');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.patch(url, headers: headers);
  }
}
