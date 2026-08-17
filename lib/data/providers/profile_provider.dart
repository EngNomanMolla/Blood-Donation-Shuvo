import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class ProfileProvider {
  final http.Client client;

  ProfileProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getProfile() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profileMe}');
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

  Future<http.Response> updateProfileImage(String imagePath) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profile}');
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
