import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/forms/position_form.dart';

class Positions extends StatefulWidget {
  const Positions({super.key});

  @override
  State<Positions> createState() => _PositionsState();
}

class _PositionsState extends State<Positions> {
  final ApiService api = Get.find<ApiService>();
  final AuthService auth = Get.find<AuthService>();

  List<dynamic> positions = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPositions();
  }

  Future<void> loadPositions() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await api.getAllPositions();
      setState(() => positions = data);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _addPosition() async {
    final result = await Get.bottomSheet(
      const PositionForm(mode: PositionFormMode.create),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (result == true) loadPositions();
  }

  Future<void> _editPosition(Map<String, dynamic> position) async {
    final result = await Get.bottomSheet(
      PositionForm(mode: PositionFormMode.edit, position: position),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );

    if (result == true) loadPositions();
  }

  Future<void> _deletePosition(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Delete Position"),
        content: const Text("This action cannot be undone. Continue?"),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await api.deletePosition(id);
      loadPositions();
      Get.snackbar("Success", "Position deleted",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Positions"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'add') {
                  _addPosition();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.deepPurple),
                      SizedBox(width: 12),
                      Text("Add Position"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text("Error: $error"),
                      TextButton(
                        onPressed: loadPositions,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : positions.isEmpty
                  ? const Center(child: Text("No positions found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: positions.length,
                      itemBuilder: (context, index) {
                        final pos = positions[index];
                        final String id = pos['_id'] ?? pos['id'] ?? '';
                        final String name = pos['name'] ?? 'Unknown';
                        final String? shortName = pos['shortName'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                shortName != null ? Text(shortName) : null,
                            trailing: isAdmin
                                ? PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _editPosition(pos);
                                      } else if (value == 'delete') {
                                        _deletePosition(id);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit,
                                                color: Colors.deepPurple),
                                            SizedBox(width: 12),
                                            Text("Edit"),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                color: Colors.red),
                                            SizedBox(width: 12),
                                            Text("Delete",
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/forms/position_form.dart';
// import 'package:precords_android/services/auth_service.dart';

// class Positions extends StatefulWidget {
//   const Positions({super.key});

//   @override
//   State<Positions> createState() => _PositionsState();
// }

// class _PositionsState extends State<Positions> {
//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   List<dynamic> positions = [];
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     loadPositions();
//   }

//   Future<void> loadPositions() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final data = await api.getAllPositions();
//       setState(() => positions = data);
//     } catch (e) {
//       setState(() => error = e.toString());
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _addPosition() async {
//     final result = await Get.bottomSheet(
//       _PositionForm(),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );

//     if (result == true) loadPositions();
//   }

//   Future<void> _editPosition(Map<String, dynamic> position) async {
//     final result = await Get.bottomSheet(
//       _PositionForm(position: position),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );

//     if (result == true) loadPositions();
//   }

//   Future<void> _deletePosition(String id) async {
//     final confirm = await Get.dialog<bool>(
//       AlertDialog(
//         title: const Text("Delete Position"),
//         content: const Text("This action cannot be undone. Continue?"),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(result: false),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             child: const Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       await api.deletePosition(id);
//       loadPositions();
//       Get.snackbar("Success", "Position deleted",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       Get.snackbar("Error", e.toString(),
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Positions"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         actions: [
//           if (isAdmin)
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert),
//               onSelected: (value) {
//                 if (value == 'add') {
//                   _addPosition();
//                 }
//               },
//               itemBuilder: (_) => [
//                 const PopupMenuItem(
//                   value: 'add',
//                   child: Row(
//                     children: [
//                       Icon(Icons.add, color: Colors.deepPurple),
//                       SizedBox(width: 12),
//                       Text("Add Position"),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error, size: 60, color: Colors.red),
//                       const SizedBox(height: 16),
//                       Text("Error: $error"),
//                       TextButton(
//                         onPressed: loadPositions,
//                         child: const Text("Retry"),
//                       ),
//                     ],
//                   ),
//                 )
//               : positions.isEmpty
//                   ? const Center(child: Text("No positions found"))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: positions.length,
//                       itemBuilder: (context, index) {
//                         final pos = positions[index];
//                         final String id = pos['_id'] ?? pos['id'] ?? '';
//                         final String name = pos['name'] ?? 'Unknown';
//                         final String? shortName = pos['shortName'];

//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             title: Text(name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold)),
//                             subtitle:
//                                 shortName != null ? Text(shortName) : null,
//                             trailing: isAdmin
//                                 ? PopupMenuButton<String>(
//                                     onSelected: (value) {
//                                       if (value == 'edit') {
//                                         _editPosition(pos);
//                                       } else if (value == 'delete') {
//                                         _deletePosition(id);
//                                       }
//                                     },
//                                     itemBuilder: (_) => [
//                                       const PopupMenuItem(
//                                         value: 'edit',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.edit,
//                                                 color: Colors.deepPurple),
//                                             SizedBox(width: 12),
//                                             Text("Edit"),
//                                           ],
//                                         ),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'delete',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.delete,
//                                                 color: Colors.red),
//                                             SizedBox(width: 12),
//                                             Text("Delete",
//                                                 style: TextStyle(
//                                                     color: Colors.red)),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : const Icon(Icons.chevron_right),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

// // Reusable form for Add/Edit Position (unchanged)
// class _PositionForm extends StatefulWidget {
//   final Map<String, dynamic>? position;

//   const _PositionForm({this.position});

//   @override
//   State<_PositionForm> createState() => _PositionFormState();
// }

// class _PositionFormState extends State<_PositionForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _shortNameCtrl;

//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.position?['name'] ?? "");
//     _shortNameCtrl =
//         TextEditingController(text: widget.position?['shortName'] ?? "");
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _shortNameCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _loading = true);

//     try {
//       if (widget.position == null) {
//         await api.createPosition(
//           name: _nameCtrl.text.trim(),
//           shortName: _shortNameCtrl.text.trim().isEmpty
//               ? null
//               : _shortNameCtrl.text.trim(),
//         );
//       } else {
//         await api.updatePosition(
//           widget.position!['_id'] ?? widget.position!['id'],
//           name: _nameCtrl.text.trim(),
//           shortName: _shortNameCtrl.text.trim().isEmpty
//               ? null
//               : _shortNameCtrl.text.trim(),
//         );
//       }

//       Get.back(result: true);
//     } catch (e) {
//       Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color;
//     final hintColor = theme.textTheme.bodyMedium?.color;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.6,
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Text(
//                 widget.position == null ? "Add Position" : "Edit Position",
//                 style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: textColor),
//               ),
//               const SizedBox(height: 30),
//               TextFormField(
//                 controller: _nameCtrl,
//                 style: TextStyle(color: textColor),
//                 decoration: InputDecoration(
//                   labelText: "Position Name *",
//                   labelStyle: TextStyle(color: hintColor),
//                   filled: true,
//                   fillColor:
//                       isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                 ),
//                 validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _shortNameCtrl,
//                 style: TextStyle(color: textColor),
//                 decoration: InputDecoration(
//                   labelText: "Short Name (e.g. GK, ST)",
//                   labelStyle: TextStyle(color: hintColor),
//                   filled: true,
//                   fillColor:
//                       isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       child: Text("Cancel", style: TextStyle(color: textColor)),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _loading ? null : _save,
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple),
//                       child: _loading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text("Save",
//                               style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
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
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';

// class Positions extends StatefulWidget {
//   const Positions({super.key});

//   @override
//   State<Positions> createState() => _PositionsState();
// }

// class _PositionsState extends State<Positions> {
//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   List<dynamic> positions = [];
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     loadPositions();
//   }

//   Future<void> loadPositions() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });

//     try {
//       final data = await api.getAllPositions();
//       setState(() => positions = data);
//     } catch (e) {
//       setState(() => error = e.toString());
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _addPosition() async {
//     final result = await Get.bottomSheet(
//       _PositionForm(),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );

//     if (result == true) loadPositions();
//   }

//   Future<void> _editPosition(Map<String, dynamic> position) async {
//     final result = await Get.bottomSheet(
//       _PositionForm(position: position),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );

//     if (result == true) loadPositions();
//   }

//   Future<void> _deletePosition(String id) async {
//     final confirm = await Get.dialog<bool>(
//       AlertDialog(
//         title: const Text("Delete Position"),
//         content: const Text("This action cannot be undone. Continue?"),
//         actions: [
//           TextButton(
//               onPressed: () => Get.back(result: false),
//               child: const Text("Cancel")),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             child: const Text("Delete", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       await api.deletePosition(id);
//       loadPositions();
//       Get.snackbar("Success", "Position deleted",
//           backgroundColor: Colors.green, colorText: Colors.white);
//     } catch (e) {
//       Get.snackbar("Error", e.toString(),
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Positions"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
        
//       ),
//       floatingActionButton: isAdmin
//           ? FloatingActionButton(
//               onPressed: _addPosition,
//               backgroundColor: Colors.deepPurple,
//               child: const Icon(Icons.add),
//             )
//           : null,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error, size: 60, color: Colors.red),
//                       const SizedBox(height: 16),
//                       Text("Error: $error"),
//                       TextButton(
//                         onPressed: loadPositions,
//                         child: const Text("Retry"),
//                       ),
//                     ],
//                   ),
//                 )
//               : positions.isEmpty
//                   ? const Center(child: Text("No positions found"))
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: positions.length,
//                       itemBuilder: (context, index) {
//                         final pos = positions[index];
//                         final String id = pos['_id'] ?? pos['id'] ?? '';
//                         final String name = pos['name'] ?? 'Unknown';
//                         final String? shortName = pos['shortName'];

//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: ListTile(
//                             title: Text(name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold)),
//                             subtitle:
//                                 shortName != null ? Text(shortName) : null,
//                             trailing: isAdmin
//                                 ? PopupMenuButton<String>(
//                                     onSelected: (value) {
//                                       if (value == 'edit') {
//                                         _editPosition(pos);
//                                       } else if (value == 'delete') {
//                                         _deletePosition(id);
//                                       }
//                                     },
//                                     itemBuilder: (_) => [
//                                       const PopupMenuItem(
//                                         value: 'edit',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.edit,
//                                                 color: Colors.deepPurple),
//                                             SizedBox(width: 12),
//                                             Text("Edit"),
//                                           ],
//                                         ),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'delete',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.delete,
//                                                 color: Colors.red),
//                                             SizedBox(width: 12),
//                                             Text("Delete",
//                                                 style: TextStyle(
//                                                     color: Colors.red)),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                                 : const Icon(Icons.chevron_right),
//                           ),
//                         );
//                       },
//                     ),
//     );
//   }
// }

// // Reusable form for Add/Edit Position
// class _PositionForm extends StatefulWidget {
//   final Map<String, dynamic>? position;

//   const _PositionForm({this.position});

//   @override
//   State<_PositionForm> createState() => _PositionFormState();
// }

// class _PositionFormState extends State<_PositionForm> {
//   final _formKey = GlobalKey<FormState>();
//   final ApiService api = Get.find<ApiService>();

//   late TextEditingController _nameCtrl;
//   late TextEditingController _shortNameCtrl;

//   bool _loading = false;

//   @override
//   void initState() {
//     super.initState();
//     _nameCtrl = TextEditingController(text: widget.position?['name'] ?? "");
//     _shortNameCtrl =
//         TextEditingController(text: widget.position?['shortName'] ?? "");
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _shortNameCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _loading = true);

//     try {
//       if (widget.position == null) {
//         // Add new
//         await api.createPosition(
//           name: _nameCtrl.text.trim(),
//           shortName: _shortNameCtrl.text.trim().isEmpty
//               ? null
//               : _shortNameCtrl.text.trim(),
//         );
//       } else {
//         // Update
//         await api.updatePosition(
//           widget.position!['_id'] ?? widget.position!['id'],
//           name: _nameCtrl.text.trim(),
//           shortName: _shortNameCtrl.text.trim().isEmpty
//               ? null
//               : _shortNameCtrl.text.trim(),
//         );
//       }

//       Get.back(result: true);
//     } catch (e) {
//       Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color;
//     final hintColor = theme.textTheme.bodyMedium?.color;

//     return Container(
//       height: MediaQuery.of(context).size.height * 0.6,
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Text(
//                 widget.position == null ? "Add Position" : "Edit Position",
//                 style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: textColor),
//               ),
//               const SizedBox(height: 30),
//               TextFormField(
//                 controller: _nameCtrl,
//                 style: TextStyle(color: textColor),
//                 decoration: InputDecoration(
//                   labelText: "Position Name *",
//                   labelStyle: TextStyle(color: hintColor),
//                   filled: true,
//                   fillColor:
//                       isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                 ),
//                 validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _shortNameCtrl,
//                 style: TextStyle(color: textColor),
//                 decoration: InputDecoration(
//                   labelText: "Short Name (e.g. GK, ST)",
//                   labelStyle: TextStyle(color: hintColor),
//                   filled: true,
//                   fillColor:
//                       isDark ? Colors.grey.shade800 : Colors.grey.shade50,
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(16)),
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       child: Text("Cancel", style: TextStyle(color: textColor)),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: _loading ? null : _save,
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple),
//                       child: _loading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text("Save",
//                               style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
