import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/models/user_model.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/services/api_service.dart';

class UserForm extends StatefulWidget {
  final UserModel? user;
  final RxList<ClubModel>? clubs;

  const UserForm({super.key, this.user, this.clubs});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = Get.find<ApiService>();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;

  String? selectedClubId;
  String? selectedRole;

  bool loading = false;
  List<ClubModel> clubs = [];
  final List<String> roles = ["coach", "admin", "player"];
@override
  void initState() {
    super.initState();

    final user = widget.user; // ← This prevents the null check error

    usernameController = TextEditingController(text: user?.username ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    nameController = TextEditingController(
        text: user?.name ?? ""); // ← WAS user?.username → BUG!
    phoneController = TextEditingController(text: user?.phone ?? "");
    passwordController = TextEditingController();

    selectedClubId = user?.club;
    selectedRole = user?.role ?? "player";

    if (widget.clubs != null) {
      clubs = widget.clubs!;
    } else {
      loadClubs();
    }
  }
  // @override
  // void initState() {
  //   super.initState();

  //   usernameController =
  //       TextEditingController(text: widget.user?.username ?? "");
  //   emailController = TextEditingController(text: widget.user?.email ?? "");
  //   nameController = TextEditingController(text: widget.user?.name ?? "");
  //   phoneController = TextEditingController(text: widget.user?.phone ?? "");
  //   passwordController = TextEditingController();

  //   selectedClubId = widget.user?.club;
  //   selectedRole = widget.user?.role ?? "player";

  //   if (widget.clubs != null) {
  //     clubs = widget.clubs!;
  //   } else {
  //     loadClubs();
  //   }
  // }

  Future<void> loadClubs() async {
    try {
      final list = await api.getAllClubs();
      setState(() => clubs = list);
    } catch (e) {
      debugPrint("Failed to load clubs: $e");
    }
  }

  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      if (widget.user == null) {
        await api.registerUser({
          "username": usernameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text,
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "club": selectedClubId,
          "role": selectedRole,
        });
      } else {
        await api.updateUser(widget.user!.id!, {
          "username": usernameController.text.trim(),
          "email": emailController.text.trim(),
          "name": nameController.text.trim(),
          "phone": phoneController.text.trim(),
          "club": selectedClubId,
          "role": selectedRole,
        });
      }
      if (mounted) Get.back(result: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final hintColor = theme.textTheme.bodyMedium?.color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Title
              Text(
                widget.user == null ? "Add User" : "Edit User",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 20),

              // Form
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Username
                          TextFormField(
                            controller: usernameController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: "Username",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon:
                                  Icon(Icons.alternate_email, color: hintColor),
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
                            validator: (v) =>
                                v?.trim().isEmpty ?? true ? "Required" : null,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          TextFormField(
                            controller: emailController,
                            style: TextStyle(color: textColor),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon:
                                  Icon(Icons.email_outlined, color: hintColor),
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
                          ),
                          const SizedBox(height: 16),

                          // Full Name
                          TextFormField(
                            controller: nameController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon: Icon(Icons.person, color: hintColor),
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
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          TextFormField(
                            controller: phoneController,
                            style: TextStyle(color: textColor),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Phone",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon: Icon(Icons.phone, color: hintColor),
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
                          ),
                          const SizedBox(height: 16),

                          // Password (only for new user)
                          if (widget.user == null) ...[
                            TextFormField(
                              controller: passwordController,
                              style: TextStyle(color: textColor),
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: hintColor),
                                prefixIcon:
                                    Icon(Icons.lock_outline, color: hintColor),
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
                              validator: (v) => (v == null || v.length < 6)
                                  ? "Password must be ≥6 chars"
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Club Dropdown
                          DropdownButtonFormField<String>(
                            value: clubs.any((c) => c.id == selectedClubId)
                                ? selectedClubId
                                : null,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: "Club",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon:
                                  Icon(Icons.sports_soccer, color: hintColor),
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
                            items: clubs
                                .map((c) => DropdownMenuItem(
                                    value: c.id, child: Text(c.name)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => selectedClubId = v),
                          ),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          DropdownButtonFormField<String>(
                            value: roles.contains(selectedRole)
                                ? selectedRole
                                : null,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              labelText: "Role",
                              labelStyle: TextStyle(color: hintColor),
                              prefixIcon: Icon(Icons.badge, color: hintColor),
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
                            items: roles
                                .map((r) => DropdownMenuItem(
                                    value: r, child: Text(r.toUpperCase())))
                                .toList(),
                            onChanged: (v) => setState(() => selectedRole = v),
                          ),
                          const SizedBox(height: 32),

                          // Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    side: BorderSide(color: theme.dividerColor),
                                  ),
                                  child: Text("Cancel",
                                      style: TextStyle(color: textColor)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: loading ? null : saveUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2),
                                        )
                                      : Text(
                                          widget.user == null
                                              ? "Create User"
                                              : "Save Changes",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}











// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';

// class UserForm extends StatefulWidget {
//   final UserModel? user; // null = create new
//   final RxList<ClubModel>? clubs; // cached clubs from Users tab

//   const UserForm({super.key, this.user, this.clubs});

//   @override
//   State<UserForm> createState() => _UserFormState();
// }

// class _UserFormState extends State<UserForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();

//   late TextEditingController usernameController;
//   late TextEditingController emailController;
//   late TextEditingController nameController;
//   late TextEditingController phoneController;
//   late TextEditingController passwordController;

//   String? selectedClubId;
//   String? selectedRole;

//   bool loading = false;
//   List<ClubModel> clubs = [];
//   final List<String> roles = ["coach", "admin", "player"];

//   @override
//   void initState() {
//     super.initState();

//     usernameController =
//         TextEditingController(text: widget.user?.username ?? "");
//     emailController = TextEditingController(text: widget.user?.email ?? "");
//     nameController = TextEditingController(text: widget.user?.username ?? "");
//     phoneController = TextEditingController(text: widget.user?.phone ?? "");
//     passwordController = TextEditingController();

//     selectedClubId = widget.user?.club;
//     selectedRole = widget.user?.role ?? "player";

//     if (widget.clubs != null) {
//       clubs = widget.clubs!;
//     } else {
//       loadClubs();
//     }
//   }

//   Future<void> loadClubs() async {
//     try {
//       final list = await api.getAllClubs();
//       setState(() => clubs = list);
//     } catch (e) {
//       debugPrint("Failed to load clubs: $e");
//     }
//   }

//   Future<void> saveUser() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => loading = true);

//     try {
//       if (widget.user == null) {
//         // CREATE
//         await api.registerUser({
//           "username": usernameController.text,
//           "email": emailController.text,
//           "password": passwordController.text,
//           "name": nameController.text,
//           "phone": phoneController.text,
//           "club": selectedClubId,
//           "role": selectedRole,
//         });
//         if (mounted) Get.back(result: true);
//       } else {
//         // EDIT
//         await api.updateUser(widget.user!.id!, {
//           "username": usernameController.text,
//           "email": emailController.text,
//           "name": nameController.text,
//           "phone": phoneController.text,
//           "club": selectedClubId,
//           "role": selectedRole,
//         });
//         if (mounted) Get.back(result: true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed: $e")),
//         );
//       }
//     }

//     setState(() => loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: DraggableScrollableSheet(
//         initialChildSize: 0.85,
//         minChildSize: 0.5,
//         maxChildSize: 0.95,
//         builder: (_, controller) => Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: ListView(
//             controller: controller,
//             children: [
//               // Header with dismiss X
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const SizedBox(width: 40),
//                   Text(
//                     widget.user == null ? "Add User" : "Edit User",
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close_rounded),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Username
//                     TextFormField(
//                       controller: usernameController,
//                       decoration: const InputDecoration(
//                         labelText: "Username",
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (v) => v!.isEmpty ? "Required" : null,
//                     ),
//                     const SizedBox(height: 12),
//                     // Email
//                     TextFormField(
//                       controller: emailController,
//                       decoration: const InputDecoration(
//                         labelText: "Email",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Full Name
//                     TextFormField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: "Full Name",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Phone
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: const InputDecoration(
//                         labelText: "Phone",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     // Password only for new user
//                     if (widget.user == null) ...[
//                       TextFormField(
//                         controller: passwordController,
//                         decoration: const InputDecoration(
//                           labelText: "Password",
//                           border: OutlineInputBorder(),
//                         ),
//                         obscureText: true,
//                         validator: (v) => (v == null || v.length < 6)
//                             ? "Password must be ≥6 chars"
//                             : null,
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                     // Clubs Dropdown
//                     DropdownButtonFormField<String>(
//                       value: clubs.any((c) => c.id == selectedClubId)
//                           ? selectedClubId
//                           : null,
//                       decoration: const InputDecoration(
//                         labelText: "Club",
//                         border: OutlineInputBorder(),
//                       ),
//                       items: clubs
//                           .map((c) => DropdownMenuItem(
//                                 value: c.id,
//                                 child: Text(c.name),
//                               ))
//                           .toList(),
//                       onChanged: (v) => setState(() => selectedClubId = v),
//                     ),
//                     const SizedBox(height: 12),
//                     // Role Dropdown
//                     DropdownButtonFormField<String>(
//                       value: roles.contains(selectedRole) ? selectedRole : null,
//                       decoration: const InputDecoration(
//                         labelText: "Role",
//                         border: OutlineInputBorder(),
//                       ),
//                       items: roles
//                           .map((r) => DropdownMenuItem(
//                                 value: r,
//                                 child: Text(r.toUpperCase()),
//                               ))
//                           .toList(),
//                       onChanged: (v) => setState(() => selectedRole = v),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Get.back(),
//                             child: const Text("Cancel"),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: saveUser,
//                             child: Text(widget.user == null
//                                 ? "Create User"
//                                 : "Save Changes"),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (loading)
//                       const Padding(
//                         padding: EdgeInsets.only(top: 12),
//                         child: CircularProgressIndicator(),
//                       ),
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

