import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/donor_repository.dart';
import '../models/doner_list_model.dart';

class DonateController extends GetxController {
  final DonorRepository donorRepository;

  DonateController({required this.donorRepository});

  final ScrollController scrollController = ScrollController();

  final searchQuery = ''.obs;
  final selectedDivision = 'Division'.obs;
  final selectedDistrict = 'District'.obs;
  final selectedUpazila = 'Upazila'.obs;

  final donors = <Donor>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;

  // bdapis.com geographical lists
  final divisions = <String>[].obs;
  final districts = <String>[].obs;
  final upazilas = <String>[].obs;
  final isDivisionsLoading = false.obs;
  final isDistrictsLoading = false.obs;
  final isUpazilasLoading = false.obs;

  String get bloodTypeArg => Get.arguments?['bloodType'] ?? 'All';

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    
    // Listen to changes in filter values and reload
    ever(selectedDivision, (String division) {
      selectedDistrict.value = 'District';
      selectedUpazila.value = 'Upazila';
      districts.clear();
      upazilas.clear();
      if (division != 'Division' && division.isNotEmpty) {
        fetchDistrictsList(division);
      }
      fetchDonors(reset: true);
    });

    ever(selectedDistrict, (String district) {
      selectedUpazila.value = 'Upazila';
      upazilas.clear();
      if (district != 'District' && district.isNotEmpty) {
        fetchUpazilasList(district);
      }
      fetchDonors(reset: true);
    });

    ever(selectedUpazila, (_) => fetchDonors(reset: true));

    // Fetch initial list of donors and divisions list
    fetchDonors(reset: true);
    fetchDivisionsList();
  }

  void _scrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100) {
        loadMore();
      }
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchDivisionsList() async {
    isDivisionsLoading.value = true;
    try {
      final response = await http.get(Uri.parse(ApiConstants.bdApisDivisions));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        divisions.value = listData
            .map((e) => e['division'] as String)
            .toList()
          ..sort();
      }
    } catch (e) {
      Get.printError(info: "Error fetching divisions list from bdapis: $e");
    } finally {
      isDivisionsLoading.value = false;
    }
  }

  Future<void> fetchDistrictsList(String division) async {
    isDistrictsLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDivisionDetail}/$division'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        districts.value = listData
            .map((e) => e['district'] as String)
            .toList()
          ..sort();
      }
    } catch (e) {
      Get.printError(info: "Error fetching districts list for $division from bdapis: $e");
    } finally {
      isDistrictsLoading.value = false;
    }
  }

  Future<void> fetchUpazilasList(String district) async {
    isUpazilasLoading.value = true;
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDistrictDetail}/$district'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        if (listData.isNotEmpty) {
          final List<dynamic> ups = listData[0]['upazillas'] ?? [];
          upazilas.value = ups.map((e) => e.toString()).toList()..sort();
        }
      }
    } catch (e) {
      Get.printError(info: "Error fetching upazilas list for $district from bdapis: $e");
    } finally {
      isUpazilasLoading.value = false;
    }
  }

  Future<void> fetchDonors({bool reset = false}) async {
    if (reset) {
      if (isLoading.value) return; // Prevent double load
      currentPage.value = 1;
      lastPage.value = 1;
      isLoading.value = true;
    } else {
      if (isLoadingMore.value || currentPage.value > lastPage.value) return;
      isLoadingMore.value = true;
    }

    try {
      final response = await donorRepository.getDonors(
        bloodGroup: bloodTypeArg,
        division: selectedDivision.value == 'Division' ? null : selectedDivision.value,
        district: selectedDistrict.value == 'District' ? null : selectedDistrict.value,
        upazila: selectedUpazila.value == 'Upazila' ? null : selectedUpazila.value,
        page: currentPage.value,
      );

      if (reset) {
        donors.assignAll(response.donors);
      } else {
        donors.addAll(response.donors);
      }

      currentPage.value = response.currentPage + 1;
      lastPage.value = response.lastPage;
    } catch (e) {
      Get.printError(info: "Error fetching donors: $e");
    } finally {
      if (reset) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  void loadMore() {
    fetchDonors(reset: false);
  }

  List<Donor> get filteredDonors {
    if (searchQuery.isEmpty) return donors;
    final query = searchQuery.value.toLowerCase();
    return donors
        .where((d) =>
            d.name.toLowerCase().contains(query) ||
            d.location.toLowerCase().contains(query))
        .toList();
  }
}