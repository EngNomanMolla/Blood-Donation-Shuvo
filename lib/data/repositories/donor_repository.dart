import 'dart:convert';
import '../providers/donor_provider.dart';
import '../../modules/doner_request/models/doner_list_model.dart';

class DonorResponse {
  final List<Donor> donors;
  final int currentPage;
  final int lastPage;
  final int total;

  DonorResponse({
    required this.donors,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class DonorRepository {
  final DonorProvider donorProvider;

  DonorRepository(this.donorProvider);

  Future<DonorResponse> getDonors({
    String? bloodGroup,
    String? division,
    String? district,
    String? upazila,
    int page = 1,
  }) async {
    final response = await donorProvider.getDonors(
      bloodGroup: bloodGroup,
      division: division,
      district: district,
      upazila: upazila,
      page: page,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch donors: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> listData = decoded['data'] ?? [];
    
    final donors = listData.map((json) {
      return Donor.fromJson(Map<String, dynamic>.from(json as Map));
    }).toList();

    final meta = decoded['meta'] ?? {};
    final currentPage = meta['current_page'] ?? 1;
    final lastPage = meta['last_page'] ?? 1;
    final total = meta['total'] ?? donors.length;

    return DonorResponse(
      donors: donors,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
    );
  }
}
