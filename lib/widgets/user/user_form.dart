import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/models/user_model.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/services/api_service.dart';

class UserForm extends StatefulWidget {
  final UserModel? user; // null = create new
  final RxList<ClubModel>? clubs; // cached clubs from Users tab

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

    usernameController =
        TextEditingController(text: widget.user?.username ?? "");
    emailController = TextEditingController(text: widget.user?.email ?? "");
    nameController = TextEditingController(text: widget.user?.username ?? "");
    phoneController = TextEditingController(text: widget.user?.phone ?? "");
    passwordController = TextEditingController();

    selectedClubId = widget.user?.club;
    selectedRole = widget.user?.role ?? "player";

    if (widget.clubs != null) {
      clubs = widget.clubs!;
    } else {
      loadClubs();
    }
  }

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
        // CREATE
        await api.registerUser({
          "username": usernameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "name": nameController.text,
          "phone": phoneController.text,
          "club": selectedClubId,
          "role": selectedRole,
        });
        if (mounted) Get.back(result: true);
      } else {
        // EDIT
        await api.updateUser(widget.user!.id!, {
          "username": usernameController.text,
          "email": emailController.text,
          "name": nameController.text,
          "phone": phoneController.text,
          "club": selectedClubId,
          "role": selectedRole,
        });
        if (mounted) Get.back(result: true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: $e")),
        );
      }
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            children: [
              // Header with dismiss X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    widget.user == null ? "Add User" : "Edit User",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 12),
                    // Email
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Phone
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: "Phone",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Password only for new user
                    if (widget.user == null) ...[
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? "Password must be ≥6 chars"
                            : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Clubs Dropdown
                    DropdownButtonFormField<String>(
                      value: clubs.any((c) => c.id == selectedClubId)
                          ? selectedClubId
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Club",
                        border: OutlineInputBorder(),
                      ),
                      items: clubs
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedClubId = v),
                    ),
                    const SizedBox(height: 12),
                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: roles.contains(selectedRole) ? selectedRole : null,
                      decoration: const InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(),
                      ),
                      items: roles
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedRole = v),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: saveUser,
                            child: Text(widget.user == null
                                ? "Create User"
                                : "Save Changes"),
                          ),
                        ),
                      ],
                    ),
                    if (loading)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: CircularProgressIndicator(),
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
}

