import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/widgets/player/add_player.dart';
import 'package:precords_android/widgets/player/all_players.dart';
import 'package:precords_android/widgets/user/users.dart';
import 'package:precords_android/widgets/club/clubs.dart';
import 'package:precords_android/widgets/settings.dart';
import 'package:precords_android/widgets/user/auth/login.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/services/theme_service.dart'; // Add this import

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int selectedIndex = 0;
  final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
  final GlobalKey<ClubsState> clubsKey = GlobalKey<ClubsState>();

  List<PopupMenuEntry<String>> get menuActions => const [
        PopupMenuItem(value: "refresh", child: Text("Refresh")),
        PopupMenuItem(value: "sort", child: Text("Sort")),
        PopupMenuItem(value: "filter", child: Text("Filter")),
      ];

  void _openAddPlayerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPlayerScreen(),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) allPlayersKey.currentState?.loadPlayers();
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

  void _logoutUser() {
    final auth = Get.find<AuthService>();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Logout"),
        content: const Text("Sure to log out?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              auth.logout();
              Get.back();
              if (selectedIndex == 1) selectedIndex = 0;
              setState(() {});
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthService>();
    final user = auth.currentUser;
    final isLoggedIn = auth.isLoggedIn.value;
    final themeService = Get.find<ThemeService>(); // Get the service

    final List<({Widget page, String title, List<Widget> actions})> pages = [
      (
        page: AllPlayers(key: allPlayersKey),
        title: "ALL PLAYERS",
        actions: [
          IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 28),
              onPressed: _openAddPlayerModal),
          PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) =>
                  allPlayersKey.currentState?.handleMenuAction(value),
              itemBuilder: (_) => menuActions),
        ]
      ),
      if (isLoggedIn)
        (
          page: const Users(),
          title: user?.username.toUpperCase() ?? "USERS",
          actions: [
            PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {},
                itemBuilder: (_) => menuActions),
          ]
        ),
      (
        page: Clubs(key: clubsKey),
        title: "CLUBS",
        actions: [
          PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) =>
                  clubsKey.currentState?.handleMenuAction(value),
              itemBuilder: (_) => menuActions),
        ]
      ),
      (
        page: const Settings(),
        title: "SETTINGS",
        actions: [
          PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {},
              itemBuilder: (_) => menuActions),
        ]
      ),
    ];

    if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
    final current = pages[selectedIndex];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
      if (isLoggedIn)
        BottomNavigationBarItem(
            icon: Icon(Icons.group), label: user?.username ?? "Users"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.location_city), label: "Clubs"),
      const BottomNavigationBarItem(
          icon: Icon(Icons.settings), label: "Settings"),
      BottomNavigationBarItem(
          icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
          label: isLoggedIn ? "Logout" : "Login"),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(40),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: IconButton(
                  key: ValueKey(themeService.isDarkMode.value),
                  icon: Icon(
                    themeService.themeIcon,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () => themeService.switchTheme(),
                  tooltip: themeService.isDarkMode.value
                      ? "Switch to Light Mode"
                      : "Switch to Dark Mode",
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
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 20, offset: Offset(0, -5)),
          ],
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
              isLoggedIn ? _logoutUser() : _openLoginModal();
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

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

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
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) allPlayersKey.currentState?.loadPlayers();
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
//         page: const Clubs(),
//         title: "CLUBS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
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
//         title: Text(current.title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 24)),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: current.actions,
//         // ONLY THIS LINE ADDED — exact mirror of your bottom bar
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(40),
//             bottomRight: Radius.circular(0),
//           ),
//         ),
//       ),
//       body: current.page,
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(0), topRight: Radius.circular(40)),
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

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

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
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) allPlayersKey.currentState?.loadPlayers();
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
//         content: const Text("Are you sure you want to log out?"),
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
//         page: const Clubs(),
//         title: "CLUBS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
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
//         const BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
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
//         title: Text(current.title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 24)),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: current.actions,
//       ),
//       body: current.page,
//       // Same imports and class structure...

//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(60), topRight: Radius.circular(60)),
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












// import 'dart:ui'; // For blur
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

//   // Shared menu actions
//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

//   // Add Player Modal
//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) allPlayersKey.currentState?.loadPlayers();
//     });
//   }

//   // Login Modal
//   void _openLoginModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const Login(),
//     ).then((_) => setState(() {}));
//   }

//   // Logout
//   void _logoutUser() {
//     final auth = Get.find<AuthService>();
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
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

//     // Pages List
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
//         page: const Clubs(),
//         title: "CLUBS",
//         actions: [
//           PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {},
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

//     // Ensure selectedIndex is valid
//     if (selectedIndex >= pages.length) selectedIndex = pages.length - 1;
//     final current = pages[selectedIndex];

//     // Nav Items List
//     final List<BottomNavigationBarItem> navItems = [
//       const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//       if (isLoggedIn)
//         const BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
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
//         title: Text(current.title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 24)),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.deepPurple,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.white.withOpacity(0.2)),
//               ),
//               child: BottomNavigationBar(
//                 backgroundColor: Colors.deepPurple,
//                 elevation: 0,
//                 type: BottomNavigationBarType.fixed,
//                 selectedItemColor: Colors.white,
//                 unselectedItemColor: Colors.grey,
//                 currentIndex: selectedIndex,
//                 onTap: (i) {
//                   // Login/Logout Button Handling
//                   if (i == navItems.length - 1) {
//                     isLoggedIn ? _logoutUser() : _openLoginModal();
//                     return;
//                   }
//                   setState(() => selectedIndex = i);
//                 },
//                 items: navItems,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/services/auth_service.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;

//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

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
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) {
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
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               auth.logout();
//               Get.back();

//               selectedIndex = 0;
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

//     // ------------------- BUILD TABS DYNAMICALLY -------------------
//     final List<({Widget page, String title, List<Widget> actions})> pages = [];

//     // PLAYERS TAB
//     pages.add((
//       page: AllPlayers(key: allPlayersKey),
//       title: "ALL PLAYERS",
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.add, color: Colors.white),
//           onPressed: _openAddPlayerModal,
//         ),
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (value) =>
//               allPlayersKey.currentState?.handleMenuAction(value),
//           itemBuilder: (_) => menuActions,
//         ),
//       ]
//     ));

//     // USERS TAB (only when logged in)
//     if (isLoggedIn) {
//       pages.add((
//         page: const Users(),
//         title: user?.username.toUpperCase() ?? "USER",
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (_) {},
//             itemBuilder: (_) => menuActions,
//           ),
//         ]
//       ));
//     }

//     // CLUBS TAB
//     pages.add((
//       page: const Clubs(),
//       title: "CLUBS",
//       actions: [
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (_) {},
//           itemBuilder: (_) => menuActions,
//         ),
//       ]
//     ));

//     // SETTINGS TAB
//     pages.add((
//       page: const Settings(),
//       title: "SETTINGS",
//       actions: [
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (_) {},
//           itemBuilder: (_) => menuActions,
//         ),
//       ]
//     ));

//     // Fix wrong index after logout
//     if (selectedIndex >= pages.length) {
//       selectedIndex = 0;
//     }

//     final current = pages[selectedIndex];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           current.title,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (i) {
//           final lastIndexIsLogin = i == pages.length;

//           if (lastIndexIsLogin) {
//             if (isLoggedIn) {
//               _logoutUser();
//             } else {
//               _openLoginModal();
//             }
//             return;
//           }

//           setState(() => selectedIndex = i);
//         },
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.deepPurple,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: "Players",
//           ),

//           if (isLoggedIn)
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.group),
//               label: user?.username ?? "User",
//             ),

//           const BottomNavigationBarItem(
//             icon: Icon(Icons.location_city),
//             label: "Clubs",
//           ),

//           const BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Settings",
//           ),

//           // LOGIN / LOGOUT BUTTON at bottom bar
//           BottomNavigationBarItem(
//             icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//             label: isLoggedIn ? "Logout" : "Login",
//           ),
//         ],
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import "package:precords_android/services/auth_service.dart";

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;

//   // Refresh key for players page
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

//   // --- Shared Actions Menu ---
//   List<PopupMenuEntry<String>> get menuActions => const [
//         PopupMenuItem(value: "refresh", child: Text("Refresh")),
//         PopupMenuItem(value: "sort", child: Text("Sort")),
//         PopupMenuItem(value: "filter", child: Text("Filter")),
//       ];

//   // --- Add Player Modal ---
//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;

