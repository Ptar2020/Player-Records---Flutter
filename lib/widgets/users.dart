import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/models/user_model.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/widgets/refreshable_page.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => UsersState();
}

class UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ApiService apiService = Get.find<ApiService>();
  final AuthService authService = Get.find<AuthService>();

  late Future<List<UserModel>> _usersFuture;
  late Future<List<ClubModel>> _clubsFuture;
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    refresh();
  }

  // Public method — called from BottomMenu via GlobalKey
  Future<void> refresh() async {
    setState(() {
      _usersFuture = apiService.getAllUsers();
      _clubsFuture = apiService.getAllClubs();
    });
  }
    Widget _userCard(UserModel user) {
    final isCurrent = authService.currentUser?.id == user.id;
    final isExpanded = _expanded.contains(user.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.yellow[50] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))
        ],
        border: isCurrent ? Border.all(color: Colors.yellow[700]!.withOpacity(0.6), width: 1.2) : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Gradient top bar
            Container(
              height: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)]),
              ),
            ),

            // Header row (clickable)
            InkWell(
              onTap: () => setState(() {
                if (isExpanded) {
                  _expanded.remove(user.id);
                } else {
                  _expanded.add(user.id!);
                }
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple[50],
                      child: Text(
                        (user.username.isNotEmpty ? user.username[0] : '?').toUpperCase(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF4C1D95)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          Text(user.email ?? '-', style: TextStyle(color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),

            // EXPANDED CONTENT — now safe and working
            if (isExpanded)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("User ID: ${user.id}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text("Role: ${user.role ?? 'Unknown'}"),
                    const SizedBox(height: 8),
                    Text("Created: ${user.createdAt ?? 'N/A'}"),
                    const SizedBox(height: 8),
                    // Fixed: user.club is a String (or null), not an object
                    if (user.club != null && user.club.toString().isNotEmpty)
                      Text("Club: ${user.club}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshablePage(
      onRefresh: refresh,
      child: FutureBuilder<List<UserModel>>(
        future: _usersFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}", style: const TextStyle(color: Colors.red)));
          }
          final users = snap.data ?? [];
          if (users.isEmpty) return const Center(child: Text("No users found"));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: users.length,
            itemBuilder: (_, i) => _userCard(users[i]),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// class Users extends StatefulWidget with HasAppBarTitle, HasAppBarActions {
//   const Users({super.key});


//   @override
//   Widget appBarActions(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         final state = context.findAncestorStateOfType<UsersState>();
//         if (value == 'refresh') state?._refresh();
//         if (value == 'logout') Get.find<AuthService>().logout();
//       },
//       itemBuilder: (_) => const [
//         PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//         PopupMenuItem(value: 'logout', child: Text("Logout")),
//       ],
//     );
//   }
// }

// class UsersState extends State<Users> with AutomaticKeepAliveClientMixin<Users> {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService apiService = Get.find<ApiService>();
//   final AuthService authService = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;
//   late Future<List<ClubModel>> _clubsFuture;
//   final Set<String> _expanded = {};
//   bool _loadingSave = false;

//   @override
//   void initState() {
//     super.initState();
//     _refresh();
//   }

//   void _refresh() {
//     setState(() {
//       _usersFuture = apiService.getAllUsers();
//       _clubsFuture = apiService.getAllClubs();
//     });
//   }

//   Widget _userCard(UserModel user) {
//     final isCurrent = authService.currentUser?.id == user.id;
//     final isExpanded = _expanded.contains(user.id);

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 280),
//       margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: isCurrent ? Colors.yellow[50] : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))
//         ],
//         border: isCurrent ? Border.all(color: Colors.yellow[700]!.withOpacity(0.6), width: 1.2) : null,
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: Column(
//           children: [
//             Container(height: 6, decoration: const BoxDecoration(
//               gradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)]),
//             )),
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   if (isExpanded) _expanded.remove(user.id);
//                   else _expanded.add(user.id!);
//                 });
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.deepPurple[50],
//                       child: Text(
//                         (user.username.isNotEmpty ? user.username[0] : '?').toUpperCase(),
//                         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF4C1D95)),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(user.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//                           Text(user.email ?? '-', style: TextStyle(color: Colors.grey[700])),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return FutureBuilder<List<UserModel>>(
//       future: _usersFuture,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
//         }
//         if (snap.hasError) {
//           return Center(child: Text("Error: ${snap.error}", style: const TextStyle(color: Colors.red)));
//         }
//         final users = snap.data ?? [];
//         if (users.isEmpty) return const Center(child: Text("No users found"));

//         return RefreshIndicator(
//           onRefresh: () async => _refresh(),
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             itemCount: users.length,
//             itemBuilder: (context, i) => _userCard(users[i]),
//           ),
//         );
//       },
//     );
//   }
// }
