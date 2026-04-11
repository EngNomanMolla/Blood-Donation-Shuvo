import 'package:blood_donation/app/routes/app_pages.dart';
import 'package:blood_donation/modules/performance/views/performance_view.dart';
import 'package:blood_donation/modules/wallet/views/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'modules/emergency_contact/views/emergency_contact_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blood Donation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFFE70349),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE70349)),
      ),
      // home: MoreView(),
      initialRoute: AppPages.getInitialRoute(),
      getPages: AppPages.pages,
    );
  }
}
