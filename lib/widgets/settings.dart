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
        content: const Text("Sure to log out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<AuthService>().logout();
              // Get.offAllNamed("/login");
            },
            child: const Text("Logout", style: TextStyle(color: Colors.deepPurple)),
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
