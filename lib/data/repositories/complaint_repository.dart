import 'dart:convert';
import '../providers/complaint_provider.dart';

class ComplaintRepository {
  final ComplaintProvider provider;

  ComplaintRepository({required this.provider});

  Future<Map<String, dynamic>> submitComplaint({
    required String name,
    required String phone,
    String? address,
    required String message,
  }) async {
    final response = await provider.submitComplaint(
      name: name,
      phone: phone,
      address: address,
      message: message,
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'status': 'success', 'data': decoded};
    } else {
      String errorMessage = 'অভিযোগ বা পরামর্শ জমা দেওয়া সম্ভব হয়নি।';
      if (decoded is Map) {
        errorMessage = decoded['message'] ?? decoded['error'] ?? errorMessage;
      }
      throw Exception(errorMessage);
    }
  }
}

