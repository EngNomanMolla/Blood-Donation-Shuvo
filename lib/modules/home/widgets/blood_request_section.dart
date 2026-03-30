import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../constants.dart';
import 'blood_type_card.dart';

/// Blood request section with blood type selection grid
class BloodRequestSection extends StatefulWidget {
  final List<String> bloodTypes;
  final String selectedBloodType;
  final ValueChanged<String> onBloodTypeChanged;

  const BloodRequestSection({
    super.key,
    required this.bloodTypes,
    required this.selectedBloodType,
    required this.onBloodTypeChanged,
  });

  @override
  State<BloodRequestSection> createState() => _BloodRequestSectionState();
}

class _BloodRequestSectionState extends State<BloodRequestSection> {
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedBloodType;
  }

  void _selectBloodType(String type) {
    setState(() => _selectedType = type);
    widget.onBloodTypeChanged(type);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: HomeConstants.headerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Blood Request', style: AllStyles.headingTextStyle),
          const SizedBox(height: 16),
          _buildBloodTypeGrid(),
        ],
      ),
    );
  }

  Widget _buildBloodTypeGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      children: widget.bloodTypes
          .map((type) => BloodTypeCard(
              bloodType: type,
              isSelected: _selectedType == type,
              onTap: () => _selectBloodType(type),
            ),
          )
          .toList(),
    );
  }
}
