import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/services/auth_service.dart';

class Logout extends StatelessWidget {
  const Logout({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.red),
      tooltip: "Log out",
      onPressed: () => _showLogoutDialog(context, authService),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await authService.logout();

    // Close loading dialog
    if (Get.isDialogOpen == true) Get.back();

    if (success) {
      Get.snackbar(
        "Logged out!",
        "successfully",
        backgroundColor: Colors.deepPurple[300],
        colorText: Colors.white,
        titleText: const Text(
      "Logged out",
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
    messageText: const Text(
      "successfully",
      style: TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
    ),
      );
      Get.offAllNamed('/login'); // Force go to login screen
    } else {
      Get.snackbar(
        "Error",
        authService.errorMessage ?? "Failed to log out",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}