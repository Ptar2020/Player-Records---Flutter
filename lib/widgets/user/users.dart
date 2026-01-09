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

    final backgroundColor = color.withValues(alpha: isDark ? 0.25 : 0.15);
    final borderColor = color.withValues(alpha: isDark ? 0.7 : 1.0);
    final textColor = isDark ? color.withValues(alpha: 0.9) : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

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

    final role = user.role.toUpperCase();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrentUser
                ? Colors.green.shade500
                : theme.dividerColor.withValues(alpha: 0.3),
            width: isCurrentUser ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                    tooltip: "Edit User",
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email",
                          style: TextStyle(fontSize: 12, color: secondaryText)),
                      Text(
                        user.email ?? "—",
                        style: TextStyle(
                            fontSize: 14,
                            color: textColor.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone",
                          style: TextStyle(fontSize: 12, color: secondaryText)),
                      Text(
                        user.phone ?? "—",
                        style: TextStyle(
                            fontSize: 14,
                            color: textColor.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _Tag(
                    label: user.clubName ?? user.club ?? "No Club",
                    color: Colors.grey.shade600),
                _Tag(label: role, color: roleColor(user.role)),
                _Tag(
                  label: user.isActive ? "Active" : "Inactive",
                  color: user.isActive
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
                if (isCurrentUser)
                  _Tag(label: "YOU", color: Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 16),
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

class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade50;
    final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Card(
      color: bg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 28, backgroundColor: shimmer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 160,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: shimmer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: List.generate(
                3,
                (_) => Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: shimmer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  Future<void> _openAddUser() async {
    final result = await Get.bottomSheet(
      UserForm(clubs: clubs),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    if (result == true) refresh();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _openAddUser,
                  tooltip: "Add User",
                ),
              ]
            : null,
      ),
      body: RefreshablePage(
        onRefresh: refresh,
        child: FutureBuilder<List<UserModel>>(
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

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text("Error loading users",
                        style: Theme.of(context).textTheme.titleMedium),
                    Text("${snapshot.error}", textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: refresh, child: const Text("Retry")),
                  ],
                ),
              );
            }

            var users = snapshot.data ?? [];

            if (!isAdmin) {
              users = users.where((u) => u.id == currentUser?.id).toList();
            }

            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "No users found",
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/forms/user_form.dart';

// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;

//   const _Tag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final backgroundColor = color.withValues(alpha: isDark ? 0.25 : 0.15);
//     final borderColor = color.withValues(alpha: isDark ? 0.7 : 1.0);
//     final textColor = isDark ? color.withValues(alpha: 0.9) : color;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         border: Border.all(color: borderColor),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: textColor,
//         ),
//       ),
//     );
//   }
// }

// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final bool canEdit;
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
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color ??
//         (isDark ? Colors.white : Colors.black87);
//     final secondaryText = theme.textTheme.bodyMedium?.color ??
//         (isDark ? Colors.white70 : Colors.grey.shade600);

//     final role = user.role.toUpperCase();

//     return Card(
//       color: theme.cardColor,
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isCurrentUser
//                 ? const Color.fromARGB(209, 75, 233, 13)
//                 : theme.dividerColor.withValues(alpha: 0.3),
//             width: isCurrentUser ? 2.5 : 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.name,
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: textColor),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         "@${user.username.toLowerCase()}",
//                         style: TextStyle(fontSize: 14, color: secondaryText),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (canEdit)
//                   IconButton(
//                     onPressed: onEdit,
//                     icon: const Icon(Icons.edit_rounded),
//                     color: Colors.deepPurple.shade600,
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     user.email ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withValues(alpha: 0.8)),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     user.phone ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withValues(alpha: 0.8)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 _Tag(
//                     label: user.clubName ?? user.club ?? "—",
//                     color: Colors.grey.shade600),
//                 _Tag(label: role, color: roleColor(user.role)),
//                 _Tag(
//                   label: user.isActive ? "Active" : "Inactive",
//                   color: user.isActive
//                       ? Colors.green.shade600
//                       : Colors.red.shade600,
//                 ),
//                 if (isCurrentUser)
//                   _Tag(label: "YOU", color: Colors.amber.shade700),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Member Since: ${formatDate(user.createdAt)}",
//               style: TextStyle(fontSize: 13, color: secondaryText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
//     final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

//     return Card(
//       color: bg,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(radius: 24, backgroundColor: shimmer),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 18, width: 140, color: shimmer),
//                       ),
//                       const SizedBox(height: 8),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 14, width: 100, color: shimmer),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(child: Container(height: 12, color: shimmer)),
//                 const SizedBox(width: 16),
//                 Expanded(child: Container(height: 12, color: shimmer)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               children: List.generate(
//                 3,
//                 (_) => ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(width: 70, height: 24, color: shimmer),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

//   Future<void> _openAddUser() async {
//     final result = await Get.bottomSheet(
//       UserForm(clubs: clubs),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );
//     if (result == true) refresh();
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
//     if (r.contains('scout')) return Colors.purple.shade600;
//     if (r.contains('player')) return Colors.blue.shade600;
//     return Colors.grey.shade600;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     final currentUser = auth.currentUser;
//     final isAdmin = currentUser?.role.toLowerCase() == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Users"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         actions: isAdmin
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: _openAddUser,
//                   tooltip: "Add User",
//                 ),
//               ]
//             : null,
//       ),
//       body: RefreshablePage(
//         onRefresh: refresh,
//         child: FutureBuilder<List<UserModel>>(
//           future: _usersFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: 6,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, __) => const UserCardSkeleton(),
//               );
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text("Error: ${snapshot.error}"));
//             }

//             var users = snapshot.data ?? [];

//             if (!isAdmin) {
//               users = users.where((u) => u.id == currentUser?.id).toList();
//             }

//             if (users.isEmpty) {
//               return Center(
//                 child: Text("No users found",
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Theme.of(context).textTheme.bodyMedium?.color)),
//               );
//             }

