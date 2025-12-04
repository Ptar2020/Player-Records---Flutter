import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final authService = Get.find<AuthService>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await authService.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      Get.back(); // close modal
      Get.snackbar(
        "WELCOME!",
        "",
        backgroundColor: Colors.deepPurple[300],
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 15,
        titleText: const Center(
          child: Text(
            "WELCOME!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        messageText: const SizedBox(),
      );
    } else {
      Get.snackbar(
        "Login Failed",
        authService.errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 6),
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        titleText: Center(
          child: Text(
            "Login Failed",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        messageText: Center(
          child: Text(
            authService.errorMessage,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        mainButton: TextButton(onPressed: null, child: const SizedBox()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 560),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Log In",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v!.trim().isEmpty ? "Enter username" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onFieldSubmitted: (_) => _login(),
                  validator: (v) => v!.isEmpty ? "Enter password" : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text("Log In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/auth_service.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   final _formKey = GlobalKey<FormState>();
//   final authService = Get.find<AuthService>();

//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     final success = await authService.login(
//       username: _usernameController.text.trim(),
//       password: _passwordController.text,
//     );

//     setState(() => _isLoading = false);

//     if (!mounted) return;

//     if (success) {
//       Get.back(); // Closes the modal
// Get.snackbar(
//   "WELCOME!",                   
//   "",                            
//   backgroundColor: Colors.deepPurple[300],
//   colorText: Colors.white,
//   snackPosition: SnackPosition.TOP,
//   duration: const Duration(seconds: 2),
//   margin: const EdgeInsets.all(10),
//   borderRadius: 15,

//   mainButton: TextButton(        
//     onPressed: null,
//     child: const SizedBox(),
//   ),
//   titleText: const Center(     
//     child: Text(
//       "WELCOME!",
//       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//     ),
//   ),
//   messageText: const SizedBox(),  // hide the empty message completely
// );
    
//     } else {
//       Get.snackbar(
//   "Login Failed",
//   authService.errorMessage,
//   backgroundColor: Colors.red,
//   colorText: Colors.white,
//   snackPosition: SnackPosition.BOTTOM,
//   duration: const Duration(seconds: 6),
//   margin: const EdgeInsets.all(20),
//   borderRadius: 12,

//   // ← Center everything perfectly
//   mainButton: TextButton(onPressed: null, child: const SizedBox()),
//   titleText: Center(
//     child: Text(
//       "Login Failed",
//       style: const TextStyle(fontWeight: FontWeight.bold),
//     ),
//   ),
//   messageText: Center(
//     child: Text(
//       authService.errorMessage,
//       style: const TextStyle(fontSize: 14),
//     ),
//   ),
// );
     
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints(maxHeight: 560),
//       padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header: Title + Close button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "Log In",
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 onPressed: () => Get.back(),
//                 icon: const Icon(Icons.close, size: 28),
//                 style: IconButton.styleFrom(
//                   backgroundColor: Colors.grey[200],
//                   padding: const EdgeInsets.all(10),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Form
//           Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: const InputDecoration(
//                     labelText: "Username",
//                     prefixIcon: Icon(Icons.person_outline),
//                     border: OutlineInputBorder(),
//                   ),
//                   textInputAction: TextInputAction.next,
//                   validator: (v) => v!.trim().isEmpty ? "Enter username" : null,
//                 ),
//                 const SizedBox(height: 16),

//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     labelText: "Password",
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     border: OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                     ),
//                   ),
//                   onFieldSubmitted: (_) => _login(),
//                   validator: (v) => v!.isEmpty ? "Enter password" : null,
//                 ),
//                 const SizedBox(height: 32),

//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     onPressed: _isLoading ? null : _login,
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
//                           )
//                         : const Text("Log In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }