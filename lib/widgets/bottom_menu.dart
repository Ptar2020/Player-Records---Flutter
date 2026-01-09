import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/forms/club_form.dart';
import 'package:precords_android/forms/player_form.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/services/theme_service.dart';
import 'package:precords_android/widgets/club/clubs.dart';
import 'package:precords_android/widgets/player/all_players.dart';
import 'package:precords_android/settings/settings.dart';
import 'package:precords_android/widgets/user/auth/login.dart';

// Global keys for refreshing from outside
final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int selectedIndex = 0;
  final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

  bool _isLoggingOut = false;

  void _openAddPlayerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
    ).then((result) {
      if (result == true) {
        allPlayersKey.currentState?.loadPlayers();
      }
    });
  }

  void _openLoginModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const Login(),
    ).then((_) => setState(() {}));
  }

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    final auth = Get.find<AuthService>();

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Sure to log out?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) {
      _isLoggingOut = false;
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final success = await auth.logout();

    if (Get.isDialogOpen ?? false) Get.back();

    if (success) {
      Get.snackbar(
        "Logged Out",
        "Logged out successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      if (mounted) {
        setState(() {
          selectedIndex = 0;
        });
      }
    } else {
      Get.snackbar(
        "Error",
        auth.errorMessage ?? "Failed to log out",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    _isLoggingOut = false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final themeService = Get.find<ThemeService>();
    final isLoggedIn = auth.isLoggedIn.value;

    final List<({Widget page, String title, List<Widget> actions})> pages = [
      (
        page: AllPlayers(key: allPlayersKey),
        title: "PLAYERS",
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _openAddPlayerModal,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => allPlayersKey.currentState?.handleMenuAction(value),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'refresh', child: Row(children: [Icon(Icons.refresh), SizedBox(width: 12), Text("Refresh")])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'sort_name_asc', child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 12), Text("Name A-Z")])),
              const PopupMenuItem(value: 'sort_name_desc', child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 12), Text("Name Z-A")])),
            ],
          ),
        ]
      ),
      if (isLoggedIn)
        (
          page: Clubs(key: clubsGlobalKey),
          title: "CLUBS",
          actions: [
            Obx(() {
              final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
              return isAdmin
                  ? IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 28),
                      onPressed: () {
                        Get.bottomSheet(
                          const ClubForm(mode: ClubFormMode.create),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                        ).then((result) {
                          if (result == true || result is ClubModel) {
                            clubsGlobalKey.currentState?.refresh();
                          }
                        });
                      },
                      tooltip: "Add Club",
                    )
                  : const SizedBox.shrink();
            }),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) => clubsGlobalKey.currentState?.handleMenuAction(value),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(children: [Icon(Icons.refresh), SizedBox(width: 12), Text("Refresh")]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'sort_name_asc',
                  child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 12), Text("Name A-Z")]),
                ),
                const PopupMenuItem(
                  value: 'sort_name_desc',
                  child: Row(children: [Icon(Icons.sort_by_alpha), SizedBox(width: 12), Text("Name Z-A")]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'sort_players_desc',
                  child: Row(children: [Icon(Icons.group), SizedBox(width: 12), Text("Most Players First")]),
                ),
                const PopupMenuItem(
                  value: 'sort_players_asc',
                  child: Row(children: [Icon(Icons.group_outlined), SizedBox(width: 12), Text("Fewest Players First")]),
                ),
              ],
            ),
          ]
        ),
      (
        page: const Settings(),
        title: "SETTINGS",
        actions: const [],
      ),
    ];

    if (selectedIndex >= pages.length) {
      selectedIndex = 0;
    }

    final current = pages[selectedIndex];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
      if (isLoggedIn) const BottomNavigationBarItem(icon: Icon(Icons.group), label: "Clubs"),
      const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      BottomNavigationBarItem(
        icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
        label: isLoggedIn ? "Logout" : "Login",
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: IconButton(
                  key: ValueKey(themeService.isDarkMode.value),
                  icon: Icon(themeService.themeIcon, size: 28, color: Colors.white),
                  onPressed: () => themeService.switchTheme(),
                  tooltip: themeService.isDarkMode.value ? "Light Mode" : "Dark Mode",
                ),
              )),
        ),
        title: Text(
          current.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        actions: current.actions,
      ),
      body: current.page,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          currentIndex: selectedIndex,
          onTap: (i) {
            if (i == navItems.length - 1) {
              if (isLoggedIn) {
                _handleLogout();
              } else {
                _openLoginModal();
              }
              return;
            }
            setState(() => selectedIndex = i);
          },
          items: navItems,
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/positions/positions.dart';
// import 'package:precords_android/settings/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/forms/club_form.dart';
// import 'package:precords_android/forms/position_form.dart';