//             return ListView.separated(
//               padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
//               itemCount: users.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (_, i) {
//                 final user = users[i];
//                 final isCurrent = currentUser?.id == user.id;
//                 final canEdit = isAdmin || isCurrent;

//                 return UserCardFinal(
//                   user: user,
//                   isCurrentUser: isCurrent,
//                   canEdit: canEdit,
//                   onEdit: () async {
//                     final result = await Get.bottomSheet(
//                       UserForm(user: user, clubs: clubs),
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
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/forms/user_form.dart';

// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;

//   const _Tag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.25 : 0.15),
//         border: Border.all(color: color.withOpacity(isDark ? 0.7 : 1.0)),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: isDark ? color.withOpacity(0.9) : color,
//         ),
//       ),
//     );
//   }
// }

// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final bool canEdit;
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
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color ??
//         (isDark ? Colors.white : Colors.black87);
//     final secondaryText = theme.textTheme.bodyMedium?.color ??
//         (isDark ? Colors.white70 : Colors.grey.shade600);

//     final role = (user.role).toUpperCase();

//     return Card(
//       color: theme.cardColor,
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isCurrentUser
//                 ? Colors.amber.shade600
//                 : theme.dividerColor.withOpacity(0.3),
//             width: isCurrentUser ? 2.5 : 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.name,
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: textColor),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         "@${user.username.toLowerCase()}",
//                         style: TextStyle(fontSize: 14, color: secondaryText),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (canEdit)
//                   IconButton(
//                     onPressed: onEdit,
//                     icon: const Icon(Icons.edit_rounded),
//                     color: Colors.deepPurple.shade600,
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     user.email ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withOpacity(0.8)),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     user.phone ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withOpacity(0.8)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 _Tag(
//                     label: user.clubName ?? user.club ?? "—",
//                     color: Colors.grey.shade600),
//                 _Tag(label: role, color: roleColor(user.role)),
//                 _Tag(
//                   label: user.isActive ? "Active" : "Inactive",
//                   color: user.isActive
//                       ? Colors.green.shade600
//                       : Colors.red.shade600,
//                 ),
//                 if (isCurrentUser)
//                   _Tag(label: "YOU", color: Colors.amber.shade700),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "Member Since: ${formatDate(user.createdAt)}",
//               style: TextStyle(fontSize: 13, color: secondaryText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
//     final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

//     return Card(
//       color: bg,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(radius: 24, backgroundColor: shimmer),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 18, width: 140, color: shimmer),
//                       ),
//                       const SizedBox(height: 8),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 14, width: 100, color: shimmer),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(child: Container(height: 12, color: shimmer)),
//                 const SizedBox(width: 16),
//                 Expanded(child: Container(height: 12, color: shimmer)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               children: List.generate(
//                 3,
//                 (_) => ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(width: 70, height: 24, color: shimmer),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

//   Future<void> _openAddUser() async {
//     final result = await Get.bottomSheet(
//       UserForm(clubs: clubs),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );
//     if (result == true) refresh();
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
//     if (r.contains('scout')) return Colors.purple.shade600;
//     if (r.contains('player')) return Colors.blue.shade600;
//     return Colors.grey.shade600;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     final currentUser = auth.currentUser;
//     final isAdmin = currentUser?.role.toLowerCase() == 'admin';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Users"),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         actions: isAdmin
//             ? [
//                 IconButton(
//                   icon: const Icon(Icons.add),
//                   onPressed: _openAddUser,
//                   tooltip: "Add User",
//                 ),
//               ]
//             : null,
//       ),
//       body: RefreshablePage(
//         onRefresh: refresh,
//         child: FutureBuilder<List<UserModel>>(
//           future: _usersFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return ListView.separated(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: 6,
//                 separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 itemBuilder: (_, __) => const UserCardSkeleton(),
//               );
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text("Error: ${snapshot.error}"));
//             }

