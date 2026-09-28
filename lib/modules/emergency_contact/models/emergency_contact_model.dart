// MODEL
import 'package:flutter/material.dart';

class EmergencyContact {
  final String title;
  final String description;
  final IconData icon;
  final List<String> numbers;

  EmergencyContact({
    required this.title,
    required this.description,
    required this.icon,
    required this.numbers,
  });
}