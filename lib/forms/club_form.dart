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
        await _api.createClub(
          name: _nameCtrl.text.trim(),
          country: _countryCtrl.text.trim(),
          level: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
          logo: _logoUrl,
        );

        Get.back(result: true);
        Get.snackbar("Success", "Club added successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
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

        await _api.updateClub(widget.club!.id, updates);

        Get.back(result: true);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final hintColor = theme.textTheme.bodyMedium?.color;

    final isEdit = widget.mode == ClubFormMode.edit;
    final title = isEdit ? "Edit Club" : "Add Club";

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickAndUploadLogo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  backgroundImage: _pickedFile != null
                      ? FileImage(File(_pickedFile!.path))
                      : (_logoUrl != null ? NetworkImage(_logoUrl!) : null),
                  child: _pickedFile == null && _logoUrl == null
                      ? Icon(Icons.sports_soccer, size: 60, color: hintColor)
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
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Club Name *",
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
                    TextFormField(
                      controller: _countryCtrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Country *",
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
                    TextFormField(
                      controller: _levelCtrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        labelText: "Level (e.g. Premier, Division 1)",
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
                                    isEdit ? "Save Changes" : "Add Club",
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


// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:get/Get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../models/club_model.dart';
// import '../services/api_service.dart';

// enum ClubFormMode { create, edit }

// class ClubForm extends StatefulWidget {
//   final ClubFormMode mode;
//   final ClubModel? club;

//   const ClubForm({
//     super.key,
//     required this.mode,
//     this.club,
//   });

//   @override
//   State<ClubForm> createState() => _ClubFormState();
// }

// class _ClubFormState extends State<ClubForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _picker = ImagePicker();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _countryCtrl;
//   late TextEditingController _levelCtrl;

//   bool _isSubmitting = false;
//   bool _isUploadingLogo = false;

//   XFile? _pickedFile;
//   String? _logoUrl;

//   final ApiService _api = Get.find<ApiService>();

//   @override
//   void initState() {
//     super.initState();

//     final c = widget.club;

//     _nameCtrl = TextEditingController(text: c?.name ?? "");
//     _countryCtrl = TextEditingController(text: c?.country ?? "");
//     _levelCtrl = TextEditingController(text: c?.level ?? "");

//     _logoUrl = c?.logo;
//   }

//   Future<void> _pickAndUploadLogo() async {
//     final picked =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
//     if (picked == null) return;

//     setState(() {
//       _pickedFile = picked;
//       _isUploadingLogo = true;
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
//         _logoUrl = res.data['secure_url'];
//       });

//       Get.snackbar("Success", "Logo uploaded",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       Get.snackbar("Error", "Logo upload failed", backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isUploadingLogo = false);
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       if (widget.mode == ClubFormMode.create) {
//         await _api.createClub(
//           name: _nameCtrl.text.trim(),
//           country: _countryCtrl.text.trim(),
//           level: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
//           logo: _logoUrl,
//         );

//         Get.back(result: true);
//         Get.snackbar("Success", "Club added successfully",
//             backgroundColor: Colors.green, colorText: Colors.white);
//       } else {
//         final updates = <String, dynamic>{
//           'name': _nameCtrl.text.trim(),
//           'country': _countryCtrl.text.trim(),
//         };

//         if (_levelCtrl.text.trim().isNotEmpty) {
//           updates['level'] = _levelCtrl.text.trim();
//         }

//         if (_logoUrl != null && _logoUrl != widget.club?.logo) {
//           updates['logo'] = _logoUrl;
//         }

//         await _api.updateClub(widget.club!.id, updates);

//         Get.back(result: true);
//         Get.snackbar("Success", "Club updated successfully",
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
//     _countryCtrl.dispose();
//     _levelCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.mode == ClubFormMode.edit;
//     final title = isEdit ? "Edit Club" : "Add Club";

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
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
//             onTap: _pickAndUploadLogo,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 70,
//                   backgroundImage: _pickedFile != null
//                       ? FileImage(File(_pickedFile!.path))
//                       : (_logoUrl != null ? NetworkImage(_logoUrl!) : null),
//                   child: _pickedFile == null && _logoUrl == null
//                       ? const Icon(Icons.sports_soccer,
//                           size: 60, color: Colors.grey)
//                       : null,
//                 ),
//                 if (_isUploadingLogo)
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
//                     TextFormField(
//                       controller: _nameCtrl,
//                       decoration:
//                           const InputDecoration(labelText: "Club Name *"),
//                       validator: (v) =>
//                           v?.trim().isEmpty ?? true ? "Required" : null,
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
//                       controller: _levelCtrl,
//                       decoration: const InputDecoration(
//                           labelText: "Level (e.g. Premier, Division 1)"),
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
//                                 : Text(isEdit ? "Save Changes" : "Add Club"),
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












// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';

// enum ClubFormMode { create, edit }

// class ClubForm extends StatefulWidget {
//   final ClubFormMode mode;
//   final ClubModel? clubToEdit;

//   const ClubForm({
//     super.key,
//     required this.mode,
//     this.clubToEdit,
//     required ClubModel club,
//   });

//   @override
//   State<ClubForm> createState() => _ClubFormState();
// }

// class _ClubFormState extends State<ClubForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _shortNameCtrl;
//   late TextEditingController _countryCtrl;
//   late TextEditingController _levelCtrl;
//   late TextEditingController _logoCtrl;

//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();

//     final club = widget.clubToEdit;

//     _nameCtrl = TextEditingController(text: club?.name ?? "");
//     _shortNameCtrl = TextEditingController(text: club?.shortName ?? "");
//     _countryCtrl = TextEditingController(text: club?.country ?? "");
//     _levelCtrl = TextEditingController(text: club?.level ?? "");
//     _logoCtrl = TextEditingController(text: club?.logo ?? "");
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _loading = true);

//     try {
//       final data = {
//         "name": _nameCtrl.text.trim(),
//         "shortName": _shortNameCtrl.text.trim().isEmpty
//             ? null
//             : _shortNameCtrl.text.trim(),
//         "country": _countryCtrl.text.trim(),
//         "level": _levelCtrl.text.trim(),
//         "logo": _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
//       };

//       if (widget.mode == ClubFormMode.create) {
//         await api.createClub(data);
//       } else {
//         await api.updateClub(widget.clubToEdit!.id, data);
//       }

//       Get.back(result: true);
//     } catch (e) {
//       Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _shortNameCtrl.dispose();
//     _countryCtrl.dispose();
//     _levelCtrl.dispose();
//     _logoCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color;
//     final hintColor = theme.textTheme.bodyMedium?.color;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: DraggableScrollableSheet(
//         initialChildSize: 0.88,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, controller) => Container(
//           decoration: BoxDecoration(
//             color: theme.scaffoldBackgroundColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//           ),
//           child: Column(
//             children: [
//               // Handle bar
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 width: 50,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),

//               // Title
//               Text(
//                 widget.mode == ClubFormMode.create ? "Add Club" : "Edit Club",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Form
//               Expanded(
//                 child: ListView(
//                   controller: controller,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   children: [
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: _nameCtrl,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Club Name",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon:
//                                   Icon(Icons.sports_soccer, color: hintColor),
//                               filled: true,
//                               fillColor: isDark
//                                   ? Colors.grey.shade800
//                                   : Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark
//                                         ? Colors.grey.shade700
//                                         : Colors.grey.shade300),
//                               ),
//                             ),
//                             validator: (v) =>
//                                 v?.trim().isEmpty ?? true ? "Required" : null,
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _shortNameCtrl,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Short Name (optional)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon:
//                                   Icon(Icons.short_text, color: hintColor),
//                               filled: true,
//                               fillColor: isDark
//                                   ? Colors.grey.shade800
//                                   : Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark
//                                         ? Colors.grey.shade700
//                                         : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _countryCtrl,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Country",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.flag, color: hintColor),
//                               filled: true,
//                               fillColor: isDark
//                                   ? Colors.grey.shade800
//                                   : Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark
//                                         ? Colors.grey.shade700
//                                         : Colors.grey.shade300),
//                               ),
//                             ),
//                             validator: (v) =>
//                                 v?.trim().isEmpty ?? true ? "Required" : null,
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _levelCtrl,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Level (e.g., Premier, Division II)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon:
//                                   Icon(Icons.emoji_events, color: hintColor),
//                               filled: true,
//                               fillColor: isDark
//                                   ? Colors.grey.shade800
//                                   : Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark
//                                         ? Colors.grey.shade700
//                                         : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           TextFormField(
//                             controller: _logoCtrl,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Logo URL (optional)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.image, color: hintColor),
//                               filled: true,
//                               fillColor: isDark
//                                   ? Colors.grey.shade800
//                                   : Colors.grey.shade50,
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark
//                                         ? Colors.grey.shade700
//                                         : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () => Get.back(),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16),
//                                     side: BorderSide(color: theme.dividerColor),
//                                   ),
//                                   child: Text("Cancel",
//                                       style: TextStyle(color: textColor)),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: _loading ? null : _save,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.deepPurple,
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             BorderRadius.circular(16)),
//                                   ),
//                                   child: _loading
//                                       ? const SizedBox(
//                                           height: 20,
//                                           width: 20,
//                                           child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2),
//                                         )
//                                       : Text(
//                                           widget.mode == ClubFormMode.create
//                                               ? "Create Club"
//                                               : "Save Changes",
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               color: Colors.white),
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';

