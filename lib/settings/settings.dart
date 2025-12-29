import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/services/theme_service.dart';
import 'package:flutter/painting.dart' as paintingBinding;
import 'package:precords_android/widgets/positions/positions.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthService auth = Get.find<AuthService>();
  final ThemeService themeService = Get.find<ThemeService>();

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              auth.logout();
              Get.back();
              Get.snackbar("Logged out", "See you soon!",
                  backgroundColor: Colors.deepPurple, colorText: Colors.white);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
    // You can add global refresh logic here later if needed
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

          // ACCOUNT SECTION
          const Text("ACCOUNT",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Text(
                      currentUser?.username[0].toUpperCase() ?? "G",
                      style: TextStyle(
                          color: Colors.deepPurple[800],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: const Text("Logged in as"),
                  subtitle: Text(currentUser?.username ?? "Guest"),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? Colors.deepPurple.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentUser?.role.toUpperCase() ?? "GUEST",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAdmin
                              ? Colors.deepPurple[900]
                              : Colors.grey[700]),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // APPEARANCE
          const Text("APPEARANCE",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Obx(() => ListTile(
                  leading: Icon(
                    themeService.isDarkMode.value
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.deepPurple,
                  ),
                  title: const Text("Dark Mode"),
                  trailing: Switch(
                    value: themeService.isDarkMode.value,
                    onChanged: (val) => themeService.switchTheme(),
                    activeThumbColor: Colors.deepPurple,
                  ),
                )),
          ),
          const SizedBox(height: 24),

          // DATA
          const Text("DATA",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
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

          // MORE
          const Text("MORE",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sports_soccer),
                  title: const Text("Positions"),
                  onTap: () => Get.to(() => const Positions()),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("About PreCords"),
                  subtitle: Text("Version 2.0.1 • Made with ❤️ in Kenya"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
