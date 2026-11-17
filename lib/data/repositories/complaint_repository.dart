import 'dart:convert';
import '../../modules/complaint_advice/models/complaint_model.dart';
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

  Future<ComplaintListResponse> getComplaints({int page = 1}) async {
    final response = await provider.getComplaints(page: page);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> list = [];
      int currentPage = page;
      int lastPage = page;
      int total = 0;

      if (decoded is Map) {
        final dataContainer = decoded['data'];
        if (dataContainer is Map) {
          if (dataContainer['data'] is List) {
            list = dataContainer['data'];
          }
          if (dataContainer['meta'] is Map) {
            currentPage = dataContainer['meta']['current_page'] ?? page;
            lastPage = dataContainer['meta']['last_page'] ?? page;
            total = dataContainer['meta']['total'] ?? list.length;
          }
        } else if (dataContainer is List) {
          list = dataContainer;
        }

        if (decoded['meta'] is Map) {
          currentPage = decoded['meta']['current_page'] ?? currentPage;
          lastPage = decoded['meta']['last_page'] ?? lastPage;
          total = decoded['meta']['total'] ?? list.length;
        }
      }

      final complaints = list
          .whereType<Map>()
          .map((item) => ComplaintItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return ComplaintListResponse(
        complaints: complaints,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
    } else {
      throw Exception('অভিযোগ তালিকা লোড করা সম্ভব হয়নি (${response.statusCode})');
    }
  }
}

