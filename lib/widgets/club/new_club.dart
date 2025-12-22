// lib/widgets/club/create_club.dart
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/api_service.dart';

class CreateClubScreen extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CreateClubScreen({super.key, this.onSuccess});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  final _formKey = GlobalKey<FormState>();
  final api = Get.find<ApiService>();

  final nameCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final levelCtrl = TextEditingController();
  final logoCtrl = TextEditingController();

  bool isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);
    try {
      await api.createClub(
        name: nameCtrl.text.trim(),
        country: countryCtrl.text.trim(),
        level: levelCtrl.text.trim(),
        logo: logoCtrl.text.isEmpty ? null : logoCtrl.text.trim(),
      );

      Get.back(); // Close bottom sheet
      widget.onSuccess?.call(); // Refresh list
      Get.snackbar("Success", "Club created!",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 16),
          Text("Create New Club",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color)),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Club Name *",
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: countryCtrl,
                      decoration: InputDecoration(
                        labelText: "Country *",
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: levelCtrl,
                      decoration: InputDecoration(
                        labelText: "Level * (e.g. Professional, Amateur)",
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: logoCtrl,
                      decoration: InputDecoration(
                        labelText: "Logo URL (optional)",
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Create Club",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    countryCtrl.dispose();
    levelCtrl.dispose();
    logoCtrl.dispose();
    super.dispose();
  }
}
