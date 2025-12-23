import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/Get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

    switch (p?.gender?.toLowerCase()) {
      case 'male':
        _selectedGender = 'Male';
        break;
      case 'female':
        _selectedGender = 'Female';
        break;
      case 'other':
        _selectedGender = 'Other';
        break;
    }

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
          Get.snackbar("Error", "Age must be a number between 10 and 909",
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

        if (_selectedClubId != null) {
          updates['club'] = _selectedClubId;
        }

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
          if (jerseyNum != null) {
            updates['jerseyNumber'] = jerseyNum;
          }
        }

        // Photo: only send if changed (new upload)
        if (_photoUrl != null && _photoUrl != widget.player?.photo) {
          updates['photo'] = _photoUrl;
        }

        final updatedPlayer =
            await _api.updatePlayer(widget.player!.id, updates);

        Get.back(result: updatedPlayer);
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
    final isEdit = widget.mode == PlayerFormMode.edit;
    final title = isEdit ? "Edit Player" : "Add Player";

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
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
            onTap: _pickAndUploadPhoto,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _pickedFile != null
                      ? FileImage(File(_pickedFile!.path))
                      : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
                  child: _pickedFile == null && _photoUrl == null
                      ? const Icon(Icons.camera_alt,
                          size: 50, color: Colors.grey)
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
                        decoration: const InputDecoration(labelText: "Club"),
                        hint: const Text("Select club "),
                        items: _clubs
                            .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClubId = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String?>(
                        initialValue: _selectedPositionId,
                        decoration:
                            const InputDecoration(labelText: "Position"),
                        hint: const Text("Select position"),
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
                        decoration: const InputDecoration(labelText: "Gender"),
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
                      decoration:
                          const InputDecoration(labelText: "Full Name *"),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageCtrl,
                      decoration: const InputDecoration(labelText: "Age *"),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final num = int.tryParse(v ?? "");
                        if (num == null) return "Valid number required";
                        if (num < 10 || num > 99) return "Age 10-99";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(labelText: "Country"),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jerseyCtrl,
                      decoration:
                          const InputDecoration(labelText: "Jersey Number"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(labelText: "Phone"),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: "Email"),
                      keyboardType: TextInputType.emailAddress,
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
                                : Text(isEdit ? "Save Changes" : "Add Player"),
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






// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:get/Get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../models/player_model.dart';
// import '../models/club_model.dart';
// import '../services/api_service.dart';

// enum PlayerFormMode { create, edit }

// class PlayerForm extends StatefulWidget {
//   final PlayerFormMode mode;
//   final Player? player;

//   const PlayerForm({
//     super.key,
//     required this.mode,
//     this.player,
//   });

//   @override
//   State<PlayerForm> createState() => _PlayerFormState();
// }

// class _PlayerFormState extends State<PlayerForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _picker = ImagePicker();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _ageCtrl;
//   late TextEditingController _countryCtrl;
//   late TextEditingController _jerseyCtrl;
//   late TextEditingController _phoneCtrl;
//   late TextEditingController _emailCtrl;

//   String? _selectedGender;
//   String? _selectedPositionId;
//   String? _selectedClubId;

//   List<Position> _positions = [];
//   List<ClubModel> _clubs = [];

//   bool _loadingData = true;
//   bool _isSubmitting = false;
//   bool _isUploadingPhoto = false;

//   XFile? _pickedFile;
//   String? _photoUrl;

//   final ApiService _api = Get.find<ApiService>();

//   @override
//   void initState() {
//     super.initState();

//     final p = widget.player;

//     _nameCtrl = TextEditingController(text: p?.name ?? "");
//     _ageCtrl = TextEditingController(text: p?.age?.toString() ?? "");
//     _countryCtrl = TextEditingController(text: p?.country ?? "");
//     _jerseyCtrl =
//         TextEditingController(text: p?.jerseyNumber?.toString() ?? "");
//     _phoneCtrl = TextEditingController(text: p?.phone ?? "");
//     _emailCtrl = TextEditingController(text: p?.email ?? "");

//     _photoUrl = p?.photo;

//     switch (p?.gender?.toLowerCase()) {
//       case 'male':
//         _selectedGender = 'Male';
//         break;
//       case 'female':
//         _selectedGender = 'Female';
//         break;
//       case 'other':
//         _selectedGender = 'Other';
//         break;
//     }

//     _selectedPositionId = p?.position?.id;
//     _selectedClubId = p?.club?.id;

//     _loadDropdowns();
//   }

//   Future<void> _loadDropdowns() async {
//     setState(() => _loadingData = true);
//     try {
//       final clubs = await _api.getAllClubs();
//       final rawPositions = await _api.getAllPositions();
//       final positions =
//           rawPositions.map((json) => Position.fromJson(json)).toList();

//       setState(() {
//         _clubs = clubs;
//         _positions = positions;
//       });
//     } catch (e) {
//       Get.snackbar("Error", "Failed to load clubs/positions");
//     } finally {
//       setState(() => _loadingData = false);
//     }
//   }

//   Future<void> _pickAndUploadPhoto() async {
//     final picked =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
//     if (picked == null) return;

//     setState(() {
//       _pickedFile = picked;
//       _isUploadingPhoto = true;
//     });

//     try {
//       final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
//       final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

//       final formData = dio.FormData.fromMap({
//         'file': await dio.MultipartFile.fromFile(picked.path),
//         'upload_preset': preset,
//       });

//       final res = await dio.Dio().post(
//         'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
//         data: formData,
//       );

//       setState(() {
//         _photoUrl = res.data['secure_url'];
//       });

//       Get.snackbar("Success", "Photo uploaded",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       Get.snackbar("Error", "Photo upload failed", backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isUploadingPhoto = false);
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       if (widget.mode == PlayerFormMode.create) {
//         if (_selectedClubId == null) {
//           Get.snackbar("Error", "Please select a club",
//               backgroundColor: Colors.red);
//           setState(() => _isSubmitting = false);
//           return;
//         }

//         final ageText = _ageCtrl.text.trim();
//         final ageNum = int.tryParse(ageText);
//         if (ageNum == null || ageNum < 10 || ageNum > 99) {
//           Get.snackbar("Error", "Age must be a number between 10 and 99",
//               backgroundColor: Colors.red);
//           setState(() => _isSubmitting = false);
//           return;
//         }

//         await _api.createPlayer(
//           clubId: _selectedClubId!,
//           name: _nameCtrl.text.trim(),
//           age: ageNum,
//           country: _countryCtrl.text.trim(),
//           photo: _photoUrl,
//           positionId: _selectedPositionId,
//           jerseyNumber: _jerseyCtrl.text.trim().isEmpty
//               ? null
//               : int.tryParse(_jerseyCtrl.text.trim()),
//           gender: _selectedGender?.toLowerCase(),
//           phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
//           email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
//         );

//         Get.back(result: true);
//         Get.snackbar("Success", "Player added successfully",
//             backgroundColor: Colors.green, colorText: Colors.white);
//       } else {
//         final formData = dio.FormData();

//         formData.fields.addAll([
//           MapEntry('name', _nameCtrl.text.trim()),
//           MapEntry('country', _countryCtrl.text.trim()),
//           if (_selectedGender != null)
//             MapEntry('gender', _selectedGender!.toLowerCase()),
//           if (_selectedPositionId != null)
//             MapEntry('position', _selectedPositionId!),
//           if (_selectedClubId != null) MapEntry('club', _selectedClubId!),
//           if (_phoneCtrl.text.trim().isNotEmpty)
//             MapEntry('phone', _phoneCtrl.text.trim()),
//           if (_emailCtrl.text.trim().isNotEmpty)
//             MapEntry('email', _emailCtrl.text.trim()),
//         ]);

//         final age = _ageCtrl.text.trim();
//         if (age.isNotEmpty) formData.fields.add(MapEntry('age', age));

//         final jersey = int.tryParse(_jerseyCtrl.text.trim());
//         if (jersey != null) {
//           formData.fields.add(MapEntry('jerseyNumber', jersey.toString()));
//         }

//         if (_pickedFile != null) {
//           formData.files.add(MapEntry(
//             'photo',
//             await dio.MultipartFile.fromFile(_pickedFile!.path,
//                 filename: _pickedFile!.name),
//           ));
//         }

//         await _api.updatePlayer(widget.player!.id, formData);

//         Get.back(result: true);
//         Get.snackbar("Success", "Player updated successfully",
//             backgroundColor: Colors.green, colorText: Colors.white);
//       }
//     } catch (e) {
//       Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _ageCtrl.dispose();
//     _countryCtrl.dispose();
//     _jerseyCtrl.dispose();
//     _phoneCtrl.dispose();
//     _emailCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.mode == PlayerFormMode.edit;
//     final title = isEdit ? "Edit Player" : "Add Player";

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.94,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//             child: Row(
//               children: [
//                 const SizedBox(width: 40),
//                 Expanded(
//                   child: Center(
//                     child: Container(
//                       width: 50,
//                       height: 5,
//                       decoration: BoxDecoration(
//                           color: Colors.grey[400],
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                     icon: const Icon(Icons.close), onPressed: () => Get.back()),
//               ],
//             ),
//           ),
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.deepPurple)),
//           const SizedBox(height: 20),
//           GestureDetector(
//             onTap: _pickAndUploadPhoto,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 70,
//                   backgroundImage: _pickedFile != null
//                       ? FileImage(File(_pickedFile!.path))
//                       : (_photoUrl != null ? NetworkImage(_photoUrl!) : null),
//                   child: _pickedFile == null && _photoUrl == null
//                       ? const Icon(Icons.camera_alt,
//                           size: 50, color: Colors.grey)
//                       : null,
//                 ),
//                 if (_isUploadingPhoto)
//                   const CircularProgressIndicator(color: Colors.deepPurple),
//               ],
//             ),
//           ),
//           const SizedBox(height: 30),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     if (_loadingData)
//                       const Center(child: CircularProgressIndicator())
//                     else ...[
//                       // Club - required for create
//                       DropdownButtonFormField<String>(
//                         initialValue: _selectedClubId,
//                         decoration: const InputDecoration(labelText: "Club *"),
//                         hint: const Text("Select club"),
//                         items: _clubs
//                             .map((c) => DropdownMenuItem(
//                                 value: c.id, child: Text(c.name)))
//                             .toList(),
//                         onChanged: (v) => setState(() => _selectedClubId = v),
//                         validator: widget.mode == PlayerFormMode.create
//                             ? (v) => v == null ? "Required" : null
//                             : null,
//                       ),
//                       const SizedBox(height: 16),

