import 'dart:convert';
import '../providers/home_provider.dart';
import '../../modules/home/models.dart';

class HomeRepository {
  final HomeProvider homeProvider;

  HomeRepository(this.homeProvider);

  Future<List<BannerModel>> getBanners() async {
    final response = await homeProvider.getBanners();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch banners: ${response.statusCode}');
    }
    
    final String body = response.body;
    if (body.isEmpty) {
      return [];
    }

    List<dynamic> listData = [];
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        listData = decoded;
      } else if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
        listData = decoded['data'];
      } else if (decoded is Map && decoded.containsKey('banners') && decoded['banners'] is List) {
        listData = decoded['banners'];
      }
    } catch (_) {
      listData = [];
    }

    return listData.map((json) {
      return BannerModel.fromJson(Map<String, dynamic>.from(json as Map));
    }).toList();
  }
}
