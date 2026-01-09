import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/forms/position_form.dart';

class Positions extends StatefulWidget {
  const Positions({super.key});

  @override
  State<Positions> createState() => PositionsState();
}

class PositionsState extends State<Positions> {
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

  Future<void> _openAddPosition() async {
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
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openAddPosition,
                  tooltip: "Add Position",
                ),
              ]
            : null,
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
                          onPressed: loadPositions, child: const Text("Retry")),
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
                                        child: Row(children: [
                                          Icon(Icons.edit,
                                              color: Colors.deepPurple),
                                          SizedBox(width: 12),
                                          Text("Edit")
                                        ]),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 12),
                                          Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red))
                                        ]),
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
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/forms/position_form.dart';

// class Positions extends StatefulWidget {
//   const Positions({super.key});

//   @override
//   State<Positions> createState() => PositionsState();
// }

// class PositionsState extends State<Positions> {
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

//   void handleMenuAction(String value) {
//     if (value == 'refresh') {
//       loadPositions();
//     }
//   }

//   Future<void> _editPosition(Map<String, dynamic> position) async {
//     final result = await Get.bottomSheet(
//       PositionForm(mode: PositionFormMode.edit, position: position),
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
//                           onPressed: loadPositions, child: const Text("Retry")),
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
//                                         child: Row(children: [
//                                           Icon(Icons.edit,
//                                               color: Colors.deepPurple),
//                                           SizedBox(width: 12),
//                                           Text("Edit"),
//                                         ]),
//                                       ),
//                                       const PopupMenuItem(
//                                         value: 'delete',
//                                         child: Row(children: [
//                                           Icon(Icons.delete, color: Colors.red),
//                                           SizedBox(width: 12),
//                                           Text("Delete",
//                                               style:
//                                                   TextStyle(color: Colors.red)),
//                                         ]),
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

// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/forms/position_form.dart';

// class Positions extends StatefulWidget {
//   const Positions({super.key});

//   @override
//   State<Positions> createState() => PositionsState();
// }

// class PositionsState extends State<Positions> {
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

//   void handleMenuAction(String value) {
//     if (value == 'refresh') {
//       loadPositions();
//     }
//   }

//   Future<void> _editPosition(Map<String, dynamic> position) async {
//     final result = await Get.bottomSheet(
//       PositionForm(mode: PositionFormMode.edit, position: position),
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

//     return isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : error != null
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error, size: 60, color: Colors.red),
//                     const SizedBox(height: 16),
//                     Text("Error: $error"),
//                     TextButton(
//                         onPressed: loadPositions, child: const Text("Retry")),
//                   ],
//                 ),
//               )
//             : positions.isEmpty
//                 ? const Center(child: Text("No positions found"))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: positions.length,
//                     itemBuilder: (context, index) {
//                       final pos = positions[index];
//                       final String id = pos['_id'] ?? pos['id'] ?? '';
//                       final String name = pos['name'] ?? 'Unknown';
//                       final String? shortName = pos['shortName'];

//                       return Card(
//                         margin: const EdgeInsets.symmetric(vertical: 6),
//                         child: ListTile(
//                           title: Text(name,
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold)),
//                           subtitle: shortName != null ? Text(shortName) : null,
//                           trailing: isAdmin
//                               ? PopupMenuButton<String>(
//                                   onSelected: (value) {
//                                     if (value == 'edit') {
//                                       _editPosition(pos);
//                                     } else if (value == 'delete') {
//                                       _deletePosition(id);
//                                     }
//                                   },
//                                   itemBuilder: (_) => [
//                                     const PopupMenuItem(
//                                       value: 'edit',
//                                       child: Row(children: [
//                                         Icon(Icons.edit,
//                                             color: Colors.deepPurple),
//                                         SizedBox(width: 12),
//                                         Text("Edit"),
//                                       ]),
//                                     ),
//                                     const PopupMenuItem(
//                                       value: 'delete',
//                                       child: Row(children: [
//                                         Icon(Icons.delete, color: Colors.red),
//                                         SizedBox(width: 12),
//                                         Text("Delete",
//                                             style:
//                                                 TextStyle(color: Colors.red)),
//                                       ]),
//                                     ),
//                                   ],
//                                 )
//                               : const Icon(Icons.chevron_right),
//                         ),
//                       );
//                     },
//                   );
//   }
// }
