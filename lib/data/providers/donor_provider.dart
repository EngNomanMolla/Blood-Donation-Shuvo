import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';

class DonorProvider {
  final http.Client client;

  DonorProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> getDonors({
    String? bloodGroup,
    String? division,
    String? district,
    String? upazila,
    int page = 1,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final queryParams = {
      if (bloodGroup != null && bloodGroup.isNotEmpty && bloodGroup.toLowerCase() != 'all') 
        'blood_group': bloodGroup,
      if (division != null && division.isNotEmpty && division != 'Division') 
        'division': division,
      if (district != null && district.isNotEmpty && district != 'District') 
        'district': district,
      if (upazila != null && upazila.isNotEmpty && upazila != 'Upazila') 
        'upazila': upazila,
      'page': page.toString(),
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getDonors}')
        .replace(queryParameters: queryParams);

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(uri, headers: headers);
  }

  Future<http.Response> getDonorDetails(int id) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getDonors}/$id');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.get(uri, headers: headers);
  }

  Future<http.Response> registerDonor(Map<String, dynamic> body) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.donorRegistration}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return await client.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> updateAvailability(bool isAvailable) async {
    final storage = Get.find<StorageService>();
    final token = storage.userToken;

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.availability}');

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final body = {
      'is_available': isAvailable,
    };

    return await client.post(uri, headers: headers, body: jsonEncode(body));
  }
}
