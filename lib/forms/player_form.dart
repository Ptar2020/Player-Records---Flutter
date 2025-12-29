import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:precords_android/constants/countries.dart';

import '../models/player_model.dart';
import '../models/club_model.dart';
import '../services/api_service.dart';

enum PlayerFormMode { create, edit }

class PlayerForm extends StatefulWidget {
  final PlayerFormMode mode;
  final Player? player;

  const PlayerForm({
    super.key,
    required this.mode,
    this.player,
  });

  @override
  State<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _jerseyCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;

  String? _selectedGender;
  String? _selectedPositionId;
  String? _selectedClubId;

  List<Position> _positions = [];
  List<ClubModel> _clubs = [];

  bool _loadingData = true;
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;

  XFile? _pickedFile;
  String? _photoUrl;

  final ApiService _api = Get.find<ApiService>();

  @override
  void initState() {
    super.initState();

    final p = widget.player;

    _nameCtrl = TextEditingController(text: p?.name ?? "");
    _ageCtrl = TextEditingController(text: p?.age?.toString() ?? "");
    _countryCtrl = TextEditingController(text: p?.country ?? "");
    _jerseyCtrl =
        TextEditingController(text: p?.jerseyNumber?.toString() ?? "");
    _phoneCtrl = TextEditingController(text: p?.phone ?? "");
    _emailCtrl = TextEditingController(text: p?.email ?? "");

    _photoUrl = p?.photo;

    _selectedGender = switch (p?.gender?.toLowerCase()) {
      'male' => 'Male',
      'female' => 'Female',
      'other' => 'Other',
      _ => null,
    };

    _selectedPositionId = p?.position?.id;
    _selectedClubId = p?.club?.id;

    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    setState(() => _loadingData = true);
    try {
      final clubs = await _api.getAllClubs();
      final rawPositions = await _api.getAllPositions();
      final positions =
          rawPositions.map((json) => Position.fromJson(json)).toList();

      setState(() {
        _clubs = clubs;
        _positions = positions;
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load clubs/positions");
    } finally {
      setState(() => _loadingData = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _pickedFile = picked;
      _isUploadingPhoto = true;
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
        _photoUrl = res.data['secure_url'];
      });

      Get.snackbar("Success", "Photo uploaded",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Photo upload failed", backgroundColor: Colors.red);
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.mode == PlayerFormMode.create) {
        if (_selectedClubId == null) {
          Get.snackbar("Error", "Please select a club",
              backgroundColor: Colors.red);
          setState(() => _isSubmitting = false);
          return;
        }

        final ageText = _ageCtrl.text.trim();
        final ageNum = int.tryParse(ageText);
        if (ageNum == null || ageNum < 10 || ageNum > 99) {
          Get.snackbar("Error", "Age must be a number between 10 and 99",
              backgroundColor: Colors.red);
          setState(() => _isSubmitting = false);
          return;
        }

        await _api.createPlayer(
          clubId: _selectedClubId!,
          name: _nameCtrl.text.trim(),
          age: ageNum,
          country: _countryCtrl.text.trim(),
          photo: _photoUrl,
          positionId: _selectedPositionId,
          jerseyNumber: _jerseyCtrl.text.trim().isEmpty
              ? null
              : int.tryParse(_jerseyCtrl.text.trim()),
          gender: _selectedGender?.toLowerCase(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        );

        Get.back(result: true);
        Get.snackbar("Success", "Player added",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        final updates = <String, dynamic>{
          'name': _nameCtrl.text.trim(),
          'country': _countryCtrl.text.trim(),
        };

        if (_selectedGender != null) {
          updates['gender'] = _selectedGender!.toLowerCase();
        }
        if (_selectedPositionId != null) {
          updates['position'] = _selectedPositionId;
        }
        if (_selectedClubId != null) updates['club'] = _selectedClubId;
        if (_phoneCtrl.text.trim().isNotEmpty) {
          updates['phone'] = _phoneCtrl.text.trim();
        }
        if (_emailCtrl.text.trim().isNotEmpty) {
          updates['email'] = _emailCtrl.text.trim();
        }
        if (_ageCtrl.text.trim().isNotEmpty) {
          updates['age'] = _ageCtrl.text.trim();
        }

        final jerseyText = _jerseyCtrl.text.trim();
        if (jerseyText.isNotEmpty) {
          final jerseyNum = int.tryParse(jerseyText);
          if (jerseyNum != null) updates['jerseyNumber'] = jerseyNum;
        }

        if (_photoUrl != null && _photoUrl != widget.player?.photo) {
          updates['photo'] = _photoUrl;
        }

        await _api.updatePlayer(widget.player!.id, updates);

        Get.back(result: true);
        Get.snackbar("Success", "Player updated successfully",
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
    _ageCtrl.dispose();
    _countryCtrl.dispose();
    _jerseyCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final hintColor = theme.textTheme.bodyMedium?.color;

    final isEdit = widget.mode == PlayerFormMode.edit;
    final title = isEdit ? "Edit Player" : "Add Player";

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                        color: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  color: textColor,
                ),
              ],
            ),
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickAndUploadPhoto,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  backgroundImage: _pickedFile != null
                      ? FileImage(File(_pickedFile!.path))
                      : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
                  child: _pickedFile == null && _photoUrl == null
                      ? Icon(Icons.camera_alt, size: 50, color: hintColor)
                      : null,
                ),
                if (_isUploadingPhoto)
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
                    if (_loadingData)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedClubId,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Club *",
                          labelStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                        ),
                        dropdownColor: theme.cardColor,
                        items: _clubs
                            .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClubId = v),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedPositionId,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Position",
                          labelStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                        ),
                        dropdownColor: theme.cardColor,
                        items: _positions
                            .map((p) => DropdownMenuItem(
                                value: p.id, child: Text(p.name)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPositionId = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedGender,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Gender",
                          labelStyle: TextStyle(color: hintColor),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade50,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          ),
                        ),
                        dropdownColor: theme.cardColor,
                        items: const [
                          DropdownMenuItem(value: "Male", child: Text("Male")),
                          DropdownMenuItem(
                              value: "Female", child: Text("Female")),
                          DropdownMenuItem(
                              value: "Other", child: Text("Other")),
                        ],
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _nameCtrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Full Name *",
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                      ),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    // Searchable Country Field using Autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return countries
                            .map((c) => c['name']!)
                            .where((String option) {
                          return option
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _countryCtrl.text = selection;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        // Keep in sync with our controller
                        textEditingController.text = _countryCtrl.text;
                        textEditingController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _countryCtrl.text.length),
                        );

                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onChanged: (value) {
                            setState(() {
                              _countryCtrl.text = value;
                            });
                          },
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            labelText: "Country *",
                            labelStyle: TextStyle(color: hintColor),
                            filled: true,
                            fillColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade50,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                            ),
                            suffixIcon: _countryCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _countryCtrl.clear();
                                        textEditingController.clear();
                                      });
                                    },
                                  )
                                : const Icon(Icons.arrow_drop_down),
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty ?? true ? "Required" : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageCtrl,
                      style: TextStyle(color: textColor),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Age *",
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                      ),
                      validator: (v) {
                        final num = int.tryParse(v ?? "");
                        if (num == null) return "Valid number required";
                        if (num < 10 || num > 99) return "Age 10-99";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jerseyCtrl,
                      style: TextStyle(color: textColor),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Jersey Number",
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      style: TextStyle(color: textColor),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      style: TextStyle(color: textColor),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: hintColor),
                        filled: true,
                        fillColor:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: theme.dividerColor),
                            ),
                            child: Text("Cancel",
                                style: TextStyle(color: textColor)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    isEdit ? "Save Changes" : "Add Player",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
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