// // Global keys
// final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();
// final GlobalKey<PositionsState> positionsGlobalKey =
//     GlobalKey<PositionsState>(); 

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   late final GlobalKey<ClubsState> clubsGlobalKey = clubsGlobalKey;

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openAddPositionModal() {
//     Get.bottomSheet(
//       const PositionForm(mode: PositionFormMode.create),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     ).then((result) {
//       if (result == true) {
//         positionsGlobalKey.currentState?.loadPositions();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'refresh',
//                 child: Row(children: [
//                   Icon(Icons.refresh),
//                   SizedBox(width: 12),
//                   Text("Refresh")
//                 ]),
//               ),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'sort_name_asc',
//                 child: Row(children: [
//                   Icon(Icons.sort_by_alpha),
//                   SizedBox(width: 12),
//                   Text("Name A-Z")
//                 ]),
//               ),
//               const PopupMenuItem(
//                 value: 'sort_name_desc',
//                 child: Row(children: [
//                   Icon(Icons.sort_by_alpha),
//                   SizedBox(width: 12),
//                   Text("Name Z-A")
//                 ]),
//               ),
//             ],
//           ),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => const [
//                 PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//               ],
//             ),
//           ]
//         ),
//       (
//         page: Clubs(key: clubsGlobalKey),
//         title: "CLUBS",
//         actions: [
//           Obx(() {
//             final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
//             return isAdmin
//                 ? IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                     onPressed: () {
//                       Get.bottomSheet(
//                         const ClubForm(mode: ClubFormMode.create),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(30)),
//                         ),
//                       ).then((result) {
//                         if (result == true || result is ClubModel) {
//                           clubsGlobalKey.currentState?.refresh();
//                         }
//                       });
//                     },
//                     tooltip: "Add Club",
//                   )
//                 : const SizedBox.shrink();
//           }),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 clubsGlobalKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'refresh',
//                 child: Row(children: [
//                   Icon(Icons.refresh),
//                   SizedBox(width: 12),
//                   Text("Refresh")
//                 ]),
//               ),
//               // Keep your existing club sort options here
//             ],
//           ),
//         ]
//       ),
//       (
//         page: Positions(key: positionsGlobalKey),
//         title: "POSITIONS",
//         actions: [
//           Obx(() {
//             final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
//             return isAdmin
//                 ? IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                     onPressed: _openAddPositionModal,
//                     tooltip: "Add Position",
//                   )
//                 : const SizedBox.shrink();
//           }),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 positionsGlobalKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'refresh',
//                 child: Row(children: [
//                   Icon(Icons.refresh),
//                   SizedBox(width: 12),
//                   Text("Refresh")
//                 ]),
//               ),
//             ],
//           ),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {},
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//             ],
//           ),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.sports_soccer), label: "Positions"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//         icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//         label: isLoggedIn ? "Logout" : "Login",
//       ),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(bottomRight: Radius.circular(40)),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(themeService.themeIcon,
//                       size: 28, color: Colors.white),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(current.title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(topLeft: Radius.circular(40)),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/positions/positions.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/settings/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/forms/club_form.dart';

// // Global key for refreshing Clubs list from anywhere
// final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   late final GlobalKey<ClubsState> clubsGlobalKey = clubsGlobalKey;

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'refresh',
//                 child: Row(
//                   children: [
//                     Icon(Icons.refresh),
//                     SizedBox(width: 12),
//                     Text("Refresh"),
//                   ],
//                 ),
//               ),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'sort_name_asc',
//                 child: Row(
//                   children: [
//                     Icon(Icons.sort_by_alpha),
//                     SizedBox(width: 12),
//                     Text("Name A-Z"),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'sort_name_desc',
//                 child: Row(
//                   children: [
//                     Icon(Icons.sort_by_alpha),
//                     SizedBox(width: 12),
//                     Text("Name Z-A"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => const [
//                 PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//               ],
//             ),
        //   ]
        // ),
      // (
      //   page: Clubs(key: clubsGlobalKey),
      //   title: "CLUBS",
      //   actions: [
      //     Obx(() {
      //       final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
      //       return isAdmin
      //           ? IconButton(
      //               icon: const Icon(Icons.add, color: Colors.white, size: 28),
      //               onPressed: () {
      //                 Get.bottomSheet(
      //                   const ClubForm(mode: ClubFormMode.create),
      //                   isScrollControlled: true,
      //                   backgroundColor: Colors.transparent,
      //                   shape: const RoundedRectangleBorder(
      //                     borderRadius:
      //                         BorderRadius.vertical(top: Radius.circular(30)),
      //                   ),
      //                 ).then((result) {
      //                   if (result == true || result is ClubModel) {
      //                     clubsGlobalKey.currentState?.refresh();
      //                   }
      //                 });
      //               },
      //               tooltip: "Add Club",
      //             )
      //           : const SizedBox.shrink();
      //     }),
      //     PopupMenuButton<String>(
      //       icon: const Icon(Icons.more_vert, color: Colors.white),
      //       onSelected: (value) =>
      //           clubsGlobalKey.currentState?.handleMenuAction(value),
      //       itemBuilder: (_) => [
      //         const PopupMenuItem(
      //           value: 'refresh',
      //           child: Row(
      //             children: [
      //               Icon(Icons.refresh),
      //               SizedBox(width: 12),
      //               Text("Refresh"),
      //             ],
      //           ),
      //         ),
      //         const PopupMenuDivider(),
      //         const PopupMenuItem(
      //           value: 'sort_name_asc',
      //           child: Row(
      //             children: [
      //               Icon(Icons.sort_by_alpha),
      //               SizedBox(width: 12),
      //               Text("Name A-Z"),
      //             ],
      //           ),
      //         ),
      //         const PopupMenuItem(
      //           value: 'sort_name_desc',
      //           child: Row(
      //             children: [
      //               Icon(Icons.sort_by_alpha),
      //               SizedBox(width: 12),
      //               Text("Name Z-A"),
      //             ],
      //           ),
      //         ),
      //         const PopupMenuDivider(),
      //         const PopupMenuItem(
      //           value: 'sort_players_desc',
      //           child: Row(
      //             children: [
      //               Icon(Icons.group),
      //               SizedBox(width: 12),
      //               Text("Most Players First"),
      //             ],
      //           ),
      //         ),
      //         const PopupMenuItem(
      //           value: 'sort_players_asc',
      //           child: Row(
      //             children: [
      //               Icon(Icons.group_outlined),
      //               SizedBox(width: 12),
      //               Text("Fewest Players First"),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ]
      // ),
//       (
//         page: const Positions(),
//         title: "POSITIONS",
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {},
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//             ],
//           ),
//           const PopupMenuItem(
//             child: Row(
//               children: [
//                 Icon(Icons.sort_by_alpha),
//                 SizedBox(width: 12),
//                 Text("Add position"),
//               ],
//             ),
//           ),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {},
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//             ],
//           ),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Positions"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//           icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//           label: isLoggedIn ? "Logout" : "Login"),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(
//                     themeService.themeIcon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(
//           current.title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(0),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }
















// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/settings/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/forms/club_form.dart';

// // Global key for refreshing Clubs list from anywhere
// final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   late final GlobalKey<ClubsState> clubsGlobalKey = clubsGlobalKey;

//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   allPlayersKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onSelected: (value) {},
//                 itemBuilder: (_) => menuActions),
//           ]
//         ),
//       (
//         page: Clubs(key: clubsGlobalKey),
//         title: "CLUBS",
//         actions: [
//           Obx(() {
//             final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
//             return isAdmin
//                 ? IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                     onPressed: () {
//                       Get.bottomSheet(
//                         const ClubForm(mode: ClubFormMode.create),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(30)),
//                         ),
//                       ).then((result) {
//                         if (result == true || result is ClubModel) {
//                           clubsGlobalKey.currentState?.refresh();
//                         }
//                       });
//                     },
//                     tooltip: "Add Club",
//                   )
//                 : const SizedBox.shrink();
//           }),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   clubsGlobalKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//           icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//           label: isLoggedIn ? "Logout" : "Login"),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(
//                     themeService.themeIcon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(
//           current.title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(0),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/forms/club_form.dart';

// // Global key for refreshing Clubs list from anywhere
// final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   late final GlobalKey<ClubsState> clubsGlobalKey = clubsGlobalKey;

//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   allPlayersKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onSelected: (value) {},
//                 itemBuilder: (_) => menuActions),
//           ]
//         ),
//       (
//         page: Clubs(key: clubsGlobalKey),
//         title: "CLUBS",
//         actions: [
//           Obx(() {
//             final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
//             return isAdmin
//                 ? IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                     onPressed: () {
//                       Get.bottomSheet(
//                         const ClubForm(mode: ClubFormMode.create),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(30)),
//                         ),
//                       ).then((result) {
//                         if (result == true || result is ClubModel) {
//                           clubsGlobalKey.currentState?.refresh();
//                         }
//                       });
//                     },
//                     tooltip: "Add Club",
//                   )
//                 : const SizedBox.shrink();
//           }),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   clubsGlobalKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//           icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//           label: isLoggedIn ? "Logout" : "Login"),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(
//                     themeService.themeIcon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(
//           current.title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(0),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:precords_android/models/club_model.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/forms/club_form.dart';

// // Global key for refreshing Clubs list from anywhere
// final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   late final GlobalKey<ClubsState> clubsGlobalKey = clubsGlobalKey;

//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   allPlayersKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onSelected: (value) {},
//                 itemBuilder: (_) => menuActions),
//           ]
//         ),
//       (
//         page: Clubs(key: clubsGlobalKey),
//         title: "CLUBS",
//         actions: [
//           Obx(() {
//             final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
//             return isAdmin
//                 ? IconButton(
//                     icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                     onPressed: () {
//                       Get.bottomSheet(
//                         const ClubForm(mode: ClubFormMode.create),
//                         isScrollControlled: true,
//                         backgroundColor: Colors.transparent,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(30)),
//                         ),
//                       ).then((result) {
//                         if (result == true || result is ClubModel) {
//                           clubsGlobalKey.currentState?.refresh();
//                         }
//                       });
//                     },
//                     tooltip: "Add Club",
//                   )
//                 : const SizedBox.shrink();
//           }),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   clubsGlobalKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//           icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//           label: isLoggedIn ? "Logout" : "Login"),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(
//                     themeService.themeIcon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(
//           current.title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(0),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import '../forms/player_form.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   final GlobalKey<ClubsState> clubsGlobalKey = GlobalKey<ClubsState>();

//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

// void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//       ),
//       builder: (_) => const PlayerForm(mode: PlayerFormMode.create),
//     ).then((result) {
//       if (result == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();
//               if (selectedIndex == 1) selectedIndex = 0;
//               setState(() {});
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;
//     final themeService = Get.find<ThemeService>();

//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.add, color: Colors.white, size: 28),
//               onPressed: _openAddPlayerModal),
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   allPlayersKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       if (isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: [
//             PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert, color: Colors.white),
//                 onSelected: (value) {},
//                 itemBuilder: (_) => menuActions),
//           ]
//         ),
//       (
//         page: Clubs(key: clubsGlobalKey),
//         title: "CLUBS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   clubsGlobalKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
//               itemBuilder: (_) => menuActions),
//         ]
//       ),
//     ];

//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         BottomNavigationBarItem(
//             icon: Icon(Icons.group), label: user?.username ?? "Users"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.location_city), label: "Clubs"),
//       const BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(
//           icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//           label: isLoggedIn ? "Logout" : "Login"),
//     ];

//     return Scaffold(
//       extendBody: true,
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(0),
//             bottomRight: Radius.circular(40),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 12),
//           child: Obx(() => AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, animation) =>
//                     ScaleTransition(scale: animation, child: child),
//                 child: IconButton(
//                   key: ValueKey(themeService.isDarkMode.value),
//                   icon: Icon(
//                     themeService.themeIcon,
//                     size: 28,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => themeService.switchTheme(),
//                   tooltip: themeService.isDarkMode.value
//                       ? "Switch to Light Mode"
//                       : "Switch to Dark Mode",
//                 ),
//               )),
//         ),
//         title: Text(
//           current.title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(40),
//             topRight: Radius.circular(0),
//           ),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
//           ],
//         ),
//         child: BottomNavigationBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white60,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           currentIndex: selectedIndex,
//           onTap: (i) {
//             if (i == navItems.length - 1) {
//               isLoggedIn ? _logoutUser() : _openLoginModal();
//               return;
//             }
//             setState(() => selectedIndex = i);
//           },
//           items: navItems,
//         ),
//       ),
//     );
//   }
// }

