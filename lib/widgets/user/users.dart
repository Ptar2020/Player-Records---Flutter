import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/models/user_model.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/widgets/refreshable_page.dart';
import 'package:precords_android/forms/user_form.dart';

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.25 : 0.15),
        border: Border.all(color: color.withOpacity(isDark ? 0.7 : 1.0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? color.withOpacity(0.9) : color,
        ),
      ),
    );
  }
}

/// ---------------- USER CARD (PERFECT & ERROR-FREE) ----------------
class UserCardFinal extends StatelessWidget {
  final UserModel user;
  final bool isCurrentUser;
  final bool canEdit;
  final VoidCallback onEdit;
  final String Function(dynamic) formatDate;
  final Color Function(String?) roleColor;

  const UserCardFinal({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.canEdit,
    required this.onEdit,
    required this.formatDate,
    required this.roleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black87);
    final secondaryText = theme.textTheme.bodyMedium?.color ??
        (isDark ? Colors.white70 : Colors.grey.shade600);

    final role = (user.role ?? "user").toUpperCase();

    return Card(
      color: theme.cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrentUser
                ? Colors.amber.shade600
                : theme.dividerColor.withOpacity(0.3),
            width: isCurrentUser ? 2.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + Username + Edit
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@${user.username.toLowerCase()}",
                        style: TextStyle(fontSize: 14, color: secondaryText),
                      ),
                    ],
                  ),
                ),
                if (canEdit)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    color: Colors.deepPurple.shade600,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Email + Phone
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.email ?? "—",
                    style: TextStyle(
                        fontSize: 14, color: textColor.withOpacity(0.8)),
                  ),
                ),
                Expanded(
                  child: Text(
                    user.phone ?? "—",
                    style: TextStyle(
                        fontSize: 14, color: textColor.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Tag(
                    label: user.clubName ?? user.club ?? "—",
                    color: Colors.grey.shade600),
                _Tag(label: role, color: roleColor(user.role)),
                _Tag(
                  label: user.isActive ? "Active" : "Inactive",
                  color: user.isActive
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
                if (isCurrentUser)
                  _Tag(label: "YOU", color: Colors.amber.shade700),
              ],
            ),
            const SizedBox(height: 12),

            // Member Since
            Text(
              "Member Since: ${formatDate(user.createdAt)}",
              style: TextStyle(fontSize: 13, color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SKELETON (NOW 100% CORRECT & BEAUTIFUL) ----------------
class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: shimmer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            Container(height: 18, width: 140, color: shimmer),
                      ),
                      const SizedBox(height: 8),
                      // Username
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            Container(height: 14, width: 100, color: shimmer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Email + Phone
            Row(
              children: [
                Expanded(child: Container(height: 12, color: shimmer)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 12, color: shimmer)),
              ],
            ),
            const SizedBox(height: 16),

            // Tags
            Wrap(
              spacing: 8,
              children: List.generate(
                3,
                (_) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(width: 70, height: 24, color: shimmer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- USERS PAGE (no changes needed) ----------------
class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ApiService api = Get.find<ApiService>();
  final AuthService auth = Get.find<AuthService>();

  late Future<List<UserModel>> _usersFuture;
  final RxList<ClubModel> clubs = <ClubModel>[].obs;
  bool clubsLoaded = false;

  @override
  void initState() {
    super.initState();
    refresh();
    loadClubs();
  }

  Future<void> loadClubs() async {
    if (!clubsLoaded) {
      try {
        final list = await api.getAllClubs();
        clubs.assignAll(list);
        clubsLoaded = true;
      } catch (e) {
        debugPrint("Failed to load clubs: $e");
      }
    }
  }

  Future<void> refresh() async {
    setState(() {
      _usersFuture = api.getAllUsers();
    });
  }

  String _formatDate(dynamic date) {
    if (date == null) return '—';
    final str = date.toString();
    if (!str.contains('T')) return str.split(' ').first;
    final parts = str.split('T');
    final datePart = parts[0];
    final ymd = datePart.split('-');
    if (ymd.length != 3) return datePart;

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = int.tryParse(ymd[1]) ?? 1;
    return '${ymd[2]} ${months[month - 1]} ${ymd[0]}';
  }

  Color _roleColor(String? role) {
    final r = (role ?? '').toLowerCase();
    if (r.contains('admin')) return Colors.red.shade600;
    if (r.contains('coach')) return Colors.orange.shade700;
    if (r.contains('scout')) return Colors.purple.shade600;
    if (r.contains('player')) return Colors.blue.shade600;
    return Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUser = auth.currentUser;
    final isAdmin = currentUser?.role.toLowerCase() == 'admin';

    return RefreshablePage(
      onRefresh: refresh,
      child: Stack(
        children: [
          FutureBuilder<List<UserModel>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, __) => const UserCardSkeleton(),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, __) =>
                      const UserCardSkeleton(), // ← Now from your new file
                );
              }
        

              var users = snapshot.data!;
              if (!isAdmin) {
                users = users.where((u) => u.id == currentUser?.id).toList();
              }

              if (users.isEmpty) {
                return Center(
                  child: Text("No users found",
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color)),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 16, 16, isAdmin ? 100 : 32),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final user = users[i];
                  final isCurrent = currentUser?.id == user.id;
                  final canEdit = isAdmin || isCurrent;

                  return UserCardFinal(
                    user: user,
                    isCurrentUser: isCurrent,
                    canEdit: canEdit,
                    onEdit: () async {
                      final result = await Get.bottomSheet(
                        UserForm(user: user, clubs: clubs),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                      if (result == true) refresh();
                    },
                    formatDate: _formatDate,
                    roleColor: _roleColor,
                  );
                },
              );
            },
          ),
          if (isAdmin)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                backgroundColor: Colors.deepPurple,
                onPressed: () async {
                  final result = await Get.bottomSheet(
                    UserForm(clubs: clubs),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                  if (result == true) refresh();
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Add User"),
              ),
            ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/user/user_form.dart';

// /// ---------------- TAG WIDGET ----------------
// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Tag({super.key, required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.15),
//           border: Border.all(color: color),
//           borderRadius: BorderRadius.circular(16)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//     );
//   }
// }

// /// ---------------- DETAIL ROW ----------------
// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 110,
//           child: Text("$label:",
//               style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                   fontSize: 14)),
//         ),
//         Expanded(
//           child: Text(value,
//               style:
//                   const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
//               overflow: TextOverflow.ellipsis),
//         ),
//       ],
//     );
//   }
// }

// /// ---------------- USER CARD FINAL ----------------
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final bool canEdit; // Permission to edit
//   final VoidCallback onEdit;
//   final String Function(dynamic) formatDate;
//   final Color Function(String?) roleColor;

//   const UserCardFinal({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.canEdit,
//     required this.onEdit,
//     required this.formatDate,
//     required this.roleColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final role = (user.role ?? "user").toUpperCase();
//     final fullName = user.name;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isCurrentUser ? const Color(0xFFFFD700) : Colors.grey.shade200,
//           width: isCurrentUser ? 2.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isCurrentUser ? 0.16 : 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top row: Name + username + edit icon
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(fullName,
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 2),
//                     Text("@${user.username.toLowerCase()}",
//                         style: TextStyle(
//                             fontSize: 14, color: Colors.grey.shade600)),
//                   ],
//                 ),
//               ),
//               if (canEdit)
//                 IconButton(
//                   onPressed: onEdit,
//                   icon: const Icon(Icons.edit_rounded),
//                   color: Colors.purple.shade700,
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Contact row: Email + phone
//           Row(
//             children: [
//               Expanded(
//                   child: Text(user.email ?? "—",
//                       style: TextStyle(
//                           fontSize: 14, color: Colors.grey.shade800))),
//               Expanded(
//                   child: Text(user.phone ?? "—",
//                       style: TextStyle(
//                           fontSize: 14, color: Colors.grey.shade800))),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Club, Role, Status row
//           Wrap(
//             spacing: 8,
//             runSpacing: 6,
//             children: [
//               _Tag(
//                   label: user.clubName ?? user.club ?? "—",
//                   color: Colors.grey.shade700),
//               _Tag(label: role, color: roleColor(user.role)),
//               _Tag(
//                   label: user.isActive ? "Active" : "Inactive",
//                   color: user.isActive ? Colors.green : Colors.red),
//               if (isCurrentUser)
//                 _Tag(label: "YOU", color: Colors.amber.shade700),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Member Since
//           _DetailRow(label: "Member Since", value: formatDate(user.createdAt)),
//         ],
//       ),
//     );
//   }
// }

// /// ---------------- USER CARD SKELETON ----------------
// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Container(height: 18, width: 120, color: Colors.grey.shade300),
//           const SizedBox(height: 6),
//           Container(height: 14, width: 80, color: Colors.grey.shade200),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(height: 12, width: 100, color: Colors.grey.shade300),
//               const SizedBox(width: 8),
//               Container(height: 12, width: 60, color: Colors.grey.shade300),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(height: 12, width: 80, color: Colors.grey.shade300),
//         ],
//       ),
//     );
//   }
// }

// /// ---------------- USERS PAGE ----------------
// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;
//   final RxList<ClubModel> clubs = <ClubModel>[].obs;
//   bool clubsLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//     loadClubs();
//   }

//   Future<void> loadClubs() async {
//     if (!clubsLoaded) {
//       try {
//         final list = await api.getAllClubs();
//         clubs.assignAll(list);
//         clubsLoaded = true;
//       } catch (e) {
//         debugPrint("Failed to load clubs: $e");
//       }
//     }
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     final str = date.toString();
//     if (!str.contains('T')) return str.split(' ').first;
//     final parts = str.split('T');
//     final datePart = parts[0];
//     final ymd = datePart.split('-');
//     if (ymd.length != 3) return datePart;

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     final month = int.tryParse(ymd[1]) ?? 1;
//     return '${ymd[2]} ${months[month - 1]} ${ymd[0]}';
//   }

//   Color _roleColor(String? role) {
//     final r = (role ?? '').toLowerCase();
//     if (r.contains('admin')) return Colors.red.shade600;
//     if (r.contains('coach')) return Colors.orange.shade700;
//     if (r.contains('player')) return Colors.blue.shade700;
//     return Colors.purple.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     final currentUser = auth.currentUser;
//     final isAdmin = currentUser?.role?.toLowerCase() == 'admin';

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: Stack(
//         children: [
//           FutureBuilder<List<UserModel>>(
//             future: _usersFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: 6,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (_, __) => const UserCardSkeleton(),
//                 );
//               }

//               if (snapshot.hasError || !snapshot.hasData) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline,
//                           size: 64, color: Colors.red.shade400),
//                       const SizedBox(height: 16),
//                       const Text("Failed to load users"),
//                       Text("${snapshot.error}",
//                           style: const TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 );
//               }

//               var users = snapshot.data!;
//               if (!isAdmin) {
//                 // Non-admins see only themselves
//                 users = users.where((u) => u.id == currentUser?.id).toList();
//               }

//               if (users.isEmpty) {
//                 return const Center(
//                     child: Text("No users found",
//                         style: TextStyle(fontSize: 16, color: Colors.grey)));
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//                 itemCount: users.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, i) {
//                   final user = users[i];
//                   final isCurrent = currentUser?.id == user.id;
//                   final canEdit = isAdmin || isCurrent;

//                   return UserCardFinal(
//                     user: user,
//                     isCurrentUser: isCurrent,
//                     canEdit: canEdit,
//                     onEdit: () async {
//                       final result = await Get.bottomSheet(
//                         UserForm(user: user, clubs: clubs),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                       );
//                       if (result == true) refresh();
//                     },
//                     formatDate: _formatDate,
//                     roleColor: _roleColor,
//                   );
//                 },
//               );
//             },
//           ),
//           if (isAdmin) // Only admin can add users
//             Positioned(
//               bottom: 24,
//               right: 24,
//               child: FloatingActionButton.extended(
//                 onPressed: () async {
//                   final result = await Get.bottomSheet(
//                     UserForm(clubs: clubs),
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                   );
//                   if (result == true) refresh();
//                 },
//                 icon: const Icon(Icons.add),
//                 label: const Text("Add User"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/user/user_form.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;

//   final RxList<ClubModel> clubs = <ClubModel>[].obs;
//   bool clubsLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//     loadClubs();
//   }

//   Future<void> loadClubs() async {
//     if (!clubsLoaded) {
//       try {
//         final list = await api.getAllClubs();
//         clubs.assignAll(list);
//         clubsLoaded = true;
//       } catch (e) {
//         debugPrint("Failed to load clubs: $e");
//       }
//     }
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     final str = date.toString();
//     if (!str.contains('T')) return str.split(' ').first;
//     final parts = str.split('T');
//     final datePart = parts[0];
//     final ymd = datePart.split('-');
//     if (ymd.length != 3) return datePart;

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     final month = int.tryParse(ymd[1]) ?? 1;
//     return '${ymd[2]} ${months[month - 1]} ${ymd[0]}';
//   }

//   Color _roleColor(String? role) {
//     final r = (role ?? '').toLowerCase();
//     if (r.contains('admin')) return Colors.red.shade600;
//     if (r.contains('coach')) return Colors.orange.shade700;
//     if (r.contains('player')) return Colors.blue.shade700;
//     return Colors.purple.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);


//     return RefreshablePage(
//       onRefresh: refresh,
//       child: Stack(
//         children: [
//           FutureBuilder<List<UserModel>>(
//             future: _usersFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return ListView.separated(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: 6,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (_, __) => const UserCardSkeleton(),
//                 );
//               }

//               if (snapshot.hasError || !snapshot.hasData) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.error_outline,
//                           size: 64, color: Colors.red.shade400),
//                       const SizedBox(height: 16),
//                       const Text("Failed to load users"),
//                       Text("${snapshot.error}",
//                           style: const TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 );
//               }

//               final users = snapshot.data!;
//               if (users.isEmpty) {
//                 return const Center(
//                     child: Text("No users found",
//                         style: TextStyle(fontSize: 16, color: Colors.grey)));
//               }

//               return ListView.separated(
//                 padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//                 itemCount: users.length,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, i) {
//                   final user = users[i];
//                   final isCurrent = auth.currentUser?.id == user.id;

//                   return UserCardFinal(
//                     user: user,
//                     isCurrentUser: isCurrent,
//                     onEdit: () async {
//                       final result = await Get.bottomSheet(
//                         UserForm(user: user, clubs: clubs),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                       );
//                       if (result == true) refresh();
//                     },
//                     formatDate: _formatDate,
//                     roleColor: _roleColor,
//                   );
//                 },
//               );
//             },
//           ),
//           Positioned(
//             bottom: 24,
//             right: 24,
//             child: FloatingActionButton.extended(
//               onPressed: () async {
//                 final result = await Get.bottomSheet(
//                   UserForm(clubs: clubs),
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                 );
//                 if (result == true) refresh();
//               },
//               icon: const Icon(Icons.add),
//               label: const Text("Add User"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------- USER CARD FINAL ----------------
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final VoidCallback onEdit;
//   final String Function(dynamic) formatDate;
//   final Color Function(String?) roleColor;

//   const UserCardFinal({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.onEdit,
//     required this.formatDate,
//     required this.roleColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final role = (user.role ?? "user").toUpperCase();
//     final fullName = user.name;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isCurrentUser ? const Color(0xFFFFD700) : Colors.grey.shade200,
//           width: isCurrentUser ? 2.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isCurrentUser ? 0.16 : 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top row: Name + username + edit icon
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(fullName,
//                         style: const TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 2),
//                     Text("@${user.username.toLowerCase()}",
//                         style: TextStyle(
//                             fontSize: 14, color: Colors.grey.shade600)),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 onPressed: onEdit,
//                 icon: const Icon(Icons.edit_rounded),
//                 color: Colors.purple.shade700,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Contact row: Email + phone
//           Row(
//             children: [
//               Expanded(
//                   child: Text(user.email ?? "—",
//                       style: TextStyle(
//                           fontSize: 14, color: Colors.grey.shade800))),
//               Expanded(
//                   child: Text(user.phone ?? "—",
//                       style: TextStyle(
//                           fontSize: 14, color: Colors.grey.shade800))),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Club, Role, Status row
//           Wrap(
//             spacing: 8,
//             runSpacing: 6,
//             children: [
//               _Tag(
//                   label: user.clubName ?? user.club ?? "—",
//                   color: Colors.grey.shade700),
//               _Tag(label: role, color: roleColor(user.role)),
//               _Tag(
//                   label: user.isActive ? "Active" : "Inactive",
//                   color: user.isActive ? Colors.green : Colors.red),
//               if (isCurrentUser)
//                 _Tag(label: "YOU", color: Colors.amber.shade700),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Member Since
//           _DetailRow(label: "Member Since", value: formatDate(user.createdAt)),
//         ],
//       ),
//     );
//   }
// }

// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;
//   const _Tag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.15),
//           border: Border.all(color: color),
//           borderRadius: BorderRadius.circular(16)),
//       child: Text(label,
//           style: TextStyle(
//               fontSize: 12, fontWeight: FontWeight.bold, color: color)),
//     );
//   }
// }

// // ---------------- DETAIL ROW ----------------
// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 110,
//           child: Text("$label:",
//               style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey.shade700,
//                   fontSize: 14)),
//         ),
//         Expanded(
//           child: Text(value,
//               style:
//                   const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
//               overflow: TextOverflow.ellipsis),
//         ),
//       ],
//     );
//   }
// }

// // ---------------- USER CARD SKELETON ----------------
// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Column(
//         children: [
//           Container(height: 18, width: 120, color: Colors.grey.shade300),
//           const SizedBox(height: 6),
//           Container(height: 14, width: 80, color: Colors.grey.shade200),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(height: 12, width: 100, color: Colors.grey.shade300),
//               const SizedBox(width: 8),
//               Container(height: 12, width: 60, color: Colors.grey.shade300),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(height: 12, width: 80, color: Colors.grey.shade300),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/user/user_form.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;

//   // Reactive cached clubs
//   final RxList<ClubModel> clubs = <ClubModel>[].obs;
//   bool clubsLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//     loadClubs();
//   }

//   Future<void> loadClubs() async {
//     if (!clubsLoaded) {
//       try {
//         final list = await api.getAllClubs();
//         clubs.assignAll(list); // RxList updated
//         clubsLoaded = true;
//       } catch (e) {
//         debugPrint("Failed to load clubs: $e");
//       }
//     }
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     final str = date.toString();
//     if (!str.contains('T')) return str.split(' ').first;
//     final parts = str.split('T');
//     final datePart = parts[0];
//     final timePart = parts.length > 1 ? ' ${parts[1].substring(0, 5)}' : '';
//     final ymd = datePart.split('-');
//     if (ymd.length != 3) return datePart;

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];
//     final month = int.tryParse(ymd[1]) ?? 1;
//     return '${ymd[2]} ${months[month - 1]} ${ymd[0]}$timePart';
//   }

//   Color _roleColor(String? role) {
//     final r = (role ?? '').toLowerCase();
//     if (r.contains('admin')) return Colors.red.shade600;
//     if (r.contains('mod')) return Colors.orange.shade700;
//     if (r.contains('member')) return Colors.blue.shade700;
//     return Colors.purple.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: Column(
//         children: [
//           // Add User button
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () async {
//                       final result = await Get.bottomSheet(
//                         UserForm(clubs: clubs),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                       );
//                       if (result == true) refresh();
//                     },
//                     icon: const Icon(Icons.add),
//                     label: const Text("Add User"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: FutureBuilder<List<UserModel>>(
//               future: _usersFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return ListView.separated(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: 8,
//                     separatorBuilder: (_, __) => const SizedBox(height: 16),
//                     itemBuilder: (_, __) => UserCardSkeleton(),
//                   );
//                 }

//                 if (snapshot.hasError || !snapshot.hasData) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline,
//                             size: 64, color: Colors.red.shade400),
//                         const SizedBox(height: 16),
//                         const Text("Failed to load users"),
//                         Text("${snapshot.error}",
//                             style: const TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   );
//                 }

//                 final users = snapshot.data!;
//                 if (users.isEmpty) {
//                   return const Center(
//                       child: Text("No users found",
//                           style: TextStyle(fontSize: 16, color: Colors.grey)));
//                 }

//                 return ListView.separated(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//                   itemCount: users.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                   itemBuilder: (_, i) {
//                     final user = users[i];
//                     final isCurrent = auth.currentUser?.id == user.id;

//                     return UserCardFinal(
//                       user: user,
//                       isCurrentUser: isCurrent,
//                       onEdit: () async {
//                         final result = await Get.bottomSheet(
//                           UserForm(user: user, clubs: clubs),
//                           isScrollControlled: true,
//                           backgroundColor: Colors.transparent,
//                         );
//                         if (result == true) refresh();
//                       },
//                       formatDate: _formatDate,
//                       roleColor: _roleColor,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------- USER CARD FINAL ----------------
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final VoidCallback onEdit;
//   final String Function(dynamic) formatDate;
//   final Color Function(String?) roleColor;

//   const UserCardFinal({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.onEdit,
//     required this.formatDate,
//     required this.roleColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final role = (user.role ?? "user").toUpperCase();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 22, 16, 26),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isCurrentUser ? const Color(0xFFFFD700) : Colors.grey.shade200,
//           width: isCurrentUser ? 2.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isCurrentUser ? 0.16 : 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                       colors: [Color(0xFF9333EA), Color(0xFFEC4899)]),
//                 ),
//                 child: CircleAvatar(
//                   radius: 32,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     user.username.isNotEmpty
//                         ? user.username[0].toUpperCase()
//                         : "?",
//                     style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6B21A8)),
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 16),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.username,
//                       style: const TextStyle(
//                           fontSize: 21, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       "@${user.username.toLowerCase()}",
//                       style: TextStyle(
//                           fontSize: 14.5, color: Colors.grey.shade600),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       user.email ?? "—",
//                       style: TextStyle(
//                           fontSize: 15.5, color: Colors.grey.shade800),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),

//               // Edit Icon
//               IconButton(
//                 onPressed: onEdit,
//                 icon: const Icon(Icons.edit_rounded, size: 24),
//                 color: Colors.purple.shade700,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // Bottom: Role, Active Status, YOU badge
//           Wrap(
//             spacing: 12,
//             runSpacing: 10,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: roleColor(user.role).withOpacity(0.14),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(color: roleColor(user.role), width: 1.4),
//                 ),
//                 child: Text(
//                   role,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: roleColor(user.role)),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: user.isActive
//                           ? Colors.green.shade600
//                           : Colors.red.shade600,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 7),
//                   Text(
//                     user.isActive ? "Active" : "Inactive",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: user.isActive
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               if (isCurrentUser)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFD700),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     "YOU",
//                     style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Details
//           _DetailRow(label: "Club", value: user.clubName ?? user.club ?? "—"),
//           const SizedBox(height: 8),
//           _DetailRow(label: "Member Since", value: formatDate(user.createdAt)),
//         ],
//       ),
//     );
//   }
// }

// // ---------------- DETAIL ROW ----------------
// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 110,
//           child: Text(
//             "$label:",
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade700,
//                 fontSize: 15),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ---------------- USER CARD SKELETON ----------------
// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.07),
//               blurRadius: 20,
//               offset: const Offset(0, 8))
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 32, backgroundColor: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(height: 20, width: 180, color: Colors.grey.shade300),
//                 const SizedBox(height: 8),
//                 Container(height: 16, width: 140, color: Colors.grey.shade200),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'user_form.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     final str = date.toString();
//     if (!str.contains('T')) return str.split(' ').first;
//     final parts = str.split('T');
//     final datePart = parts[0];
//     final timePart = parts.length > 1 ? ' ${parts[1].substring(0, 5)}' : '';
//     final ymd = datePart.split('-');
//     if (ymd.length != 3) return datePart;

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];

//     final month = int.tryParse(ymd[1]) ?? 1;
//     return '${ymd[2]} ${months[month - 1]} ${ymd[0]}$timePart';
//   }

//   Color _roleColor(String? role) {
//     final r = (role ?? '').toLowerCase();
//     if (r.contains('admin')) return Colors.red.shade600;
//     if (r.contains('coach')) return Colors.orange.shade700;
//     if (r.contains('player')) return Colors.blue.shade700;
//     return Colors.purple.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       body: RefreshablePage(
//         onRefresh: refresh,
//         child: FutureBuilder<List<UserModel>>(
//           future: _usersFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: 8,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, __) => const UserCardSkeleton(),
//               );
//             }

//             if (snapshot.hasError || !snapshot.hasData) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline,
//                         size: 64, color: Colors.red.shade400),
//                     const SizedBox(height: 16),
//                     const Text("Failed to load users"),
//                     Text("${snapshot.error}",
//                         style: const TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               );
//             }

//             final users = snapshot.data!;

//             if (users.isEmpty) {
//               return const Center(
//                   child: Text("No users found",
//                       style: TextStyle(fontSize: 16, color: Colors.grey)));
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//               itemCount: users.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (_, i) {
//                 final user = users[i];
//                 final isCurrent = auth.currentUser?.id == user.id;

//                 return UserCardFinal(
//                   user: user,
//                   isCurrentUser: isCurrent,
//                   onEdit: () async {
//                     final result = await Get.bottomSheet(
//                       UserForm(user: user),
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                     );
//                     if (result == true) refresh();
//                   },
//                   formatDate: _formatDate,
//                   roleColor: _roleColor,
//                 );
//               },
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Icons.add_rounded),
//         label: const Text("Add User"),
//         onPressed: () async {
//           final result = await Get.bottomSheet(
//             const UserForm(),
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//           );
//           if (result == true) refresh();
//         },
//       ),
//     );
//   }
// }

