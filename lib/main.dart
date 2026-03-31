import 'package:blood_donation/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        primaryColor: const Color(0xFFE70349),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE70349)),
      ),
      initialRoute: AppPages.getInitialRoute(),
      getPages: AppPages.pages,
    );
  }
}

