import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/models/player_model.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditPlayerModal extends StatefulWidget {
  final Player player;

  const EditPlayerModal({super.key, required this.player});

  @override
  State<EditPlayerModal> createState() => _EditPlayerModalState();
}

class _EditPlayerModalState extends State<EditPlayerModal> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late TextEditingController _name;
  late TextEditingController _age;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _jersey;

  String? _gender;
  String? _position;
  String? _country;

  XFile? _photoFile;

  @override
  void initState() {
    super.initState();
    final p = widget.player;

    _name = TextEditingController(text: p.name);
    _age = TextEditingController(text: p.age.toString());
    _phone = TextEditingController(text: p.phone ?? "");
    _email = TextEditingController(text: p.email ?? "");
    _jersey = TextEditingController(
        text: p.jerseyNumber != null ? p.jerseyNumber.toString() : "");

    _gender = p.gender;
    _position = p.position?.name;
    _country = p.country;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _email.dispose();
    _jersey.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _photoFile = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    Get.snackbar("Updating", "Saving player changes...",
        backgroundColor: Colors.deepPurple,
        colorText: Colors.white,
        duration: const Duration(seconds: 1));

    final updated = await Get.find<ApiService>().updatePlayer(
      id: widget.player.id,
      name: _name.text,
      age: int.tryParse(_age.text),
      phone: _phone.text.isEmpty ? null : _phone.text,
      email: _email.text.isEmpty ? null : _email.text,
      jerseyNumber: int.tryParse(_jersey.text),
      gender: _gender,
      country: _country,
      position: _position,
      photoFile: _photoFile,
    );

    if (updated != null) {
      Navigator.pop(context, updated); // return updated player
    } else {
      Get.snackbar("Error", "Failed to update player",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Text(
                  "Edit Player",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (v) =>
                      v!.trim().isEmpty ? "Name is required" : null,
                ),

                const SizedBox(height: 12),

                // Age
                TextFormField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: "Age"),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                // Jersey Number
                TextFormField(
                  controller: _jersey,
                  decoration: const InputDecoration(labelText: "Jersey Number"),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                // Phone
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),

                const SizedBox(height: 12),

                // Email
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 12),

                // Photo
                TextButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo),
                  label: const Text("Change Photo"),
                ),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
