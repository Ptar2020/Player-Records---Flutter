import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../services/api_service.dart';
import '../../models/club_model.dart';

class AddPlayerModal extends StatefulWidget {
  const AddPlayerModal({super.key});

  @override
  State<AddPlayerModal> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerModal> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  bool _isLoadingData = true;

  XFile? _imageFile;
  String? _photoUrl;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController(text: "");
  final _jerseyCtrl = TextEditingController();

  String? _selectedClubId;
  String? _selectedPositionId;

  List<ClubModel> _clubs = [];
  List<Map<String, dynamic>> _positions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final clubs = await api.getAllClubs();
      final positions = await api.getAllPositions();
      setState(() {
        _clubs = clubs;
        _positions = positions;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Failed to load players",
          textColor: Colors.white54,
          backgroundColor: Colors.black);

      // Fluttertoast.showToast(msg: "Load failed", backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _uploadPhoto() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      _imageFile = picked;
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

      setState(() => _photoUrl = res.data['secure_url']);
      Fluttertoast.showToast(
          msg: "Photo uploaded", backgroundColor: Colors.green);
    } catch (e) {
      Fluttertoast.showToast(msg: "Upload failed", backgroundColor: Colors.red);
    } finally {
      setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClubId == null) {
      Fluttertoast.showToast(
          msg: "Select club", backgroundColor: Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await api.createPlayer(
        clubId: _selectedClubId!,
        name: _nameCtrl.text,
        age: int.parse(_ageCtrl.text),
        country: _nationalityCtrl.text,
        photo: _photoUrl,
        positionId: _selectedPositionId,
        jerseyNumber:
            _jerseyCtrl.text.isEmpty ? null : int.tryParse(_jerseyCtrl.text),
      );

      Fluttertoast.showToast(
          msg: "Player added!", backgroundColor: Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString().replaceAll("Exception: ", ""),
          backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
        prefixIcon: Icon(icon, color: theme.textTheme.bodyMedium?.color),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = 60.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag handle + Close
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: theme.textTheme.bodyLarge?.color),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Text(
            "Add Player",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Photo
                    GestureDetector(
                      onTap: _uploadPhoto,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: radius,
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            backgroundImage: _imageFile != null
                                ? FileImage(File(_imageFile!.path))
                                : (_photoUrl != null
                                    ? NetworkImage(_photoUrl!)
                                    : null) as ImageProvider?,
                          ),
                          if (_isUploadingPhoto)
                            CircularProgressIndicator(
                                color: theme.primaryColor),
                          if (_imageFile == null &&
                              _photoUrl == null &&
                              !_isUploadingPhoto)
                            Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    if (_isLoadingData)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // Club Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedClubId,
                        decoration: InputDecoration(
                          labelText: "Club *",
                          labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                          prefixIcon: Icon(Icons.sports_soccer,
                              color: theme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
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
                        hint: const Text("Select club"),
                        dropdownColor: theme.cardColor,
                        items: _clubs
                            .map((c) => DropdownMenuItem(
                                value: c.id, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedClubId = v),
                        validator: (v) => v == null ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Position Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPositionId,
                        decoration: InputDecoration(
                          labelText: "Position",
                          labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color),
                          prefixIcon: Icon(Icons.directions_run,
                              color: theme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100,
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
                        hint: const Text("Select position"),
                        dropdownColor: theme.cardColor,
                        items: _positions.map((p) {
                          final id =
                              p['id']?.toString() ?? p['_id']?.toString() ?? "";
                          return DropdownMenuItem(
                              value: id, child: Text(p['name'] ?? ""));
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPositionId = v),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Text Fields
                    _buildTextField(
                        controller: _nameCtrl,
                        label: "Name *",
                        icon: Icons.person,
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? "Required" : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _ageCtrl,
                        label: "Age *",
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            int.tryParse(v ?? "") == null ? "Valid age" : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _nationalityCtrl,
                        label: "Nationality",
                        icon: Icons.flag),
                    const SizedBox(height: 16),
                    _buildTextField(
                        controller: _jerseyCtrl,
                        label: "Jersey #",
                        icon: Icons.confirmation_number,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Add Player",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                      ),
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _nationalityCtrl.dispose();
    _jerseyCtrl.dispose();
    super.dispose();
  }
}







// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:image_picker/image_picker.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../../services/api_service.dart';
// import '../../models/club_model.dart';

// class AddPlayerModal extends StatefulWidget {
//   const AddPlayerModal({Key? key}) : super(key: key);

//   @override
//   State<AddPlayerModal> createState() => _AddPlayerScreenState();
// }

// class _AddPlayerScreenState extends State<AddPlayerModal> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();
//   final ImagePicker _picker = ImagePicker();

//   bool _isLoading = false;
//   bool _isUploadingPhoto = false;
//   bool _isLoadingData = true;

//   XFile? _imageFile;
//   String? _photoUrl;

//   final _nameCtrl = TextEditingController();
//   final _ageCtrl = TextEditingController();
//   final _nationalityCtrl = TextEditingController(text: "Unknown");
//   final _jerseyCtrl = TextEditingController();

//   String? _selectedClubId;
//   String? _selectedPositionId;

//   List<ClubModel> _clubs = [];
//   List<Map<String, dynamic>> _positions = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoadingData = true);
//     try {
//       final clubs = await api.getAllClubs();
//       final positions = await api.getAllPositions();
//       setState(() {
//         _clubs = clubs;
//         _positions = positions;
//       });
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Load failed", backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isLoadingData = false);
//     }
//   }

//   Future<void> _uploadPhoto() async {
//     final picked = await _picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 85,
//     );
//     if (picked == null) return;

//     setState(() {
//       _imageFile = picked;
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

//       setState(() => _photoUrl = res.data['secure_url']);
//       Fluttertoast.showToast(msg: "Photo uploaded");
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Upload failed", backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isUploadingPhoto = false);
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedClubId == null) {
//       Fluttertoast.showToast(
//           msg: "Select club", backgroundColor: Colors.orange);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       await api.createPlayer(
//         clubId: _selectedClubId!,
//         name: _nameCtrl.text,
//         age: int.parse(_ageCtrl.text),
//         country: _nationalityCtrl.text,
//         photo: _photoUrl,
//         positionId: _selectedPositionId,
//         jerseyNumber:
//             _jerseyCtrl.text.isEmpty ? null : int.tryParse(_jerseyCtrl.text),
//       );

//       Fluttertoast.showToast(
//           msg: "Player added!", backgroundColor: Colors.green);
//       Navigator.pop(context, true);
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: e.toString().replaceAll("Exception: ", ""),
//           backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         filled: true,
//         fillColor: Colors.grey[100],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final radius = 60.0;
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.94,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const SizedBox(width: 48),
//                 Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[400],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//           const Text(
//             "Add Player",
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Profile Photo
//                     GestureDetector(
//                       onTap: _uploadPhoto,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: radius,
//                             backgroundColor: Colors.grey[200],
//                             backgroundImage: _imageFile != null
//                                 ? FileImage(File(_imageFile!.path))
//                                 : (_photoUrl != null
//                                     ? NetworkImage(_photoUrl!)
//                                     : null) as ImageProvider?,
//                           ),
//                           if (_isUploadingPhoto)
//                             const CircularProgressIndicator(),
//                           if (_imageFile == null &&
//                               _photoUrl == null &&
//                               !_isUploadingPhoto)
//                             Icon(
//                               Icons.camera_alt,
//                               size: 40,
//                               color: Colors.grey[700],
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),

//                     // Loading indicator while data loads
//                     if (_isLoadingData)
//                       const Center(child: CircularProgressIndicator())
//                     else ...[
//                       DropdownButtonFormField<String>(
//                         value: _selectedClubId,
//                         decoration: InputDecoration(
//                           labelText: "Club *",
//                           prefixIcon: const Icon(Icons.sports_soccer),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                         ),
//                         hint: const Text("Select club"),
//                         items: _clubs
//                             .map((c) => DropdownMenuItem(
//                                 value: c.id, child: Text(c.name)))
//                             .toList(),
//                         onChanged: (v) => setState(() => _selectedClubId = v),
//                         validator: (v) => v == null ? "Required" : null,
//                       ),
//                       const SizedBox(height: 16),
//                       DropdownButtonFormField<String>(
//                         value: _selectedPositionId,
//                         decoration: InputDecoration(
//                           labelText: "Position",
//                           prefixIcon: const Icon(Icons.directions_run),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                         ),
//                         hint: const Text("Select position"),
//                         items: _positions.map((p) {
//                           final id =
//                               p['id']?.toString() ?? p['_id']?.toString() ?? "";
//                           return DropdownMenuItem(
//                               value: id, child: Text(p['name'] ?? ""));
//                         }).toList(),
//                         onChanged: (v) =>
//                             setState(() => _selectedPositionId = v),
//                       ),
//                       const SizedBox(height: 20),
//                     ],

//                     _buildTextField(
//                       controller: _nameCtrl,
//                       label: "Name *",
//                       icon: Icons.person,
//                       validator: (v) =>
//                           v?.trim().isEmpty ?? true ? "Required" : null,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _ageCtrl,
//                       label: "Age *",
//                       icon: Icons.cake,
//                       keyboardType: TextInputType.number,
//                       validator: (v) =>
//                           int.tryParse(v ?? "") == null ? "Valid age" : null,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _nationalityCtrl,
//                       label: "Nationality",
//                       icon: Icons.flag,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildTextField(
//                       controller: _jerseyCtrl,
//                       label: "Jersey #",
//                       icon: Icons.confirmation_number,
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 40),

//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _submit,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : const Text(
//                                 "Add Player",
//                                 style: TextStyle(
//                                     fontSize: 18, color: Colors.white),
//                               ),
//                       ),
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

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _ageCtrl.dispose();
//     _nationalityCtrl.dispose();
//     _jerseyCtrl.dispose();
//     super.dispose();
//   }
// }
