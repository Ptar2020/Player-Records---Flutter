import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/widgets/refreshable_page.dart';

class Settings extends StatefulWidget {
  const Settings({super.key}); // ← now const is allowed!

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate refresh (replace with real logic later)
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthService>().logout();
              Get.offAllNamed("/login");
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshablePage(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 50),
          const Center(
            child: Text(
              "Settings",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),

          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              subtitle: const Text("Sign out from your account"),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLogoutDialog,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              subtitle: const Text("Version 1.0.0"),
              onTap: () {
                Get.snackbar("About", "Precords v1.0.0", snackPosition: SnackPosition.BOTTOM);
              },
            ),
          ),

          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/bottom_menu.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// class Settings extends StatefulWidget
//     with HasAppBarTitle, HasAppBarActions {
//   const Settings({super.key});

//   @override
//   State<Settings> createState() => SettingsState();

//   @override
//   Widget get appBarTitle => const Text("SETTINGS");

//   @override
//   Widget appBarActions(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),

//       onSelected: (value) {
//         if (value == "refresh") {
//           // Silent refresh action
//           final state = context.findAncestorStateOfType<SettingsState>();
//           state?._onRefresh();
//         } 
//         else if (value == "logout") {
//           final state = context.findAncestorStateOfType<SettingsState>();
//           state?._onRefresh();
//         }
//       },

//       itemBuilder: (context) => [
//         const PopupMenuItem(
//           value: "refresh",
//           child: Text("Refresh"),
//         ),
//         const PopupMenuItem(
//           value: "logout",
//           child: Text("Logout"),
//         ),
//       ],
//     );
//   }
// }

// class SettingsState extends State<Settings>
//     with AutomaticKeepAliveClientMixin<Settings> {
//   @override
//   bool get wantKeepAlive => true;

//   Future<void> _onRefresh() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: _onRefresh,
//       child: ObxValue<RxInt>(
//         (tab) {
//           if (tab.value == 3) {
//             scheduleMicrotask(() => mounted ? _onRefresh() : null);
//           }

//           return ListView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//             children: [
//               const SizedBox(height: 80),

//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.construction,
//                       size: 100,
//                       color: Colors.deepPurple,
//                     ),
//                     const SizedBox(height: 32),
//                     const Text(
//                       "Settings",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       "Coming soon...",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 24,
//                         color: Colors.grey,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Stay tuned for themes, notifications,\nand advanced options!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 200),
//             ],
//           );
//         },
//         currentTabIndex,
//       ),
//     );
//   }
// }



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/bottom_menu.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// class Settings extends StatefulWidget with HasAppBarTitle {
//   const Settings({super.key});

//   @override
//   State<Settings> createState() => SettingsState();

//   @override
//   Widget get appBarTitle => const Text("SETTINGS");
// }

// class SettingsState extends State<Settings>
//     with AutomaticKeepAliveClientMixin<Settings> {
//   @override
//   bool get wantKeepAlive => true;

//   // Silent refresh — no snackbar, no noise
//   Future<void> _onRefresh() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     // Nothing here → pure silent refresh
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: _onRefresh,
//       child: ObxValue<RxInt>(
//         (tab) {
//           // Optional: auto-refresh when entering Settings tab
//           if (tab.value == 3) {
//             scheduleMicrotask(() => mounted ? _onRefresh() : null);
//           }

//           return ListView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
//             children: [
//               const SizedBox(height: 80),

//               Center(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.construction,
//                       size: 100,
//                       color: Colors.deepPurple,
//                     ),
//                     const SizedBox(height: 32),
//                     const Text(
//                       "Settings",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       "Coming soon...",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 24,
//                         color: Colors.grey,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Stay tuned for themes, notifications,\nand advanced options!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 200),
//             ],
//           );
//         },
//         currentTabIndex,
//       ),
//     );
//   }
// }