//                       // Position - optional
//                       DropdownButtonFormField<String?>(
//                         initialValue: _selectedPositionId,
//                         decoration:
//                             const InputDecoration(labelText: "Position"),
//                         hint: const Text("Select position "),
//                         items: _positions
//                             .map((p) => DropdownMenuItem(
//                                 value: p.id, child: Text(p.name)))
//                             .toList(),
//                         onChanged: (v) =>
//                             setState(() => _selectedPositionId = v),
//                       ),
//                       const SizedBox(height: 16),

//                       // Gender - optional
//                       DropdownButtonFormField<String?>(
//                         initialValue: _selectedGender,
//                         decoration: const InputDecoration(labelText: "Gender"),
//                         items: const [
//                           DropdownMenuItem(value: "Male", child: Text("Male")),
//                           DropdownMenuItem(
//                               value: "Female", child: Text("Female")),
//                           DropdownMenuItem(
//                               value: "Other", child: Text("Other")),
//                         ],
//                         onChanged: (v) => setState(() => _selectedGender = v),
//                       ),
//                       const SizedBox(height: 16),
//                     ],
//                     TextFormField(
//                       controller: _nameCtrl,
//                       decoration:
//                           const InputDecoration(labelText: "Full Name *"),
//                       validator: (v) =>
//                           v?.trim().isEmpty ?? true ? "Required" : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _ageCtrl,
//                       decoration: const InputDecoration(labelText: "Age *"),
//                       keyboardType: TextInputType.number,
//                       validator: (v) {
//                         final num = int.tryParse(v ?? "");
//                         if (num == null) return "Valid number required";
//                         if (num < 10 || num > 99) return "Age 10-99";
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _countryCtrl,
//                       decoration: const InputDecoration(labelText: "Country *"),
//                       validator: (v) =>
//                           v?.trim().isEmpty ?? true ? "Required" : null,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _jerseyCtrl,
//                       decoration:
//                           const InputDecoration(labelText: "Jersey Number"),
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _phoneCtrl,
//                       decoration: const InputDecoration(labelText: "Phone"),
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _emailCtrl,
//                       decoration: const InputDecoration(labelText: "Email"),
//                       keyboardType: TextInputType.emailAddress,
//                     ),
//                     const SizedBox(height: 40),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: _isSubmitting ? null : () => Get.back(),
//                             child: const Text("Cancel"),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: _isSubmitting ? null : _submit,
//                             style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.deepPurple),
//                             child: _isSubmitting
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white)
//                                 : Text(isEdit ? "Save Changes" : "Add Player"),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
