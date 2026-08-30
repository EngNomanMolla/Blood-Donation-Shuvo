import 'dart:io';
import 'package:blood_donation/app/routes/app_pages.dart';
// Import the generated file
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:blood_donation/core/services/fcm_service.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36';
  }
}

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
 
  HttpOverrides.global = MyHttpOverrides();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => FCMService().init());
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