// enum ClubFormMode { create, edit }

// class ClubForm extends StatefulWidget {
//   final ClubFormMode mode;
//   final ClubModel? clubToEdit;

//   const ClubForm({super.key, required this.mode, this.clubToEdit});

//   @override
//   State<ClubForm> createState() => _ClubFormState();
// }

// class _ClubFormState extends State<ClubForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();

//   late TextEditingController nameController;
//   late TextEditingController shortNameController;
//   late TextEditingController countryController;
//   late TextEditingController levelController;
//   late TextEditingController logoController;

//   bool loading = false;

//   @override
//   void initState() {
//     super.initState();

//     final club = widget.clubToEdit;

//     nameController = TextEditingController(text: club?.name ?? "");
//     shortNameController = TextEditingController(text: club?.shortName ?? "");
//     countryController = TextEditingController(text: club?.country ?? "");
//     levelController = TextEditingController(text: club?.level ?? "");
//     logoController = TextEditingController(text: club?.logo ?? "");
//   }

//   Future<void> saveClub() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => loading = true);

//     try {
//       final data = {
//         "name": nameController.text.trim(),
//         "shortName": shortNameController.text.trim(),
//         "country": countryController.text.trim(),
//         "level": levelController.text.trim(),
//         "logo": logoController.text.trim().isEmpty ? null : logoController.text.trim(),
//       };

