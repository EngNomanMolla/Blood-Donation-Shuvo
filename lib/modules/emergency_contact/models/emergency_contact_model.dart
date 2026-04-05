/// MODEL
import 'package:flutter/material.dart';

class EmergencyContact {
  final String title;
  final IconData icon;
  final List<String> numbers;

  EmergencyContact({
    required this.title,
    required this.icon,
    required this.numbers,
  });
}