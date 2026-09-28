import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactController extends GetxController {
  List<EmergencyContact> get contacts => [
        EmergencyContact(
          title: "National Emergency Helpline",
          description: "Govt (Police, Fire Service, Ambulance)",
          icon: Icons.local_police_rounded,
          numbers: ["999"],
        ),
        EmergencyContact(
          title: "Fire Service Emergency",
          description: "Fire service emergency rescue",
          icon: Icons.local_fire_department_rounded,
          numbers: ["102"],
        ),
        EmergencyContact(
          title: "Women & Child Helpline",
          description: "Women & Child Harassment Prevention",
          icon: Icons.health_and_safety_rounded,
          numbers: ["109"],
        ),
      ];
}