// // ------------------- USER CARD -------------------
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final VoidCallback onEdit;
//   final String Function(dynamic) formatDate;
//   final Color Function(String?) roleColor;

//   const UserCardFinal({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.onEdit,
//     required this.formatDate,
//     required this.roleColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final role = (user.role ?? "user").toUpperCase();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 22, 16, 26),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isCurrentUser ? const Color(0xFFFFD700) : Colors.grey.shade200,
//           width: isCurrentUser ? 2.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isCurrentUser ? 0.16 : 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                       colors: [Color(0xFF9333EA), Color(0xFFEC4899)]),
//                 ),
//                 child: CircleAvatar(
//                   radius: 32,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     user.username.isNotEmpty
//                         ? user.username[0].toUpperCase()
//                         : "?",
//                     style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6B21A8)),
//                   ),
//                 ),
//               ),

//               const SizedBox(width: 16),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.username,
//                       style: const TextStyle(
//                           fontSize: 21, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       "@${user.username.toLowerCase()}",
//                       style: TextStyle(
//                           fontSize: 14.5, color: Colors.grey.shade600),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       user.email ?? "—",
//                       style: TextStyle(
//                           fontSize: 15.5, color: Colors.grey.shade800),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),

//               IconButton(
//                 onPressed: onEdit,
//                 icon: const Icon(Icons.edit_rounded, size: 24),
//                 color: Colors.purple.shade700,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Wrap(
//             spacing: 12,
//             runSpacing: 10,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: roleColor(user.role).withOpacity(0.14),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(color: roleColor(user.role), width: 1.4),
//                 ),
//                 child: Text(
//                   role,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: roleColor(user.role)),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: user.isActive
//                           ? Colors.green.shade600
//                           : Colors.red.shade600,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 7),
//                   Text(
//                     user.isActive ? "Active" : "Inactive",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: user.isActive
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               if (isCurrentUser)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFD700),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     "YOU",
//                     style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _DetailRow(label: "Club", value: user.clubName ?? user.club ?? "—"),
//           const SizedBox(height: 8),
//           _DetailRow(label: "Member Since", value: formatDate(user.createdAt)),
//         ],
//       ),
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 110,
//           child: Text(
//             "$label:",
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade700,
//                 fontSize: 15),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.07),
//               blurRadius: 20,
//               offset: const Offset(0, 8))
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 32, backgroundColor: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(height: 20, width: 180, color: Colors.grey.shade300),
//                 const SizedBox(height: 8),
//                 Container(height: 16, width: 140, color: Colors.grey.shade200),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'user_form.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => _UsersState();
// }

