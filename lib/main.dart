import 'package:blood_donation/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
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
