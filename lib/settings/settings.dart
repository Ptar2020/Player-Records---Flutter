import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:flutter/painting.dart' as paintingBinding;

import '../widgets/positions/positions.dart';
import '../widgets/user/users.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService auth = Get.find<AuthService>();

  void _clearCache() {
    paintingBinding.imageCache.clear();
    paintingBinding.imageCache.clearLiveImages();
    Get.snackbar("Cache Cleared", "All images refreshed next time",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _refreshAllData() {
    Get.snackbar("Refreshing", "Reloading all data...",
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white);
  }

  void _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      Get.snackbar("Logged Out", "See you soon!",
          backgroundColor: Colors.deepPurple, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.role.toLowerCase() == 'admin';

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 20),

          // ACCOUNT
          _buildSectionHeader(context, "ACCOUNT", Icons.account_circle),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  currentUser?.username[0].toUpperCase() ?? "G",
                  style: TextStyle(
                      color: Colors.deepPurple[800],
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(currentUser?.username ?? "Guest"),
              subtitle: Text(currentUser?.role.toUpperCase() ?? "GUEST"),
              trailing: IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: _logout,
                tooltip: "Logout",
              ),
            ),
          ),
          const SizedBox(height: 24),

          // DATA
          _buildSectionHeader(context, "DATA", Icons.storage),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.deepPurple),
                  title: const Text("Refresh All Data"),
                  onTap: _refreshAllData,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cleaning_services,
                      color: Colors.deepPurple),
                  title: const Text("Clear Image Cache"),
                  subtitle: const Text("Free up space, reload fresh images"),
                  onTap: _clearCache,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ADMIN TOOLS
          if (isAdmin) ...[
            _buildSectionHeader(
                context, "ADMIN TOOLS", Icons.admin_panel_settings),
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 6,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.to(() => const Positions()),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.sports_soccer,
                                size: 40, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text("Positions",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 6,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Get.to(() => const Users()),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(Icons.group,
                                size: 40, color: Colors.deepPurple),
                            SizedBox(height: 8),
                            Text("Users",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],

          // Version at bottom
          Center(
            child: Text(
              "PreCords v2.0.1 • Made with ❤️ in Kenya",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:flutter/painting.dart' as paintingBinding;

// import '../widgets/positions/positions.dart';
// import '../widgets/user/users.dart';

// class Settings extends StatefulWidget {
//   const Settings({super.key});

//   @override
//   State<Settings> createState() => _SettingsState();
// }

// class _SettingsState extends State<Settings> {
//   final AuthService auth = Get.find<AuthService>();

//   void _clearCache() {
//     paintingBinding.imageCache.clear();
//     paintingBinding.imageCache.clearLiveImages();
//     Get.snackbar("Cache Cleared", "All images refreshed next time",
//         backgroundColor: Colors.green, colorText: Colors.white);
//   }

//   void _refreshAllData() {
//     Get.snackbar("Refreshing", "Reloading all data...",
//         duration: const Duration(seconds: 2),
//         backgroundColor: Colors.deepPurple,
//         colorText: Colors.white);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = auth.currentUser;
//     final isAdmin = currentUser?.role.toLowerCase() == 'admin';

//     return Scaffold(
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const SizedBox(height: 20),

//           // ACCOUNT — Clean: only username + role
//           const Text("ACCOUNT",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey)),
//           const SizedBox(height: 8),
//           Card(
//             child: ListTile(
//               leading: CircleAvatar(
//                 backgroundColor: Colors.deepPurple.shade100,
//                 child: Text(
//                   currentUser?.username[0].toUpperCase() ?? "G",
//                   style: TextStyle(
//                       color: Colors.deepPurple[800],
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               title: Text(currentUser?.username ?? "Guest"),
//               subtitle: Text(currentUser?.role.toUpperCase() ?? "GUEST"),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // DATA
//           const Text("DATA",
//               style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey)),
//           const SizedBox(height: 8),
//           Card(
//             child: Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.refresh, color: Colors.deepPurple),
//                   title: const Text("Refresh All Data"),
//                   onTap: _refreshAllData,
//                 ),
//                 const Divider(height: 1),
//                 ListTile(
//                   leading: const Icon(Icons.cleaning_services,
//                       color: Colors.deepPurple),
//                   title: const Text("Clear Image Cache"),
//                   subtitle: const Text("Free up space, reload fresh images"),
//                   onTap: _clearCache,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // ADMIN TOOLS — Side by side for admin only
//           if (isAdmin) ...[
//             const Text("ADMIN TOOLS",
//                 style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey)),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     child: ListTile(
//                       leading: const Icon(Icons.sports_soccer,
//                           color: Colors.deepPurple),
//                       title: const Text("Positions"),
//                       onTap: () => Get.to(() => const Positions()),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Card(
//                     child: ListTile(
//                       leading:
//                           const Icon(Icons.group, color: Colors.deepPurple),
//                       title: const Text("Users"),
//                       onTap: () => Get.to(() => const Users()),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//           ],

//           const SizedBox(height: 40),
//         ],
//       ),
//     );
//   }
// }