// class _UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     final str = date.toString();
//     if (!str.contains('T')) return str.split(' ').first;
//     final parts = str.split('T');
//     final datePart = parts[0];
//     final timePart = parts.length > 1 ? ' ${parts[1].substring(0, 5)}' : '';
//     final ymd = datePart.split('-');
//     if (ymd.length != 3) return datePart;

//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec'
//     ];

//     final month = int.tryParse(ymd[1]) ?? 1;
//     return '${ymd[2]} ${months[month - 1]} ${ymd[0]}$timePart';
//   }

//   Color _roleColor(String? role) {
//     final r = (role ?? '').toLowerCase();
//     if (r.contains('admin')) return Colors.red.shade600;
//     if (r.contains('mod')) return Colors.orange.shade700;
//     if (r.contains('member')) return Colors.blue.shade700;
//     return Colors.purple.shade700;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           final created = await showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             shape: const RoundedRectangleBorder(
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//             ),
//             builder: (_) => Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//               ),
//               child: const UserForm(user: null),
//             ),
//           );

//           if (created == true) refresh();
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: RefreshablePage(
//         onRefresh: refresh,
//         child: FutureBuilder<List<UserModel>>(
//           future: _usersFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: 8,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, __) => const UserCardSkeleton(),
//               );
//             }

//             if (snapshot.hasError || !snapshot.hasData) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline,
//                         size: 64, color: Colors.red.shade400),
//                     const SizedBox(height: 16),
//                     const Text("Failed to load users"),
//                     Text("${snapshot.error}",
//                         style: const TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               );
//             }

//             final users = snapshot.data!;

//             if (users.isEmpty) {
//               return const Center(
//                   child: Text("No users found",
//                       style: TextStyle(fontSize: 16, color: Colors.grey)));
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//               itemCount: users.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (_, i) {
//                 final user = users[i];
//                 final isCurrent = auth.currentUser?.id == user.id;

//                 return UserCardFinal(
//                   user: user,
//                   isCurrentUser: isCurrent,
//                   onEdit: () async {
//                     final updated = await showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.vertical(top: Radius.circular(24)),
//                       ),
//                       builder: (_) => Padding(
//                         padding: EdgeInsets.only(
//                           bottom: MediaQuery.of(context).viewInsets.bottom,
//                         ),
//                         child: UserForm(user: user),
//                       ),
//                     );

//                     if (updated == true) refresh();
//                   },
//                   formatDate: _formatDate,
//                   roleColor: _roleColor,
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ==================== USER CARD ====================
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final VoidCallback onEdit;
//   final String Function(dynamic) formatDate;
//   final Color Function(String?) roleColor;

//   const UserCardFinal({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.onEdit,
//     required this.formatDate,
//     required this.roleColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final role = (user.role ?? "user").toUpperCase();

//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 22, 16, 26),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(
//           color: isCurrentUser ? const Color(0xFFFFD700) : Colors.grey.shade200,
//           width: isCurrentUser ? 2.5 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isCurrentUser ? 0.16 : 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Avatar
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                       colors: [Color(0xFF9333EA), Color(0xFFEC4899)]),
//                 ),
//                 child: CircleAvatar(
//                   radius: 32,
//                   backgroundColor: Colors.white,
//                   child: Text(
//                     user.username.isNotEmpty
//                         ? user.username[0].toUpperCase()
//                         : "?",
//                     style: const TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6B21A8)),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user.username,
//                       style: const TextStyle(
//                           fontSize: 21, fontWeight: FontWeight.bold),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       "@${user.username.toLowerCase()}",
//                       style: TextStyle(
//                           fontSize: 14.5, color: Colors.grey.shade600),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       user.email ?? "—",
//                       style: TextStyle(
//                           fontSize: 15.5, color: Colors.grey.shade800),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),