//     // ---------- PAGES ----------
//     List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white, size: 28),
//             onPressed: _openAddPlayerModal,
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => menuActions,
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
//               onSelected: (value) {
//                 // USERS tab does not refresh PLAYERS anymore
//                 // If you want refresh, implement UsersState with a key
//               },
//               itemBuilder: (_) => menuActions,
//             ),
//           ]
//         ),
//       (
//         page: const Clubs(),
//         title: "CLUBS",
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {
//               // TODO: Add Club refresh logic if required
//             },
//             itemBuilder: (_) => menuActions,
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
//             itemBuilder: (_) => menuActions,
//           ),
//         ]
//       ),
//     ];

//     // Fix index if user logs out while on users tab
//     if (!isLoggedIn && selectedIndex == 1) {
//       selectedIndex = 0;
//     }

//     final current = pages[selectedIndex];

//     // ---------- UI ----------

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           current.title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 24,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (i) => setState(() => selectedIndex = i),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.deepPurple,
//         items: [
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.people),
//             label: "Players",
//           ),
//           if (isLoggedIn)
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.group),
//               label: user?.username ?? "User",
//             ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.location_city),
//             label: "Clubs",
//           ),
//           const BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: "Settings",
//           ),
//         ],
//       ),
//     );
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/widgets/player/add_player.dart';
// import 'package:precords_android/widgets/player/all_players.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/settings.dart';
// import "package:precords_android/services/auth_service.dart";

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;



//   // This key lets us call loadPlayers() after adding a player
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

//   void _openAddPlayerModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => const AddPlayerScreen(),
//     ).then((shouldRefresh) {
//       if (shouldRefresh == true) {
//         allPlayersKey.currentState?.loadPlayers();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = Get.find<AuthService>();
//     final user = auth.currentUser;
//     final isLoggedIn = auth.isLoggedIn.value;

//     // dynamic pages must be inside build()!
//     final List<({Widget page, String title, List<Widget> actions})> pages = [
//       (
//         page: AllPlayers(key: allPlayersKey),
//         title: "ALL PLAYERS",
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white, size: 28),
//             onPressed: _openAddPlayerModal,
//             tooltip: "Add Player",
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: "refresh", child: Text("Refresh")),
//               PopupMenuItem(value: "sort", child: Text("Sort")),
//               PopupMenuItem(value: "filter", child: Text("Filter")),
//             ],
//           ),
//         ],
//       ),

//       // USERS TAB – only visible when logged in
//       if ( isLoggedIn)
//         (
//           page: const Users(),
//           title: user?.username.toUpperCase() ?? "USERS",
//           actions: <Widget>[
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) =>
//                   allPlayersKey.currentState?.handleMenuAction(value),
//               itemBuilder: (_) => const [
//                 PopupMenuItem(value: "refresh", child: Text("Refresh")),
//                 PopupMenuItem(value: "sort", child: Text("Sort")),
//                 PopupMenuItem(value: "filter", child: Text("Filter")),
//               ],
//             ),
//           ],
//         ),

//       (
//         page: const Clubs(),
//         title: "CLUBS",
//         actions: <Widget>[
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: "refresh", child: Text("Refresh")),
//               PopupMenuItem(value: "sort", child: Text("Sort")),
//               PopupMenuItem(value: "filter", child: Text("Filter")),
//             ],
//           ),
//         ],
//       ),

//       (
//         page: const Settings(),
//         title: "SETTINGS",
//         actions: <Widget>[
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) =>
//                 allPlayersKey.currentState?.handleMenuAction(value),
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: "refresh", child: Text("Refresh")),
//               PopupMenuItem(value: "sort", child: Text("Sort")),
//               PopupMenuItem(value: "filter", child: Text("Filter")),
//             ],
//           ),
//         ],
//       ),
//     ];

//     final current = pages[selectedIndex];

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           current.title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//             fontSize: 25,
//           ),
//         ),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (i) => setState(() => selectedIndex = i),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: Colors.deepPurple,
//         items: [
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.people), label: "Players"),
//           if (isLoggedIn)
//             BottomNavigationBarItem(
//               icon: const Icon(Icons.group),
//               label: user?.username ?? "User",
//             ),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.location_city), label: "Clubs"),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }

 
// }
