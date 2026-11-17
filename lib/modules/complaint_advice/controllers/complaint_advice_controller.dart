import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../data/providers/complaint_provider.dart';
import '../../../../data/providers/profile_provider.dart';
import '../../../../data/repositories/complaint_repository.dart';
import '../../../../data/repositories/profile_repository.dart';
import '../models/complaint_model.dart';

class ComplaintAdviceController extends GetxController with GetSingleTickerProviderStateMixin {
  late final TabController tabController;
  final ScrollController scrollController = ScrollController();

  // Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final messageController = TextEditingController();

  // States
  final isPrefilling = true.obs;
  final isSubmitting = false.obs;
  final isLoadingHistory = false.obs;
  final isLoadingMore = false.obs;
  final selectedFilter = 'all'.obs; // all, pending, in_review, resolved, rejected

  // History Data
  final complaints = <ComplaintItem>[].obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final totalCount = 0.obs;

  late final ComplaintRepository _complaintRepo;
  late final ProfileRepository _profileRepo;

  @override
  void onInit() {
    super.onInit();
    final initialTab = Get.arguments is Map && Get.arguments['initialTab'] != null
        ? (Get.arguments['initialTab'] as int)
        : 0;

    tabController = TabController(length: 2, vsync: this, initialIndex: initialTab);
    tabController.addListener(() {
      if (tabController.index == 1 && complaints.isEmpty && !isLoadingHistory.value) {
        fetchComplaints();
      }
    });

    scrollController.addListener(_onScroll);

    // Dependencies
    final compProvider = Get.isRegistered<ComplaintProvider>()
        ? Get.find<ComplaintProvider>()
        : Get.put(ComplaintProvider());
    _complaintRepo = Get.isRegistered<ComplaintRepository>()
        ? Get.find<ComplaintRepository>()
        : Get.put(ComplaintRepository(provider: compProvider));

    final profProvider = Get.isRegistered<ProfileProvider>()
        ? Get.find<ProfileProvider>()
        : Get.put(ProfileProvider());
    _profileRepo = Get.isRegistered<ProfileRepository>()
        ? Get.find<ProfileRepository>()
        : Get.put(ProfileRepository(provider: profProvider));

    loadUserData();
    fetchComplaints();
  }

  void _onScroll() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150) {
        loadMore();
      }
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // --- Filtered Complaints ---
  List<ComplaintItem> get filteredComplaints {
    if (selectedFilter.value == 'all') return complaints;
    return complaints.where((item) {
      final s = item.status.toLowerCase();
      if (selectedFilter.value == 'resolved') {
        return s == 'resolved' || s == 'approved';
      }
      return s == selectedFilter.value;
    }).toList();
  }

  int get pendingCount => complaints.where((c) => c.status == 'pending').length;
  int get inReviewCount => complaints.where((c) => c.status == 'in_review' || c.status == 'processing').length;
  int get resolvedCount => complaints.where((c) => c.status == 'resolved' || c.status == 'approved').length;
  int get rejectedCount => complaints.where((c) => c.status == 'rejected').length;

  Future<void> loadUserData() async {
    isPrefilling.value = true;
    try {
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        if (storage.userPhone != null && storage.userPhone!.isNotEmpty) {
          phoneController.text = storage.userPhone!;
        }
      }

      final profile = await _profileRepo.getProfile();
      if (profile != null) {
        if (nameController.text.trim().isEmpty && profile.name.isNotEmpty) {
          nameController.text = profile.name;
        }
        if (phoneController.text.trim().isEmpty && profile.phone != null) {
          phoneController.text = profile.phone!;
        }
        if (addressController.text.trim().isEmpty) {
          final addressParts = [profile.upazila, profile.district, profile.division]
              .where((p) => p != null && p.trim().isNotEmpty)
              .join(', ');
          if (addressParts.isNotEmpty) {
            addressController.text = addressParts;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading user data in ComplaintAdviceController: $e");
    } finally {
      isPrefilling.value = false;
    }
  }

  Future<void> fetchComplaints({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
    }
    isLoadingHistory.value = true;

    try {
      final result = await _complaintRepo.getComplaints(page: 1);
      complaints.assignAll(result.complaints);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      totalCount.value = result.total;
    } catch (e) {
      debugPrint("Error fetching complaints: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || currentPage.value >= lastPage.value) return;

    isLoadingMore.value = true;
    try {
      final nextPage = currentPage.value + 1;
      final result = await _complaintRepo.getComplaints(page: nextPage);
      complaints.addAll(result.complaints);
      currentPage.value = result.currentPage;
      lastPage.value = result.lastPage;
      totalCount.value = result.total;
    } catch (e) {
      debugPrint("Error loading more complaints: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<bool> submitComplaint() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final message = messageController.text.trim();

    if (name.isEmpty) {
      _showWarning('অনুগ্রহ করে আপনার নাম লিখুন');
      return false;
    }

    if (phone.isEmpty) {
      _showWarning('অনুগ্রহ করে আপনার মোবাইল নম্বর লিখুন');
      return false;
    }

    if (message.isEmpty) {
      _showWarning('অনুগ্রহ করে আপনার অভিযোগ বা পরামর্শ লিখুন');
      return false;
    }

    isSubmitting.value = true;
    try {
      await _complaintRepo.submitComplaint(
        name: name,
        phone: phone,
        address: address.isNotEmpty ? address : null,
        message: message,
      );

      // Clear message field after successful submit
      messageController.clear();

      // Refresh history so the new complaint is immediately visible
      fetchComplaints(refresh: true);

      return true;
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showWarning(String msg) {
    Get.snackbar(
      'সতর্কতা',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}