//               IconButton(
//                 onPressed: onEdit,
//                 icon: const Icon(Icons.edit_rounded, size: 24),
//                 color: Colors.purple.shade700,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Wrap(
//             spacing: 12,
//             runSpacing: 10,
//             children: [
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                 decoration: BoxDecoration(
//                   color: roleColor(user.role).withOpacity(0.14),
//                   borderRadius: BorderRadius.circular(18),
//                   border: Border.all(color: roleColor(user.role), width: 1.4),
//                 ),
//                 child: Text(
//                   role,
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: roleColor(user.role)),
//                 ),
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: user.isActive
//                           ? Colors.green.shade600
//                           : Colors.red.shade600,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 7),
//                   Text(
//                     user.isActive ? "Active" : "Inactive",
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: user.isActive
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                     ),
//                   ),
//                 ],
//               ),
//               if (isCurrentUser)
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFFD700),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: const Text(
//                     "YOU",
//                     style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           _DetailRow(label: "Club", value: user.clubName ?? user.club ?? "—"),
//           const SizedBox(height: 8),
//           _DetailRow(label: "Member Since", value: formatDate(user.createdAt)),
//         ],
//       ),
//     );
//   }
// }

// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 110,
//           child: Text(
//             "$label:",
//             style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade700,
//                 fontSize: 15),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.07),
//               blurRadius: 20,
//               offset: const Offset(0, 8))
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 32, backgroundColor: Colors.grey),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(height: 20, width: 180, color: Colors.grey.shade300),
//                 const SizedBox(height: 8),
//                 Container(height: 16, width: 140, color: Colors.grey.shade200),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => UsersState();
// }

