import 'package:get/get.dart';
import '../../../data/repositories/home_repository.dart';
import '../models.dart';

class HomeController extends GetxController {
  final HomeRepository homeRepository;

  HomeController({required this.homeRepository});

  final banners = <BannerModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    isLoading.value = true;
    try {
      final bannerList = await homeRepository.getBanners();
      // Filter active banners and sort by order ascending
      banners.value = bannerList
          .where((banner) => banner.isActive)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (e) {
      Get.printError(info: "Error fetching banners from API: $e. Using local fallbacks.");
      // Graceful fallback to default banners so the UI is not empty
      banners.value = [
        BannerModel(
          id: 1,
          title: "Emergency Blood Needed",
          image: "https://images.unsplash.com/photo-1615461066841-6116e61058f4?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/emergency-blood-needed",
          isActive: true,
          order: 1,
        ),
        BannerModel(
          id: 2,
          title: "Become a Volunteer",
          image: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/become-a-volunteer",
          isActive: true,
          order: 2,
        ),
        BannerModel(
          id: 3,
          title: "Donate Near You",
          image: "https://images.unsplash.com/photo-1584515933487-779824d29309?auto=format&fit=crop&w=1200&q=80",
          link: "https://example.com/campaigns/donate-near-you",
          isActive: true,
          order: 3,
        ),
      ];
    } finally {
      isLoading.value = false;
    }
  }
}
