import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:precords_android/models/club_model.dart';
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
  late TextEditingController _country;

  String? _selectedGender; // UI: "Male", "Female", "Other"
  String? _selectedPositionId;
  String? _selectedClubId;

  List<Position> _positions = [];
  List<ClubModel> _clubs = [];

  bool _loadingPositions = true;
  bool _loadingClubs = true;

  XFile? _photoFile;

  @override
  void initState() {
    super.initState();
    final p = widget.player;

    _name = TextEditingController(text: p.name);
    _age = TextEditingController(text: p.age?.toString() ?? "");
    _phone = TextEditingController(text: p.phone ?? "");
    _email = TextEditingController(text: p.email ?? "");
    _jersey = TextEditingController(text: p.jerseyNumber?.toString() ?? "");
    _country = TextEditingController(text: p.country);

    // Normalize gender from backend (lowercase) to UI (capitalized)
    switch (p.gender?.toLowerCase()) {
      case 'male':
        _selectedGender = 'Male';
        break;
      case 'female':
        _selectedGender = 'Female';
        break;
      case 'other':
        _selectedGender = 'Other';
        break;
      default:
        _selectedGender = null;
    }

    // Pre-select current position and club
    _selectedPositionId = p.position?.id;
    _selectedClubId = p.club?.id;

    // Load positions and clubs from API
    _fetchPositions();
    _fetchClubs();
  }

  Future<void> _fetchPositions() async {
    try {
      final api = Get.find<ApiService>();
      final List<Map<String, dynamic>> rawPositions =
          await api.getAllPositions();

      final positions =
          rawPositions.map((json) => Position.fromJson(json)).toList();

      setState(() {
        _positions = positions;
        _loadingPositions = false;
      });
    } catch (e) {
      setState(() => _loadingPositions = false);
      Get.snackbar("Error", "Failed to load positions");
    }
  }

  Future<void> _fetchClubs() async {
    try {
      final api = Get.find<ApiService>();
      final clubs = await api.getAllClubs();

      setState(() {
        _clubs = clubs;
        _loadingClubs = false;
      });
    } catch (e) {
      setState(() => _loadingClubs = false);
      Get.snackbar("Error", "Failed to load clubs");
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _email.dispose();
    _jersey.dispose();
    _country.dispose();
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

    Get.dialog(const Center(child: CircularProgressIndicator()));

    try {
      final formData = dio.FormData();

      formData.fields.addAll([
        MapEntry('name', _name.text.trim()),
        MapEntry('country', _country.text.trim()),
        if (_selectedGender != null)
          MapEntry('gender', _selectedGender!.toLowerCase()),
        if (_selectedPositionId != null)
          MapEntry('position', _selectedPositionId!),
        if (_selectedClubId != null)
          MapEntry('club', _selectedClubId!)
        else
          const MapEntry('club', ''), // send empty to remove from club
        if (_phone.text.trim().isNotEmpty)
          MapEntry('phone', _phone.text.trim())
        else
          const MapEntry('phone', ''),
        if (_email.text.trim().isNotEmpty)
          MapEntry('email', _email.text.trim())
        else
          const MapEntry('email', ''),
      ]);

      final ageParsed = int.tryParse(_age.text.trim());
      if (ageParsed != null) {
        formData.fields.add(MapEntry('age', ageParsed.toString()));
      }

      final jerseyParsed = int.tryParse(_jersey.text.trim());
      if (jerseyParsed != null) {
        formData.fields.add(MapEntry('jerseyNumber', jerseyParsed.toString()));
      }

      if (_photoFile != null) {
        formData.files.add(MapEntry(
          'photo',
          await dio.MultipartFile.fromFile(
            _photoFile!.path,
            filename: _photoFile!.name,
          ),
        ));
      }

      final Player updatedPlayer = await Get.find<ApiService>().updatePlayer(
        widget.player.id,
        formData,
      );

      Get.back();
      Navigator.pop(context, updatedPlayer);

      Get.snackbar(
        "Success",
        "Player updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "Error",
        "Failed to update player: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
                // Drag handle
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

                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? "Name is required" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: "Age"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _jersey,
                  decoration: const InputDecoration(labelText: "Jersey Number"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _country,
                  decoration:
                      const InputDecoration(labelText: "Country/Nationality"),
                ),
                const SizedBox(height: 12),

                // Gender
                DropdownButtonFormField<String?>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: "Gender"),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(value: "Other", child: Text("Other")),
                  ],
                  onChanged: (v) => setState(() => _selectedGender = v),
                ),
                const SizedBox(height: 12),

                // Position dropdown
                _loadingPositions
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<String?>(
                        value: _selectedPositionId,
                        decoration:
                            const InputDecoration(labelText: "Position"),
                        hint: const Text("Select a position"),
                        items: _positions.map((pos) {
                          return DropdownMenuItem(
                            value: pos.id,
                            child: Text(pos.name),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedPositionId = v),
                      ),
                const SizedBox(height: 12),

                // Club dropdown
                _loadingClubs
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : DropdownButtonFormField<String?>(
                        value: _selectedClubId,
                        decoration: const InputDecoration(labelText: "Club"),
                        hint: const Text("Select a club (or none)"),
                        items: [
                          const DropdownMenuItem(
                              value: null, child: Text("Free Agent")),
                          ..._clubs.map((club) {
                            return DropdownMenuItem(
                              value: club.id,
                              child: Text(club.name),
                            );
                          }).toList(),
                        ],
                        onChanged: (v) => setState(() => _selectedClubId = v),
                      ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Photo preview
                if (_photoFile != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _photoFile!.path,
                        height: 140,
                        width: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),

                Center(
                  child: TextButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Change Photo"),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:image_picker/image_picker.dart';

// class EditPlayerModal extends StatefulWidget {
//   final Player player;

//   const EditPlayerModal({super.key, required this.player});

//   @override
//   State<EditPlayerModal> createState() => _EditPlayerModalState();
// }

// class _EditPlayerModalState extends State<EditPlayerModal> {
//   final _formKey = GlobalKey<FormState>();
//   final picker = ImagePicker();

//   late TextEditingController _name;
//   late TextEditingController _age;
//   late TextEditingController _phone;
//   late TextEditingController _email;
//   late TextEditingController _jersey;
//   late TextEditingController _country;
//   late TextEditingController _positionController;

//   String?
//       _gender; // Will be null, "Male", or "Female" — exactly matching dropdown
//   XFile? _photoFile;

//   @override
//   void initState() {
//     super.initState();
//     final p = widget.player;

//     _name = TextEditingController(text: p.name);
//     _age = TextEditingController(text: p.age?.toString() ?? "");
//     _phone = TextEditingController(text: p.phone ?? "");
//     _email = TextEditingController(text: p.email ?? "");
//     _jersey = TextEditingController(text: p.jerseyNumber?.toString() ?? "");
//     _country = TextEditingController(text: p.country);
//     _positionController = TextEditingController(text: p.position?.name ?? "");

//     // Normalize gender to match dropdown options exactly
//     if (p.gender != null) {
//       final lower = p.gender!.toLowerCase();
//       if (lower == "male") {
//         _gender = "Male";
//       } else if (lower == "female") {
//         _gender = "Female";
//       } else {
//         _gender = "Other"; // or keep as-is if you have other values
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _age.dispose();
//     _phone.dispose();
//     _email.dispose();
//     _jersey.dispose();
//     _country.dispose();
//     _positionController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickPhoto() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _photoFile = picked);
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;

//     Get.dialog(const Center(child: CircularProgressIndicator()));

//     try {
//       final formData = dio.FormData();

//       formData.fields.addAll([
//         MapEntry('name', _name.text.trim()),
//         MapEntry('country', _country.text.trim()),
//         if (_gender != null) MapEntry('gender', _gender!),
//         if (_positionController.text.trim().isNotEmpty)
//           MapEntry('position', _positionController.text.trim()),
//         if (_phone.text.trim().isNotEmpty)
//           MapEntry('phone', _phone.text.trim())
//         else
//           const MapEntry('phone', ''),
//         if (_email.text.trim().isNotEmpty)
//           MapEntry('email', _email.text.trim())
//         else
//           const MapEntry('email', ''),
//       ]);

//       final ageParsed = int.tryParse(_age.text.trim());
//       if (ageParsed != null) {
//         formData.fields.add(MapEntry('age', ageParsed.toString()));
//       }

//       final jerseyParsed = int.tryParse(_jersey.text.trim());
//       if (jerseyParsed != null) {
//         formData.fields.add(MapEntry('jerseyNumber', jerseyParsed.toString()));
//       }

//       if (_photoFile != null) {
//         formData.files.add(MapEntry(
//           'photo',
//           await dio.MultipartFile.fromFile(
//             _photoFile!.path,
//             filename: _photoFile!.name,
//           ),
//         ));
//       }

//       final Player updatedPlayer = await Get.find<ApiService>().updatePlayer(
//         widget.player.id,
//         formData,
//       );

//       Get.back();
//       Navigator.pop(context, updatedPlayer);

//       Get.snackbar(
//         "Success",
//         "Player updated successfully",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.back();
//       Get.snackbar(
//         "Error",
//         "Failed to update player: $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       padding: EdgeInsets.only(bottom: bottomPadding),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 50,
//                     height: 5,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[400],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 const Text(
//                   "Edit Player",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 TextFormField(
//                   controller: _name,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (v) =>
//                       v?.trim().isEmpty ?? true ? "Name is required" : null,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _age,
//                   decoration: const InputDecoration(labelText: "Age"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _jersey,
//                   decoration: const InputDecoration(labelText: "Jersey Number"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _country,
//                   decoration:
//                       const InputDecoration(labelText: "Country/Nationality"),
//                 ),
//                 const SizedBox(height: 12),

//                 // Gender dropdown - values exactly match "Male"/"Female"/null
//                 DropdownButtonFormField<String?>(
//                   value: _gender,
//                   decoration: const InputDecoration(labelText: "Gender"),
//                   items: const [
//                     DropdownMenuItem(value: null, child: Text("Not specified")),
//                     DropdownMenuItem(value: "Male", child: Text("Male")),
//                     DropdownMenuItem(value: "Female", child: Text("Female")),
//                   ],
//                   onChanged: (v) => setState(() => _gender = v),
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _positionController,
//                   decoration: const InputDecoration(
//                       labelText: "Position (e.g. Forward, Goalkeeper)"),
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _phone,
//                   decoration: const InputDecoration(labelText: "Phone"),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 12),

//                 TextFormField(
//                   controller: _email,
//                   decoration: const InputDecoration(labelText: "Email"),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20),

//                 if (_photoFile != null)
//                   Center(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         _photoFile!.path,
//                         height: 140,
//                         width: 140,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 12),

//                 Center(
//                   child: TextButton.icon(
//                     onPressed: _pickPhoto,
//                     icon: const Icon(Icons.photo_camera),
//                     label: const Text("Change Photo"),
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       "Save Changes",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio; // Alias to avoid conflict with GetX
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:image_picker/image_picker.dart';

// class EditPlayerModal extends StatefulWidget {
//   final Player player;

//   const EditPlayerModal({super.key, required this.player});

//   @override
//   State<EditPlayerModal> createState() => _EditPlayerModalState();
// }

// class _EditPlayerModalState extends State<EditPlayerModal> {
//   final _formKey = GlobalKey<FormState>();
//   final picker = ImagePicker();

//   late TextEditingController _name;
//   late TextEditingController _age;
//   late TextEditingController _phone;
//   late TextEditingController _email;
//   late TextEditingController _jersey;
//   late TextEditingController _country;
//   late TextEditingController _positionController;

//   String? _gender;
//   XFile? _photoFile;

//   @override
//   void initState() {
//     super.initState();
//     final p = widget.player;

//     _name = TextEditingController(text: p.name);
//     _age = TextEditingController(text: p.age?.toString() ?? "");
//     _phone = TextEditingController(text: p.phone ?? "");
//     _email = TextEditingController(text: p.email ?? "");
//     _jersey = TextEditingController(text: p.jerseyNumber?.toString() ?? "");
//     _country = TextEditingController(text: p.country);
//     _positionController = TextEditingController(text: p.position?.name ?? "");

//     _gender = p.gender;
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _age.dispose();
//     _phone.dispose();
//     _email.dispose();
//     _jersey.dispose();
//     _country.dispose();
//     _positionController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickPhoto() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _photoFile = picked);
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;

//     Get.dialog(const Center(child: CircularProgressIndicator()));

//     try {
//       final formData = dio.FormData();

//       // Text fields
//       formData.fields.addAll([
//         MapEntry('name', _name.text.trim()),
//         MapEntry('country', _country.text.trim()),
//         if (_gender != null) MapEntry('gender', _gender!),
//         if (_positionController.text.trim().isNotEmpty)
//           MapEntry('position', _positionController.text.trim()),
//         if (_phone.text.trim().isNotEmpty)
//           MapEntry('phone', _phone.text.trim())
//         else
//           const MapEntry('phone', ''),
//         if (_email.text.trim().isNotEmpty)
//           MapEntry('email', _email.text.trim())
//         else
//           const MapEntry('email', ''),
//       ]);

//       // Numeric fields
//       final ageParsed = int.tryParse(_age.text.trim());
//       if (ageParsed != null) {
//         formData.fields.add(MapEntry('age', ageParsed.toString()));
//       }

//       final jerseyParsed = int.tryParse(_jersey.text.trim());
//       if (jerseyParsed != null) {
//         formData.fields.add(MapEntry('jerseyNumber', jerseyParsed.toString()));
//       }

//       // Photo upload
//       if (_photoFile != null) {
//         formData.files.add(MapEntry(
//           'photo',
//           await dio.MultipartFile.fromFile(
//             _photoFile!.path,
//             filename: _photoFile!.name,
//           ),
//         ));
//       }

//       // Call API
//       final Player updatedPlayer = await Get.find<ApiService>().updatePlayer(
//         widget.player.id,
//         formData,
//       );

//       Get.back(); // close loading
//       Navigator.pop(context, updatedPlayer);

//       Get.snackbar(
//         "Success",
//         "Player updated successfully",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.back();
//       Get.snackbar(
//         "Error",
//         "Failed to update player: $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       padding: EdgeInsets.only(bottom: bottomPadding),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Drag handle
//                 Center(
//                   child: Container(
//                     width: 50,
//                     height: 5,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[400],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),

//                 const Text(
//                   "Edit Player",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Full Name
//                 TextFormField(
//                   controller: _name,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (v) =>
//                       v?.trim().isEmpty ?? true ? "Name is required" : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Age
//                 TextFormField(
//                   controller: _age,
//                   decoration: const InputDecoration(labelText: "Age"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),

//                 // Jersey Number
//                 TextFormField(
//                   controller: _jersey,
//                   decoration: const InputDecoration(labelText: "Jersey Number"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),

//                 // Country
//                 TextFormField(
//                   controller: _country,
//                   decoration:
//                       const InputDecoration(labelText: "Country/Nationality"),
//                 ),
//                 const SizedBox(height: 12),

//                 // Gender
//                 DropdownButtonFormField<String?>(
//                   value: _gender,
//                   decoration: const InputDecoration(labelText: "Gender"),
//                   items: const [
//                     DropdownMenuItem(value: null, child: Text("Not specified")),
//                     DropdownMenuItem(value: "Male", child: Text("Male")),
//                     DropdownMenuItem(value: "Female", child: Text("Female")),
//                   ],
//                   onChanged: (v) => setState(() => _gender = v),
//                 ),
//                 const SizedBox(height: 12),

//                 // Position
//                 TextFormField(
//                   controller: _positionController,
//                   decoration: const InputDecoration(
//                       labelText: "Position (e.g. Forward, Goalkeeper)"),
//                 ),
//                 const SizedBox(height: 12),

//                 // Phone
//                 TextFormField(
//                   controller: _phone,
//                   decoration: const InputDecoration(labelText: "Phone"),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 12),

//                 // Email
//                 TextFormField(
//                   controller: _email,
//                   decoration: const InputDecoration(labelText: "Email"),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20),

//                 // Photo preview
//                 if (_photoFile != null)
//                   Center(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         _photoFile!.path,
//                         height: 140,
//                         width: 140,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 12),

//                 // Change photo button
//                 Center(
//                   child: TextButton.icon(
//                     onPressed: _pickPhoto,
//                     icon: const Icon(Icons.photo_camera),
//                     label: const Text("Change Photo"),
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // Save button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       "Save Changes",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart' as dio; // Alias only for dio classes
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:image_picker/image_picker.dart';

// class EditPlayerModal extends StatefulWidget {
//   final Player player;

//   const EditPlayerModal({super.key, required this.player});

//   @override
//   State<EditPlayerModal> createState() => _EditPlayerModalState();
// }

// class _EditPlayerModalState extends State<EditPlayerModal> {
//   final _formKey = GlobalKey<FormState>();
//   final picker = ImagePicker();

//   late TextEditingController _name;
//   late TextEditingController _age;
//   late TextEditingController _phone;
//   late TextEditingController _email;
//   late TextEditingController _jersey;
//   late TextEditingController _country;

//   String? _gender;
//   String? _position;

//   XFile? _photoFile;

//   @override
//   void initState() {
//     super.initState();
//     final p = widget.player;

//     _name = TextEditingController(text: p.name);
//     _age = TextEditingController(text: p.age?.toString() ?? "");
//     _phone = TextEditingController(text: p.phone ?? "");
//     _email = TextEditingController(text: p.email ?? "");
//     _jersey = TextEditingController(text: p.jerseyNumber?.toString() ?? "");
//     _country = TextEditingController(text: p.country);

//     _gender = p.gender;
//     _position = p.position?.name;
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _age.dispose();
//     _phone.dispose();
//     _email.dispose();
//     _jersey.dispose();
//     _country.dispose();
//     super.dispose();
//   }

//   Future<void> _pickPhoto() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() => _photoFile = picked);
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;

//     Get.dialog(const Center(child: CircularProgressIndicator()));

//     try {
//       // Use Dio's FormData
//       final formData = dio.FormData();

//       // Text fields - use plain MapEntry (from dart:core)
//       formData.fields.addAll([
//         MapEntry('name', _name.text.trim()),
//         MapEntry('country', _country.text.trim()),
//         if (_gender != null) MapEntry('gender', _gender!),
//         if (_position != null && _position!.isNotEmpty)
//           MapEntry('position', _position!),
//         if (_phone.text.trim().isNotEmpty)
//           MapEntry('phone', _phone.text.trim())
//         else
//           const MapEntry('phone', ''),
//         if (_email.text.trim().isNotEmpty)
//           MapEntry('email', _email.text.trim())
//         else
//           const MapEntry('email', ''),
//       ]);

//       // Numeric fields
//       final ageParsed = int.tryParse(_age.text.trim());
//       if (ageParsed != null) {
//         formData.fields.add(MapEntry('age', ageParsed.toString()));
//       }

//       final jerseyParsed = int.tryParse(_jersey.text.trim());
//       if (jerseyParsed != null) {
//         formData.fields.add(MapEntry('jerseyNumber', jerseyParsed.toString()));
//       }

//       // Photo upload
//       if (_photoFile != null) {
//         formData.files.add(MapEntry(
//           'photo',
//           await dio.MultipartFile.fromFile(
//             _photoFile!.path,
//             filename: _photoFile!.name,
//           ),
//         ));
//       }

//       // Call API
//       final Player updatedPlayer = await Get.find<ApiService>().updatePlayer(
//         widget.player.id,
//         formData,
//       );

//       Get.back(); // close loading
//       Navigator.pop(context, updatedPlayer);

//       Get.snackbar(
//         "Success",
//         "Player updated successfully",
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       Get.back();
//       Get.snackbar(
//         "Error",
//         "Failed to update player: $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       padding: EdgeInsets.only(bottom: bottomPadding),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 50,
//                     height: 5,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[400],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const Text(
//                   "Edit Player",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextFormField(
//                   controller: _name,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (v) =>
//                       v?.trim().isEmpty ?? true ? "Name is required" : null,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _age,
//                   decoration: const InputDecoration(labelText: "Age"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _jersey,
//                   decoration: const InputDecoration(labelText: "Jersey Number"),
//                   keyboardType: TextInputType.number,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _country,
//                   decoration:
//                       const InputDecoration(labelText: "Country/Nationality"),
//                 ),
//                 const SizedBox(height: 12),
//                 DropdownButtonFormField<String?>(
//                   value: _gender,
//                   decoration: const InputDecoration(labelText: "Gender"),
//                   items: const [
//                     DropdownMenuItem(value: null, child: Text("Not specified")),
//                     DropdownMenuItem(value: "Male", child: Text("Male")),
//                     DropdownMenuItem(value: "Female", child: Text("Female")),
//                   ],
//                   onChanged: (v) => setState(() => _gender = v),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   initialValue: _position,
//                   decoration: const InputDecoration(
//                       labelText: "Position (e.g. Forward, Goalkeeper)"),
//                   onChanged: (v) => _position = v.isEmpty ? null : v.trim(),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _phone,
//                   decoration: const InputDecoration(labelText: "Phone"),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _email,
//                   decoration: const InputDecoration(labelText: "Email"),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 20),
//                 if (_photoFile != null)
//                   Center(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: Image.network(
//                         _photoFile!.path,
//                         height: 140,
//                         width: 140,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 Center(
//                   child: TextButton.icon(
//                     onPressed: _pickPhoto,
//                     icon: const Icon(Icons.photo_camera),
//                     label: const Text("Change Photo"),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text(
//                       "Save Changes",
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:image_picker/image_picker.dart';

// class EditPlayerModal extends StatefulWidget {
//   final Player player;

//   const EditPlayerModal({super.key, required this.player});

//   @override
//   State<EditPlayerModal> createState() => _EditPlayerModalState();
// }

// class _EditPlayerModalState extends State<EditPlayerModal> {
//   final _formKey = GlobalKey<FormState>();
//   final picker = ImagePicker();

//   late TextEditingController _name;
//   late TextEditingController _age;
//   late TextEditingController _phone;
//   late TextEditingController _email;
//   late TextEditingController _jersey;

//   String? _gender;
//   String? _position;
//   String? _country;

//   XFile? _photoFile;

//   @override
//   void initState() {
//     super.initState();
//     final p = widget.player;

//     _name = TextEditingController(text: p.name);
//     _age = TextEditingController(text: p.age.toString());
//     _phone = TextEditingController(text: p.phone ?? "");
//     _email = TextEditingController(text: p.email ?? "");
//     _jersey = TextEditingController(
//         text: p.jerseyNumber != null ? p.jerseyNumber.toString() : "");

//     _gender = p.gender;
//     _position = p.position?.name;
//     _country = p.country;
//   }

//   @override
//   void dispose() {
//     _name.dispose();
//     _age.dispose();
//     _phone.dispose();
//     _email.dispose();
//     _jersey.dispose();
//     super.dispose();
//   }

//   Future<void> _pickPhoto() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);

//     if (picked != null) {
//       setState(() => _photoFile = picked);
//     }
//   }

//   Future<void> _saveChanges() async {
//     if (!_formKey.currentState!.validate()) return;

//     Get.snackbar("Updating", "Saving player changes...",
//         backgroundColor: Colors.deepPurple,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 1));

//     final updated = await Get.find<ApiService>().updatePlayer(
//       id: widget.player.id,
//       name: _name.text,
//       age: int.tryParse(_age.text),
//       phone: _phone.text.isEmpty ? null : _phone.text,
//       email: _email.text.isEmpty ? null : _email.text,
//       jerseyNumber: int.tryParse(_jersey.text),
//       gender: _gender,
//       country: _country,
//       position: _position,
//       photoFile: _photoFile,
//     );

//     Navigator.pop(context, updated); // return updated player
//     }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       padding: EdgeInsets.only(bottom: bottomPadding),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 50,
//                     height: 5,
//                     margin: const EdgeInsets.only(bottom: 20),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[400],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const Text(
//                   "Edit Player",
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Name
//                 TextFormField(
//                   controller: _name,
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (v) =>
//                       v!.trim().isEmpty ? "Name is required" : null,
//                 ),

//                 const SizedBox(height: 12),

//                 // Age
//                 TextFormField(
//                   controller: _age,
//                   decoration: const InputDecoration(labelText: "Age"),
//                   keyboardType: TextInputType.number,
//                 ),

//                 const SizedBox(height: 12),

//                 // Jersey Number
//                 TextFormField(
//                   controller: _jersey,
//                   decoration: const InputDecoration(labelText: "Jersey Number"),
//                   keyboardType: TextInputType.number,
//                 ),

//                 const SizedBox(height: 12),

//                 // Phone
//                 TextFormField(
//                   controller: _phone,
//                   decoration: const InputDecoration(labelText: "Phone"),
//                 ),

//                 const SizedBox(height: 12),

//                 // Email
//                 TextFormField(
//                   controller: _email,
//                   decoration: const InputDecoration(labelText: "Email"),
//                 ),

//                 const SizedBox(height: 12),

//                 // Photo
//                 TextButton.icon(
//                   onPressed: _pickPhoto,
//                   icon: const Icon(Icons.photo),
//                   label: const Text("Change Photo"),
//                 ),

//                 const SizedBox(height: 24),

//                 // Save Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _saveChanges,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                     child: const Text(
//                       "Save Changes",
//                       style: TextStyle(fontSize: 18),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