// class UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;
//   final Set<String> _expanded = {};

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//     });
//   }

//   String _formatDate(dynamic date) {
//     if (date == null) return '—';
//     return date.toString().split('T').first;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: FutureBuilder<List<UserModel>>(
//         future: _usersFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return ListView.builder(
//               itemCount: 8,
//               padding: const EdgeInsets.all(16),
//               itemBuilder: (_, i) => const UserCardShimmer(),
//             );
//           }

//           if (snapshot.hasError || snapshot.data == null) {
//             return const Center(child: Text("Error loading users"));
//           }

//           final users = snapshot.data!;

//           if (users.isEmpty) {
//             return const Center(child: Text("No users found"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//             itemCount: users.length,
//             itemBuilder: (_, i) => UserCard(
//               user: users[i],
//               isCurrentUser: auth.currentUser?.id == users[i].id,
//               isExpanded: _expanded.contains(users[i].id),
//               onToggle: () {
//                 setState(() {
//                   if (_expanded.contains(users[i].id)) {
//                     _expanded.remove(users[i].id);
//                   } else {
//                     _expanded.add(users[i].id!);
//                   }
//                 });
//               },
//               formatDate: _formatDate,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ──────────────────────────────────────────────
// // THIS IS THE NEW PREMIUM CARD — 100% visual impact
// // ──────────────────────────────────────────────
// class UserCard extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final bool isExpanded;
//   final VoidCallback onToggle;
//   final String Function(dynamic) formatDate;