//             var users = snapshot.data ?? [];

//             if (!isAdmin) {
//               users = users.where((u) => u.id == currentUser?.id).toList();
//             }

//             if (users.isEmpty) {
//               return Center(
//                 child: Text("No users found",
//                     style: TextStyle(
//                         fontSize: 16,
//                         color: Theme.of(context).textTheme.bodyMedium?.color)),
//               );
//             }

//             return ListView.separated(
//               padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
//               itemCount: users.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (_, i) {
//                 final user = users[i];
//                 final isCurrent = currentUser?.id == user.id;
//                 final canEdit = isAdmin || isCurrent;

//                 return UserCardFinal(
//                   user: user,
//                   isCurrentUser: isCurrent,
//                   canEdit: canEdit,
//                   onEdit: () async {
//                     final result = await Get.bottomSheet(
//                       UserForm(user: user, clubs: clubs),
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
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/user_model.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/forms/user_form.dart';

// class _Tag extends StatelessWidget {
//   final String label;
//   final Color color;

//   const _Tag({required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(isDark ? 0.25 : 0.15),
//         border: Border.all(color: color.withOpacity(isDark ? 0.7 : 1.0)),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: isDark ? color.withOpacity(0.9) : color,
//         ),
//       ),
//     );
//   }
// }

// /// ---------------- USER CARD (PERFECT & ERROR-FREE) ----------------
// class UserCardFinal extends StatelessWidget {
//   final UserModel user;
//   final bool isCurrentUser;
//   final bool canEdit;
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
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final textColor = theme.textTheme.bodyLarge?.color ??
//         (isDark ? Colors.white : Colors.black87);
//     final secondaryText = theme.textTheme.bodyMedium?.color ??
//         (isDark ? Colors.white70 : Colors.grey.shade600);

//     final role = (user.role).toUpperCase();

