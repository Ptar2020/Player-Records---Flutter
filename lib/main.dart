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

  // 1. Register AuthService first (permanent)
  Get.put<AuthService>(AuthService(), permanent: true);

  // 2. Load .env EARLY — before anything that needs it (ApiService!)
  await dotenv.load(fileName: ".env");

  // 3. Now register and init ApiService (it can safely read env vars)
  await Get.putAsync<ApiService>(() async => await ApiService().init());

  // 4. Now safe to init AuthService (it depends on ApiService)
  await Get.find<AuthService>().init();

  // 5. GetStorage init
  await GetStorage.init();

  // 6. ThemeService
  Get.put<ThemeService>(ThemeService(), permanent: true);
  runApp(const PRecords());
}
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // 1. Register AuthService FIRST (permanent, so it's always available)
//   Get.put<AuthService>(AuthService(), permanent: true);

//   // 2. Now it's safe to call init() on it
//   await Get.find<AuthService>().init();

//   // 3. Load .env and GetStorage
//   await dotenv.load(fileName: ".env");
//   await GetStorage.init();

//   // 4. Register other services
//   await Get.putAsync<ApiService>(() async => await ApiService().init());
//   Get.put<ThemeService>(ThemeService(), permanent: true);

//   runApp(const PRecords());
// }

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
//   await Get.find<AuthService>().init();

//   await dotenv.load(fileName: ".env");
//   await GetStorage.init();

//   await Get.putAsync<ApiService>(() async => await ApiService().init());
//   Get.put<AuthService>(AuthService(), permanent: true);
//   Get.put<ThemeService>(ThemeService(), permanent: true);

//   // await Get.find<AuthService>().init();

//   runApp(const PRecords());
// }

// class PRecords extends StatelessWidget {
//   const PRecords({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "P-RECORDS",

//       // LIGHT THEME — FORCE WHITE TITLES
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

//       // DARK THEME — also forced to white
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
//       // themeMode: Get.find<ThemeService>().theme,
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

//   await dotenv.load(fileName: ".env");
//   await GetStorage.init();

//   // Initialize services
//   await Get.putAsync<ApiService>(() async => await ApiService().init());
//   Get.put<AuthService>(AuthService(), permanent: true);
//   Get.put<ThemeService>(ThemeService(), permanent: true);

//   // Init auth state (check token, etc.)
//   await Get.find<AuthService>().init();

//   runApp(const PRecords());
// }

// class PRecords extends StatelessWidget {
//   const PRecords({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "P-RECORDS",

//       // LIGHT THEME — now with white header text!
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,   
//           elevation: 0,
//         ),
//       ),

//       // DARK THEME — already perfect
//       darkTheme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         useMaterial3: true,
//         brightness: Brightness.dark,
//         scaffoldBackgroundColor: Colors.grey[900],
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.deepPurple,
//           foregroundColor: Colors.white,
//           elevation: 0,
//         ),
//       ),

//       themeMode: Get.find<ThemeService>().theme,
//       home: const SplashScreen(),
//     );
//   }
// }

