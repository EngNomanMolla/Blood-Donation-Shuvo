import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../home/controllers/home_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for Personal Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Address Dropdown states
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;

  List<String> _divisions = [];
  List<String> _districts = [];
  List<String> _upazilas = [];

  bool _isDivisionsLoading = false;
  bool _isDistrictsLoading = false;
  bool _isUpazilasLoading = false;

  // Controllers for Donor Info
  final TextEditingController _donationsCountController = TextEditingController();
  final TextEditingController _lastDonationDateController = TextEditingController();
  final TextEditingController _preferredLocationController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'B+';
  bool _isDonorAvailable = true;
  bool _isLoading = true;
  String? _avatarUrl;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _donationsCountController.dispose();
    _lastDonationDateController.dispose();
    _preferredLocationController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    await _loadUserProfile();
    await _fetchDivisions();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadUserProfile() async {
    try {
      if (Get.isRegistered<ProfileRepository>()) {
        final profile = await Get.find<ProfileRepository>().getProfile();
        if (profile != null) {
          _nameController.text = profile.name;
          _emailController.text = profile.email ?? '';
          _phoneController.text = profile.phone ?? '';
          _dobController.text = _formatDateFull(profile.dateOfBirth);

          _selectedDivision = profile.division?.isNotEmpty == true ? profile.division : null;
          _selectedDistrict = profile.district?.isNotEmpty == true ? profile.district : null;
          _selectedUpazila = profile.upazila?.isNotEmpty == true ? profile.upazila : null;

          if (profile.gender != null && _genders.contains(profile.gender)) {
            _selectedGender = profile.gender!;
          }

          if (profile.bloodGroup != null && _bloodGroups.contains(profile.bloodGroup)) {
            _selectedBloodGroup = profile.bloodGroup!;
          }

          _isDonorAvailable = profile.isAvailable;
          _donationsCountController.text = profile.donationsCount.toString();
          _avatarUrl = profile.avatar;

          // Cascade load districts and upazilas for the default user address
          if (_selectedDivision != null) {
            await _fetchDistricts(_selectedDivision!, setInitial: true);
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    }
  }

  // ── Address API Calls ──────────────────────────────────────────────────────

  Future<void> _fetchDivisions() async {
    setState(() => _isDivisionsLoading = true);
    try {
      final response = await http.get(Uri.parse(ApiConstants.bdApisDivisions));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        final fetched = listData.map((e) => e['division'].toString()).toList()..sort();
        setState(() {
          _divisions = fetched;
          if (_selectedDivision != null && !_divisions.contains(_selectedDivision)) {
            // Find match ignoring case
            final match = _divisions.firstWhereOrNull((d) => d.toLowerCase() == _selectedDivision!.toLowerCase());
            if (match != null) _selectedDivision = match;
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching divisions: $e");
    } finally {
      if (mounted) setState(() => _isDivisionsLoading = false);
    }
  }

  Future<void> _fetchDistricts(String division, {bool setInitial = false}) async {
    setState(() => _isDistrictsLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDivisionDetail}/$division'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        final fetched = listData.map((e) => e['district'].toString()).toList()..sort();
        setState(() {
          _districts = fetched;
          if (!setInitial) {
            _selectedDistrict = null;
            _selectedUpazila = null;
            _upazilas = [];
          } else if (_selectedDistrict != null && !_districts.contains(_selectedDistrict)) {
            final match = _districts.firstWhereOrNull((d) => d.toLowerCase() == _selectedDistrict!.toLowerCase());
            if (match != null) _selectedDistrict = match;
          }
        });

        if (setInitial && _selectedDistrict != null) {
          await _fetchUpazilas(_selectedDistrict!, setInitial: true);
        }
      }
    } catch (e) {
      debugPrint("Error fetching districts for $division: $e");
    } finally {
      if (mounted) setState(() => _isDistrictsLoading = false);
    }
  }

  Future<void> _fetchUpazilas(String district, {bool setInitial = false}) async {
    setState(() => _isUpazilasLoading = true);
    try {
      final response = await http.get(Uri.parse('${ApiConstants.bdApisDistrictDetail}/$district'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> listData = decoded['data'] ?? [];
        if (listData.isNotEmpty) {
          final List<dynamic> ups = listData[0]['upazillas'] ?? [];
          final fetched = ups.map((e) => e.toString()).toList()..sort();
          setState(() {
            _upazilas = fetched;
            if (!setInitial) {
              _selectedUpazila = null;
            } else if (_selectedUpazila != null && !_upazilas.contains(_selectedUpazila)) {
              final match = _upazilas.firstWhereOrNull((u) => u.toLowerCase() == _selectedUpazila!.toLowerCase());
              if (match != null) _selectedUpazila = match;
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching upazilas for $district: $e");
    } finally {
      if (mounted) setState(() => _isUpazilasLoading = false);
    }
  }

  String _formatDateFull(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      try {
        if (dateStr.contains('/')) {
          final parts = dateStr.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final months = [
              'January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December'
            ];
            return '$day ${months[month - 1]} $year';
          }
        }
      } catch (_) {}
      return dateStr;
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D2D2D),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      setState(() {
        controller.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildHeader(context),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPersonalInfoTab(),
                      _buildDonorInfoTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Header Section ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final displayAvatar = _avatarUrl ?? (homeController?.avatarUrl.value ?? '');

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE70349), Color(0xFF9E1B3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33E70349),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            children: [
              // Top Bar: Back Button & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  Text(
                    'Profile & Donor Settings',
                    style: AllStyles.titleTextStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance spacing
                ],
              ),

              const SizedBox(height: 18),

              // Avatar with Camera Edit Badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: displayAvatar.isNotEmpty ? NetworkImage(displayAvatar) : null,
                      child: displayAvatar.isEmpty
                          ? const Icon(Icons.person_rounded, size: 48, color: Colors.white)
                          : null,
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: Colors.black26,
                    child: InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Update Photo',
                          'Camera & Gallery upload will be available in next update',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: const Color(0xFF2D2D2D),
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // User Name
              Text(
                _nameController.text.isNotEmpty ? _nameController.text : 'User Profile',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 4),

              // User Phone / Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_phoneController.text.isNotEmpty)
                    Text(
                      _phoneController.text,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  if (_phoneController.text.isNotEmpty) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.water_drop_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          'Blood: $_selectedBloodGroup',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline_rounded, size: 18),
                SizedBox(width: 6),
                Text('Personal Info'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.volunteer_activism_rounded, size: 18),
                SizedBox(width: 6),
                Text('Donor Info'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Personal Info ───────────────────────────────────────────────────

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardWrapper(
            title: 'Basic Information',
            icon: Icons.badge_outlined,
            children: [
              _buildInputField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email address',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '01XXXXXXXXX',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 16),
              _buildDatePickerField(
                controller: _dobController,
                label: 'Date of Birth',
                hint: 'Select birth date',
                icon: Icons.cake_rounded,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildCardWrapper(
            title: 'Address & Location',
            icon: Icons.location_on_outlined,
            children: [
              // Division Dropdown
              _buildDropdownField(
                label: 'Division',
                hint: 'Select Division',
                icon: Icons.map_rounded,
                value: _selectedDivision,
                items: _divisions,
                isLoading: _isDivisionsLoading,
                onChanged: (val) {
                  if (val != null && val != _selectedDivision) {
                    setState(() {
                      _selectedDivision = val;
                      _selectedDistrict = null;
                      _selectedUpazila = null;
                      _districts = [];
                      _upazilas = [];
                    });
                    _fetchDistricts(val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // District Dropdown
              _buildDropdownField(
                label: 'District',
                hint: _selectedDivision == null ? 'Select Division first' : 'Select District',
                icon: Icons.location_city_rounded,
                value: _selectedDistrict,
                items: _districts,
                isLoading: _isDistrictsLoading,
                onChanged: (val) {
                  if (val != null && val != _selectedDistrict) {
                    setState(() {
                      _selectedDistrict = val;
                      _selectedUpazila = null;
                      _upazilas = [];
                    });
                    _fetchUpazilas(val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Upazila Dropdown
              _buildDropdownField(
                label: 'Upazila',
                hint: _selectedDistrict == null ? 'Select District first' : 'Select Upazila',
                icon: Icons.explore_rounded,
                value: _selectedUpazila,
                items: _upazilas,
                isLoading: _isUpazilasLoading,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedUpazila = val);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSaveButton(
            title: 'Save Profile Changes',
            onTap: () {
              Get.snackbar(
                'Success',
                'Personal profile details updated successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Donor Info ──────────────────────────────────────────────────────

  Widget _buildDonorInfoTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Switch Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDonorAvailable
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFF1F5F9), const Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isDonorAvailable ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFF94A3B8),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isDonorAvailable ? const Color(0xFF10B981) : Colors.grey[500],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isDonorAvailable ? 'Available for Donation' : 'Currently Unavailable',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isDonorAvailable ? const Color(0xFF065F46) : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isDonorAvailable
                            ? 'Patients & searchers can find you for blood requests.'
                            : 'Turn this on when you are ready to donate blood.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _isDonorAvailable ? const Color(0xFF047857) : Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isDonorAvailable,
                  activeThumbColor: const Color(0xFF10B981),
                  activeTrackColor: const Color(0xFFA7F3D0),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                  onChanged: (val) {
                    setState(() => _isDonorAvailable = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Blood Group Selection Card
          _buildCardWrapper(
            title: 'Blood Group',
            icon: Icons.water_drop_rounded,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _bloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return InkWell(
                    onTap: () => setState(() => _selectedBloodGroup = group),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: (MediaQuery.of(context).size.width - 74) / 4,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            size: 16,
                            color: isSelected ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Donation History & Preferred Locations
          _buildCardWrapper(
            title: 'Donation History & Preferences',
            icon: Icons.history_rounded,
            children: [
              _buildInputField(
                controller: _donationsCountController,
                label: 'Total Times Donated',
                hint: 'e.g. 3',
                icon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildDatePickerField(
                controller: _lastDonationDateController,
                label: 'Last Donation Date',
                hint: 'Select last donation date',
                icon: Icons.event_available_rounded,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _preferredLocationController,
                label: 'Preferred Hospital / Areas',
                hint: 'e.g. DMCH, Uttara, Dhanmondi',
                icon: Icons.local_hospital_rounded,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _emergencyContactController,
                label: 'Emergency / Alternate Contact',
                hint: '01XXXXXXXXX',
                icon: Icons.contact_phone_rounded,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildSaveButton(
            title: 'Save Donor Information',
            onTap: () {
              Get.snackbar(
                'Success',
                'Donor information & availability updated successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF4CAF50),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Helper UI Components ───────────────────────────────────────────────────

  Widget _buildCardWrapper({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
  }) {
    final hasMatchingValue = value != null && items.contains(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: hasMatchingValue ? value : null,
                    isExpanded: true,
                    hint: isLoading
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                              SizedBox(width: 8),
                              Text('Loading...', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                            ],
                          )
                        : Text(
                            hint,
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
                          ),
                    icon: isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: isLoading ? null : onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E293B),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _selectDate(context, controller),
          borderRadius: BorderRadius.circular(12),
          child: IgnorePointer(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[400]),
                prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
                suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: _genders.map((gender) {
            final isSelected = _selectedGender == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: gender != _genders.last ? 8 : 0),
                child: InkWell(
                  onTap: () => setState(() => _selectedGender = gender),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      gender,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