//   const UserCard({
//     super.key,
//     required this.user,
//     required this.isCurrentUser,
//     required this.isExpanded,
//     required this.onToggle,
//     required this.formatDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOutCubic,
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (_, value, child) {
//         return Transform.scale(
//           scale: 0.94 + (value * 0.06),
//           child: Opacity(opacity: value, child: child!),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         decoration: BoxDecoration(
//           gradient: isCurrentUser
//               ? const LinearGradient(
//                   colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : LinearGradient(
//                   colors: [Colors.white, Colors.grey.shade50],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: [
//             BoxShadow(
//               color: isCurrentUser
//                   ? const Color(0xFFFFD54F).withOpacity(0.4)
//                   : Colors.black.withOpacity(0.08),
//               blurRadius: 30,
//               offset: const Offset(0, 12),
//             ),
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//           border: isCurrentUser
//               ? Border.all(color: const Color(0xFFFFD54F), width: 2)
//               : Border.all(color: Colors.transparent),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(28),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: onToggle,
//               borderRadius: BorderRadius.circular(28),
//               child: Column(
//                 children: [
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 24, 20, 20),
//                     child: Row(
//                       children: [
//                         // Avatar with ring
//                         Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF8B5CF6), Color(0xFFE040FB)],
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.deepPurple.withOpacity(0.3),
//                                 blurRadius: 12,
//                               ),
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 32,
//                             backgroundColor: Colors.white,
//                             child: Text(
//                               user.username.isNotEmpty
//                                   ? user.username[0].toUpperCase()
//                                   : "?",
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF6D28D9),
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 20),