//       if (widget.mode == ClubFormMode.create) {
//         await api.createClub(data);
//       } else {
//         await api.updateClub(widget.clubToEdit!.id, data);
//       }

//       if (mounted) Get.back(result: true);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color;
//     final hintColor = theme.textTheme.bodyMedium?.color;

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: DraggableScrollableSheet(
//         initialChildSize: 0.88,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, controller) => Container(
//           decoration: BoxDecoration(
//             color: theme.scaffoldBackgroundColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//           ),
//           child: Column(
//             children: [
//               // Handle bar
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 width: 50,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),

//               // Title
//               Text(
//                 widget.mode == ClubFormMode.create ? "Add Club" : "Edit Club",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Form
//               Expanded(
//                 child: ListView(
//                   controller: controller,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   children: [
//                     Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: nameController,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Club Name",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.sports_soccer, color: hintColor),
//                               filled: true,
//                               fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                               ),
//                             ),
//                             validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
//                           ),
//                           const SizedBox(height: 16),

//                           TextFormField(
//                             controller: shortNameController,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Short Name (optional)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.short_text, color: hintColor),
//                               filled: true,
//                               fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           TextFormField(
//                             controller: countryController,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Country",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.flag, color: hintColor),
//                               filled: true,
//                               fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                               ),
//                             ),
//                             validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
//                           ),
//                           const SizedBox(height: 16),

//                           TextFormField(
//                             controller: levelController,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Level (e.g., Premier, Division II)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.emoji_events, color: hintColor),
//                               filled: true,
//                               fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),

//                           TextFormField(
//                             controller: logoController,
//                             style: TextStyle(color: textColor),
//                             decoration: InputDecoration(
//                               labelText: "Logo URL (optional)",
//                               labelStyle: TextStyle(color: hintColor),
//                               prefixIcon: Icon(Icons.image, color: hintColor),
//                               filled: true,
//                               fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                                 borderSide: BorderSide(
//                                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 32),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: OutlinedButton(
//                                   onPressed: () => Get.back(),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(vertical: 16),
//                                     side: BorderSide(color: theme.dividerColor),
//                                   ),
//                                   child: Text("Cancel", style: TextStyle(color: textColor)),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: loading ? null : saveClub,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.deepPurple,
//                                     padding: const EdgeInsets.symmetric(vertical: 16),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                                   ),
//                                   child: loading
//                                       ? const SizedBox(
//                                           height: 20,
//                                           width: 20,
//                                           child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                                         )
//                                       : Text(
//                                           widget.mode == ClubFormMode.create ? "Create Club" : "Save Changes",
//                                           style: const TextStyle(fontSize: 16, color: Colors.white),
//                                         ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 40),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     shortNameController.dispose();
//     countryController.dispose();
//     levelController.dispose();
//     logoController.dispose();
//     super.dispose();
//   }
// }






// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:get/Get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// import '../models/club_model.dart';
// import '../services/api_service.dart';

// enum ClubFormMode { create, edit }

// class ClubForm extends StatefulWidget {
//   final ClubFormMode mode;
//   final ClubModel? club;

//   const ClubForm({
//     super.key,
//     required this.mode,
//     this.club,
//   });

//   @override
//   State<ClubForm> createState() => _ClubFormState();
// }

// class _ClubFormState extends State<ClubForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _picker = ImagePicker();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _countryCtrl;
//   late TextEditingController _levelCtrl;

//   bool _isSubmitting = false;
//   bool _isUploadingLogo = false;

//   XFile? _pickedFile;
//   String? _logoUrl;

//   final ApiService _api = Get.find<ApiService>();

//   @override
//   void initState() {
//     super.initState();

//     final c = widget.club;

//     _nameCtrl = TextEditingController(text: c?.name ?? "");
//     _countryCtrl = TextEditingController(text: c?.country ?? "");
//     _levelCtrl = TextEditingController(text: c?.level ?? "");

//     _logoUrl = c?.logo;
//   }

//   Future<void> _pickAndUploadLogo() async {
//     final picked =
//         await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
//     if (picked == null) return;

//     setState(() {
//       _pickedFile = picked;
//       _isUploadingLogo = true;
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
//         _logoUrl = res.data['secure_url'];
//       });

//       Get.snackbar("Success", "Logo uploaded",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       Get.snackbar("Error", "Logo upload failed", backgroundColor: Colors.red);
//     } finally {
//       setState(() => _isUploadingLogo = false);
//     }
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {
//       if (widget.mode == ClubFormMode.create) {
//         final newClub = await _api.createClub(
//           name: _nameCtrl.text.trim(),
//           country: _countryCtrl.text.trim(),
//           logo: _logoUrl,
//           level: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
//         );

//         Get.back(result: newClub);
//         Get.snackbar("Success", "Club added successfully",
//             backgroundColor: Colors.green, colorText: Colors.white);
//       } else {
//         // Edit mode
//         final updates = <String, dynamic>{
//           'name': _nameCtrl.text.trim(),
//           'country': _countryCtrl.text.trim(),
//         };

//         if (_levelCtrl.text.trim().isNotEmpty) {
//           updates['level'] = _levelCtrl.text.trim();
//         }

//         if (_logoUrl != null && _logoUrl != widget.club?.logo) {
//           updates['logo'] = _logoUrl;
//         }

//         // Use club id for update (as per your backend)
//         final updatedClub = await _api.updateClub(widget.club!.id, updates);

//         Get.back(result: updatedClub);
//         Get.snackbar("Success", "Club updated successfully",
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
//     _countryCtrl.dispose();
//     _levelCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.mode == ClubFormMode.edit;
//     final title = isEdit ? "Edit Club" : "Add Club";

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.9,
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
//             onTap: _pickAndUploadLogo,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 70,
//                   backgroundImage: _pickedFile != null
//                       ? FileImage(File(_pickedFile!.path))
//                       : (_logoUrl != null ? NetworkImage(_logoUrl!) : null),
//                   child: _pickedFile == null && _logoUrl == null
//                       ? const Icon(Icons.sports_soccer,
//                           size: 60, color: Colors.grey)
//                       : null,
//                 ),
//                 if (_isUploadingLogo)
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
//                     TextFormField(
//                       controller: _nameCtrl,
//                       decoration:
//                           const InputDecoration(labelText: "Club Name *"),
//                       validator: (v) =>
//                           v?.trim().isEmpty ?? true ? "Required" : null,
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
//                       controller: _levelCtrl,
//                       decoration: const InputDecoration(
//                           labelText: "Level (e.g. Premier, Division 1)"),
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
//                                 : Text(isEdit ? "Save Changes" : "Add Club"),
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