//     return Card(
//       color: theme.cardColor,
//       elevation: 8,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           border: Border.all(
//             color: isCurrentUser
//                 ? Colors.amber.shade600
//                 : theme.dividerColor.withOpacity(0.3),
//             width: isCurrentUser ? 2.5 : 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Name + Username + Edit
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         user.name,
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: textColor),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         "@${user.username.toLowerCase()}",
//                         style: TextStyle(fontSize: 14, color: secondaryText),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (canEdit)
//                   IconButton(
//                     onPressed: onEdit,
//                     icon: const Icon(Icons.edit_rounded),
//                     color: Colors.deepPurple.shade600,
//                   ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Email + Phone
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     user.email ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withOpacity(0.8)),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     user.phone ?? "—",
//                     style: TextStyle(
//                         fontSize: 14, color: textColor.withOpacity(0.8)),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Tags
//             Wrap(
//               spacing: 8,
//               runSpacing: 6,
//               children: [
//                 _Tag(
//                     label: user.clubName ?? user.club ?? "—",
//                     color: Colors.grey.shade600),
//                 _Tag(label: role, color: roleColor(user.role)),
//                 _Tag(
//                   label: user.isActive ? "Active" : "Inactive",
//                   color: user.isActive
//                       ? Colors.green.shade600
//                       : Colors.red.shade600,
//                 ),
//                 if (isCurrentUser)
//                   _Tag(label: "YOU", color: Colors.amber.shade700),
//               ],
//             ),
//             const SizedBox(height: 12),

//             // Member Since
//             Text(
//               "Member Since: ${formatDate(user.createdAt)}",
//               style: TextStyle(fontSize: 13, color: secondaryText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ---------------- SKELETON ----------------
// class UserCardSkeleton extends StatelessWidget {
//   const UserCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
//     final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

//     return Card(
//       color: bg,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(radius: 24, backgroundColor: shimmer),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 18, width: 140, color: shimmer),
//                       ),
//                       const SizedBox(height: 8),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child:
//                             Container(height: 14, width: 100, color: shimmer),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(child: Container(height: 12, color: shimmer)),
//                 const SizedBox(width: 16),
//                 Expanded(child: Container(height: 12, color: shimmer)),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Wrap(
//               spacing: 8,
//               children: List.generate(
//                 3,
//                 (_) => ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Container(width: 70, height: 24, color: shimmer),
//                 ),
//               ),
//             ),
//           ],
//         ),
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
//     if (r.contains('scout')) return Colors.purple.shade600;
//     if (r.contains('player')) return Colors.blue.shade600;
//     return Colors.grey.shade600;
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     final currentUser = auth.currentUser;
//     final isAdmin = currentUser?.role.toLowerCase() == 'admin';

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

//               if (snapshot.hasError) {
//                 return Center(
//                   child: Text("Error: ${snapshot.error}"),
//                 );
//               }

//               var users = snapshot.data ?? [];

//               if (!isAdmin) {
//                 users = users.where((u) => u.id == currentUser?.id).toList();
//               }

//               if (users.isEmpty) {
//                 return Center(
//                   child: Text("No users found",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color:
//                               Theme.of(context).textTheme.bodyMedium?.color)),
//                 );
//               }

//               return ListView.separated(
//                 padding: EdgeInsets.fromLTRB(16, 16, 16, isAdmin ? 100 : 32),
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
//           if (isAdmin)
//             Positioned(
//               bottom: 24,
//               right: 24,
//               child: FloatingActionButton.extended(
//                 backgroundColor: Colors.deepPurple,
//                 onPressed: () async {
//                   final result = await Get.bottomSheet(
//                     UserForm(clubs: clubs),
//                     isScrollControlled: true,
//                     backgroundColor: Colors.transparent,
//                   );
//                   if (result == true) refresh();
//                 },
//                 icon: const Icon(Icons.person_add),
//                 label: const Text("Add User"),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