//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       user.username,
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ),
//                                   if (isCurrentUser)
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 12, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFFFD54F),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: const Text(
//                                         "YOU",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 11,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 user.email ?? "—no email—",
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   color: Colors.grey.shade700,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         Transform.rotate(
//                           angle: isExpanded ? 3.14159 : 0,
//                           child: const Icon(
//                             Icons.keyboard_arrow_down_rounded,
//                             size: 32,
//                             color: Colors.deepPurple,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Expanded details — silky smooth
//                   AnimatedCrossFade(
//                     duration: const Duration(milliseconds: 400),
//                     crossFadeState: isExpanded
//                         ? CrossFadeState.showSecond
//                         : CrossFadeState.showFirst,
//                     firstChild: const SizedBox.shrink(),
//                     secondChild: Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
//                       decoration: BoxDecoration(
//                         color: isCurrentUser
//                             ? const Color(0xFFFFF8E1).withOpacity(0.6)
//                             : Colors.deepPurple.shade50.withOpacity(0.4),
//                         borderRadius: const BorderRadius.vertical(
//                             bottom: Radius.circular(28)),
//                       ),
//                       child: Column(
//                         children: [
//                           const Divider(height: 32, thickness: 1),
//                           _InfoRow(
//                               icon: Icons.tag,
//                               label: "ID",
//                               value: user.id ?? "—"),
//                           const SizedBox(height: 12),
//                           _InfoRow(
//                               icon: Icons.shield,
//                               label: "Role",
//                               value: user.role ?? "—"),
//                           const SizedBox(height: 12),
//                           _InfoRow(
//                               icon: Icons.calendar_today,
//                               label: "Joined",
//                               value: formatDate(user.createdAt)),
//                           if (user.club?.isNotEmpty == true) ...[
//                             const SizedBox(height: 12),
//                             _InfoRow(
//                               icon: Icons.location_city,
//                               label: "Club",
//                               value: user.club!,
//                               valueColor: Colors.deepPurple,
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color? valueColor;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     this.valueColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 20, color: Colors.deepPurple.shade400),
//         const SizedBox(width: 14),
//         Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: valueColor ?? Colors.black87,
//               fontSize: 15,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class UserCardShimmer extends StatelessWidget {
//   const UserCardShimmer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 20),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 20,
//               offset: const Offset(0, 10)),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 36, backgroundColor: Colors.grey),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(height: 20, width: 160, color: Colors.grey.shade300),
//                 const SizedBox(height: 10),
//                 Container(height: 16, width: 220, color: Colors.grey.shade200),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';

// class Users extends StatefulWidget {
//   const Users({super.key});

//   @override
//   State<Users> createState() => UsersState();
// }

// class UsersState extends State<Users> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   final AuthService auth = Get.find<AuthService>();

//   late Future<List<UserModel>> _usersFuture;
//   late Future<List<ClubModel>> _clubsFuture;
//   final Set<String> _expanded = {};

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   // Public method — called from BottomMenu via GlobalKey
//   Future<void> refresh() async {
//     setState(() {
//       _usersFuture = api.getAllUsers();
//       _clubsFuture = api.getAllClubs();
//     });
//   }
//     Widget _userCard(UserModel user) {
//     final isCurrent = auth.currentUser?.id == user.id;
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
//             // Gradient top bar
//             Container(
//               height: 6,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6)]),
//               ),
//             ),

//             // Header row (clickable)
//             InkWell(
//               onTap: () => setState(() {
//                 if (isExpanded) {
//                   _expanded.remove(user.id);
//                 } else {
//                   _expanded.add(user.id!);
//                 }
//               }),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                 child: Row(
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
//                     Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: Colors.grey[600]),
//                   ],
//                 ),
//               ),
//             ),

//             if (isExpanded)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 color: Colors.deepPurple[50],
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("User ID: ${user.id}", style: const TextStyle(fontWeight: FontWeight.w600)),
//                     const SizedBox(height: 8),
//                     Text("Role: ${user.role ?? 'Unknown'}"),
//                     const SizedBox(height: 8),
//                     Text("Created: ${user.createdAt ?? 'N/A'}"),
//                     const SizedBox(height: 8),
//                     if (user.club != null && user.club.toString().isNotEmpty)
//                       Text("Club: ${user.club}", style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500)),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: FutureBuilder<List<UserModel>>(
//         future: _usersFuture,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
//           }
//           if (snap.hasError) {
//             return Center(child: Text("Error: ${snap.error}", style: const TextStyle(color: Colors.red)));
//           }
//           final users = snap.data ?? [];
//           if (users.isEmpty) return const Center(child: Text("No users found"));

//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             itemCount: users.length,
//             itemBuilder: (_, i) => _userCard(users[i]),
//           );
//         },
//       ),
//     );
//   }
// }
