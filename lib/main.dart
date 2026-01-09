import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'widgets/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env first
  await dotenv.load(fileName: ".env");

  // Initialize ApiService first (no dependency on AuthService)
  await Get.putAsync<ApiService>(() async {
    final api = ApiService();
    await api.init();
    return api;
  });

  // Initialize AuthService second (depends on ApiService.dio)
  await Get.putAsync<AuthService>(() async {
    final auth = AuthService();
    await auth.init();
    return auth;
  });

  // GetStorage
  await GetStorage.init();

  // ThemeService
  Get.put<ThemeService>(ThemeService(), permanent: true);

  runApp(const PRecords());
}

class PRecords extends StatelessWidget {
  const PRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "P-RECORDS",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      themeMode: Get.find<ThemeService>().themeMode,
      home: const SplashScreen(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import 'services/api_service.dart';
// import 'services/auth_service.dart';
// import 'services/theme_service.dart';
// import 'widgets/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Load .env first
//   await dotenv.load(fileName: ".env");

//   // Initialize ApiService first
//   await Get.putAsync<ApiService>(() async {
//     final api = ApiService();
//     await api.init();
//     return api;
//   });

//   // Initialize AuthService second (depends on ApiService)
//   await Get.putAsync<AuthService>(() async {
//     final auth = AuthService();
//     await auth.init();
//     return auth;
//   });

//   // GetStorage
//   await GetStorage.init();

//   // ThemeService
//   Get.put<ThemeService>(ThemeService(), permanent: true);

//   runApp(const PRecords());
// }

// class PRecords extends StatelessWidget {
//   const PRecords({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "P-RECORDS",
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: Colors.grey[900],
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       themeMode: Get.find<ThemeService>().themeMode,
//       home: const SplashScreen(),
//     );
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import 'services/api_service.dart';
// import 'services/auth_service.dart';
// import 'services/theme_service.dart';
// import 'widgets/splash_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 1. Register AuthService first (permanent)
//   Get.put<AuthService>(AuthService(), permanent: true);

//   // 2. Load .env EARLY — before anything that needs it (ApiService!)
//   await dotenv.load(fileName: ".env");

//   // 3. Now register and init ApiService (it can safely read env vars)
//   await Get.putAsync<ApiService>(() async => await ApiService().init());

//   // 4. Now safe to init AuthService (it depends on ApiService)
//   await Get.find<AuthService>().init();

//   // 5. GetStorage init
//   await GetStorage.init();

//   // 6. ThemeService
//   Get.put<ThemeService>(ThemeService(), permanent: true);
//   runApp(const PRecords());
// }

// class PRecords extends StatelessWidget {
//   const PRecords({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "P-RECORDS",
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: Colors.grey[900],
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,
//           titleTextStyle: TextStyle(
//             color: Colors.white,
//             fontSize: 30,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       themeMode: Get.find<ThemeService>().themeMode,
//       home: const SplashScreen(),
//     );
//   }
// }







