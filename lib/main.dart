import 'package:blood_donation/modules/auth/views/login_view.dart';
import 'package:blood_donation/modules/home/views/home_view.dart';
import 'package:blood_donation/modules/onboarding/views/onboarding_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'modules/splash/bindings/splash_binding.dart';
import 'modules/splash/views/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blood Donation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFE70349),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE70349)),
      ),
      //initialBinding: SplashBinding(),
      home:  HomeView(),
    );
  }
}

