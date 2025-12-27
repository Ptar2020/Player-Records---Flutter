import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/Get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/club_model.dart';
import '../services/api_service.dart';

enum ClubFormMode { create, edit }

class ClubForm extends StatefulWidget {
  final ClubFormMode mode;
  final ClubModel? club;

  const ClubForm({
    super.key,
    required this.mode,
    this.club,
  });

  @override
  State<ClubForm> createState() => _ClubFormState();
}

class _ClubFormState extends State<ClubForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _levelCtrl;

  bool _isSubmitting = false;
  bool _isUploadingLogo = false;

  XFile? _pickedFile;
  String? _logoUrl;

  final ApiService _api = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();

    final c = widget.club;

    _nameCtrl = TextEditingController(text: c?.name ?? "");
    _countryCtrl = TextEditingController(text: c?.country ?? "");
    _levelCtrl = TextEditingController(text: c?.level ?? "");

    _logoUrl = c?.logo;
  }

  Future<void> _pickAndUploadLogo() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _pickedFile = picked;
      _isUploadingLogo = true;
    });

    try {
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
      final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

      final formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(picked.path),
        'upload_preset': preset,
      });

      final res = await dio.Dio().post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      setState(() {
        _logoUrl = res.data['secure_url'];
      });

      Get.snackbar("Success", "Logo uploaded",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Logo upload failed", backgroundColor: Colors.red);
    } finally {
      setState(() => _isUploadingLogo = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.mode == ClubFormMode.create) {
        final newClub = await _api.createClub(
          name: _nameCtrl.text.trim(),
          country: _countryCtrl.text.trim(),
          logo: _logoUrl,
          level: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
        );

        Get.back(result: newClub);
        Get.snackbar("Success", "Club added successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Edit mode
        final updates = <String, dynamic>{
          'name': _nameCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
        };

        if (_levelCtrl.text.trim().isNotEmpty) {
          updates['level'] = _levelCtrl.text.trim();
        }

        if (_logoUrl != null && _logoUrl != widget.club?.logo) {
          updates['logo'] = _logoUrl;
        }

        // Use club id for update (as per your backend)
        final updatedClub = await _api.updateClub(widget.club!.id, updates);

        Get.back(result: updatedClub);
        Get.snackbar("Success", "Club updated successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _countryCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mode == ClubFormMode.edit;
    final title = isEdit ? "Edit Club" : "Add Club";

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.close), onPressed: () => Get.back()),
              ],
            ),
          ),
          Text(title,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickAndUploadLogo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _pickedFile != null
                      ? FileImage(File(_pickedFile!.path))
                      : (_logoUrl != null ? NetworkImage(_logoUrl!) : null),
                  child: _pickedFile == null && _logoUrl == null
                      ? const Icon(Icons.sports_soccer,
                          size: 60, color: Colors.grey)
                      : null,
                ),
                if (_isUploadingLogo)
                  const CircularProgressIndicator(color: Colors.deepPurple),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: "Club Name *"),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(labelText: "Country *"),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _levelCtrl,
                      decoration: const InputDecoration(
                          labelText: "Level (e.g. Premier, Division 1)"),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : Text(isEdit ? "Save Changes" : "Add Club"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
