import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/services/api_service.dart';

enum PositionFormMode { create, edit }

class PositionForm extends StatefulWidget {
  final PositionFormMode mode;
  final Map<String, dynamic>? position;

  const PositionForm({
    super.key,
    required this.mode,
    this.position,
  });

  @override
  State<PositionForm> createState() => _PositionFormState();
}

class _PositionFormState extends State<PositionForm> {
  final _formKey = GlobalKey<FormState>();
  final ApiService api = Get.find<ApiService>();

  late TextEditingController _nameCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.position?['name'] ?? "");
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (widget.mode == PositionFormMode.create) {
        await api.createPosition(
          name: _nameCtrl.text.trim(),
          // shortName is no longer sent — backend will auto-generate it
        );
      } else {
        final id = widget.position!['_id'] ?? widget.position!['id'];
        await api.updatePosition(
          id,
          name: _nameCtrl.text.trim(),
          // shortName not sent on edit either (backend will handle if needed)
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final hintColor = theme.textTheme.bodyMedium?.color;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                widget.mode == PositionFormMode.create
                    ? "Add Position"
                    : "Edit Position",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Position Name *",
                  labelStyle: TextStyle(color: hintColor),
                  filled: true,
                  fillColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? "Required" : null,
              ),
              const SizedBox(height: 16),
              Text(
                "Short name will be auto-generated (e.g. GK, CB, ST)",
                style: TextStyle(
                  color: hintColor?.withOpacity(0.8),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: Text("Cancel", style: TextStyle(color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save",
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/services/api_service.dart';

// enum PositionFormMode { create, edit }

// class PositionForm extends StatefulWidget {
//   final PositionFormMode mode;
//   final Map<String, dynamic>? position;

//   const PositionForm({
//     super.key,
//     required this.mode,
//     this.position,
//   });

//   @override
//   State<PositionForm> createState() => _PositionFormState();
// }

// class _PositionFormState extends State<PositionForm> {
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
//       if (widget.mode == PositionFormMode.create) {
//         await api.createPosition(
//           name: _nameCtrl.text.trim(),
//           shortName: _shortNameCtrl.text.trim().isEmpty
//               ? null
//               : _shortNameCtrl.text.trim(),
//         );
//       } else {
//         final id = widget.position!['_id'] ?? widget.position!['id'];
//         await api.updatePosition(
//           id,
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
//                 widget.mode == PositionFormMode.create
//                     ? "Add Position"
//                     : "Edit Position",
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
