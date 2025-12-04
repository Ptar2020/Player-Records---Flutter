import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/widgets/all_players.dart';
import 'package:precords_android/widgets/coaches.dart';
import 'package:precords_android/widgets/users.dart';
import 'package:precords_android/widgets/clubs.dart';
import 'package:precords_android/widgets/settings.dart';
import 'package:precords_android/services/auth_service.dart'; 

class BottomMenu extends StatefulWidget {
  const BottomMenu({super.key});

  @override
  State<BottomMenu> createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int selectedIndex = 0;

  // GlobalKeys — one for each tab that needs actions
  final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
  final GlobalKey<ClubsState>    clubsKey       = GlobalKey<ClubsState>();
  final GlobalKey<UsersState>    usersKey       = GlobalKey<UsersState>();

  late final List<({Widget page, String title, List<Widget> actions})> pages = [
    // ── Players ─────────────────────────────────────
    (
      page: AllPlayers(key: allPlayersKey),
      title: "ALL PLAYERS",
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            final state = allPlayersKey.currentState;
            switch (value) {
              case "refresh": state?.loadPlayers(); break;
              case "sort":    state?.showSortOptions(); break;
              case "filter":  state?.showFilterOptions(); break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "refresh", child: Text("Refresh")),
            PopupMenuItem(value: "sort",   child: Text("Sort")),
            PopupMenuItem(value: "filter", child: Text("Filter")),
          ],
        ),
      ],
    ),

    // ── Coaches (placeholder) ───────────────────────
    (
      page: const Coaches(),
      title: "COACHES",
      actions: <Widget>[ /* you’ll fill this later */ ],
    ),

    // ── Users ───────────────────────────────────────
    (
      page: Users(key: usersKey),
      title: "USERS",
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == "refresh") usersKey.currentState?.refresh();
            if (value == "logout")  Get.find<AuthService>().logout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "refresh", child: Text("Refresh")),
            PopupMenuItem(value: "logout",  child: Text("Logout")),
          ],
        ),
      ],
    ),

    // ── Clubs ───────────────────────────────────────
    (
      page: Clubs(key: clubsKey),
      title: "CLUBS",
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            if (value == "refresh") clubsKey.currentState?.refresh();
            if (value == "logout")  Get.find<AuthService>().logout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "refresh", child: Text("Refresh")),
            PopupMenuItem(value: "logout",  child: Text("Logout")),
          ],
        ),
      ],
    ),

    // ── Settings ────────────────────────────────────
    (
      page: const Settings(),
      title: "SETTINGS",
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          itemBuilder: (_) => const [
            PopupMenuItem(value: "refresh", child: Text("Refresh")),
            PopupMenuItem(value: "about",   child: Text("About")),
          ],
          onSelected: (_) {}, // placeholder
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = pages[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          current.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: current.actions,
      ),
      body: Column(
        children: [
          Expanded(child: current.page),
          Container(height: 1.5, color: Colors.deepPurple), // your divider
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people),          label: "Players"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_kabaddi), label: "Coaches"),
          BottomNavigationBarItem(icon: Icon(Icons.group),           label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.location_city),  label: "Clubs"),
          BottomNavigationBarItem(icon: Icon(Icons.settings),        label: "Settings"),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:precords_android/widgets/all_players.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';
// import 'package:get/get.dart';

// class BottomMenu extends StatefulWidget {
//   const BottomMenu({super.key});

//   @override
//   State<BottomMenu> createState() => _BottomMenuState();
// }

// class _BottomMenuState extends State<BottomMenu> {
//   int selectedIndex = 0;

//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();

//   // Wrap pages with metadata using a simple record (Dart 3+)
//   late final List<({Widget page, Widget title, List<Widget> actions})> pages = [
//     (
//       page: AllPlayers(key: allPlayersKey),
//       title: const Text("PLAYER RECORDS"),
//       actions: <Widget>[
//         PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, color: Colors.white),
//           onSelected: (value) {
//             final state = allPlayersKey.currentState;
//             switch (value) {
//               case "refresh":
//                 state?.loadPlayers();
//                 break;
//               case "sort":
//                 state?.showSortOptions();
//                 break;
//               case "filter":
//                 state?.showFilterOptions();
//                 break;
//             }
//           },
//           itemBuilder: (_) => const [
//             PopupMenuItem(value: "refresh", child: Text("Refresh")),
//             PopupMenuItem(value: "sort", child: Text("Sort")),
//             PopupMenuItem(value: "filter", child: Text("Filter")),
//           ],
//         ),
//       ],
//     ),
//     (
//       page: const Settings(),
//       title: const Text("Settings"),
//       actions: <Widget>[],
//     ),
//   ];

//   void confirmLogout() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Get.offAllNamed("/login");
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final current = pages[selectedIndex];

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: current.title,
//         actions: current.actions,
//       ),
//       body: current.page,
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (index) => setState(() => selectedIndex = index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.people), label: "Players"),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';

// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/widgets/all_players.dart';
// import 'package:precords_android/widgets/clubs.dart';
// import 'package:precords_android/widgets/users.dart';

// final RxInt currentTabIndex = 0.obs;

// class Menu extends StatefulWidget {
//   const Menu({super.key});

//   @override
//   State<Menu> createState() => MenuState();
// }

// class MenuState extends State<Menu> {
//   final RxInt selectedIndex = 0.obs;

//   // GlobalKeys for pages to access state from app bar if needed
//   final GlobalKey<AllPlayersState> allPlayersKey = GlobalKey<AllPlayersState>();
//   final GlobalKey<SettingsState> settingsKey = GlobalKey<SettingsState>();

//   List<Widget> buildPages(bool isAdmin) {
//     return [
//       AllPlayers(key: allPlayersKey),
//       const Clubs(),
//       if (isAdmin) const Users(),
//       Settings(key: settingsKey),
//       const SizedBox(), // Placeholder for login/logout
//     ];
//   }

//   void _showLoginModal() {
//     Get.bottomSheet(
//       const Login(),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//     );
//   }

//   void _confirmLogout() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Log out?"),
//         content: const Text("Are you sure you want to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               Get.back();
//               await Get.find<AuthService>().logout();
//             },
//             child: const Text("Log out", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Get.find<AuthService>();
//     final themeService = Get.find<ThemeService>();

//     return Scaffold(
//       body: Obx(() {
//         final isAdmin = (authService.currentUser?.role ?? '').toLowerCase() == "admin";
//         final pages = buildPages(isAdmin);

//         return NestedScrollView(
//           headerSliverBuilder: (context, _) => [
//             SliverAppBar(
//               expandedHeight: 50,
//               floating: true,
//               pinned: true,
//               backgroundColor: Colors.deepPurple,
//               foregroundColor: Colors.white,
//               elevation: 5,
//               leading: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Obx(() => IconButton(
//                       icon: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Icon(
//                           themeService.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
//                           key: ValueKey(themeService.isDarkMode.value),
//                         ),
//                       ),
//                       color: Colors.white,
//                       onPressed: () => themeService.switchTheme(),
//                     )),
//               ),
//               actions: [
//                 Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarActions) {
//                     return currentPage.appBarActions(context);
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarTitle) {
//                     return DefaultTextStyle(
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                       child: currentPage.appBarTitle,
//                     );
//                   }
//                   return const Text(
//                     "PLAYER RECORDS",
//                     style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
//                   );
//                 }),
//                 centerTitle: true,
//               ),
//             ),
//           ],
//           body: Obx(() => IndexedStack(index: selectedIndex.value, children: pages)),
//         );
//       }),
//       bottomNavigationBar: Obx(() {
//         final isLoggedIn = authService.isLoggedIn.value;
//         final isAdmin = (authService.currentUser?.role ?? '').toLowerCase() == "admin";

//         final items = <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Players"),
//           const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clubs"),
//           if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
//           const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//           BottomNavigationBarItem(icon: Icon(isLoggedIn ? Icons.logout : Icons.login), label: isLoggedIn ? "Logout" : "Login"),
//         ];

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(height: 5, color: Colors.deepPurple),
//             BottomNavigationBar(
//               currentIndex: selectedIndex.value,
//               onTap: (index) {
//                 if (index == items.length - 1) {
//                   isLoggedIn ? _confirmLogout() : _showLoginModal();
//                 } else {
//                   selectedIndex.value = index;
//                   currentTabIndex.value = index;
//                 }
//               },
//               type: BottomNavigationBarType.fixed,
//               selectedItemColor: Colors.deepPurple,
//               unselectedItemColor: Colors.grey[600],
//               showUnselectedLabels: true,
//               items: items,
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }






// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/widgets/all_players.dart';
// import 'package:precords_android/widgets/club/clubs.dart';
// import 'package:precords_android/widgets/user/users.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// final RxInt currentTabIndex = 0.obs;

// class Menu extends StatefulWidget {
//   const Menu({super.key});

//   @override
//   State<Menu> createState() => MenuState();
// }

// class MenuState extends State<Menu> {
//   final RxInt selectedIndex = 0.obs;

//   List<Widget> buildPages(bool isAdmin) {
//     return [
//       const AllPlayers(),
//       const Clubs(),
//       if (isAdmin) const Users(),
//       const Settings(),
//       const SizedBox(),
//     ];
//   }

//   void _showLoginModal() {
//     Get.bottomSheet(
//       const Login(),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//     );
//   }

//   // ✅ Make this public so other pages (like Settings) can call
//   void confirmLogout() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Log out?"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               Get.back();
//               await Get.find<AuthService>().logout();
//             },
//             child: const Text("Log out", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Get.find<AuthService>();
//     final themeService = Get.find<ThemeService>();

//     return Scaffold(
//       body: Obx(() {
//         final isAdmin = (authService.currentUser?.role ?? '').toLowerCase() == "admin";
//         final pages = buildPages(isAdmin);

//         return NestedScrollView(
//           headerSliverBuilder: (context, _) => [
//             SliverAppBar(
//               expandedHeight: 50,
//               floating: true,
//               pinned: true,
//               backgroundColor: Colors.deepPurple,
//               foregroundColor: Colors.white,
//               elevation: 5,
//               leading: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Obx(() => IconButton(
//                       icon: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Icon(
//                           themeService.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
//                           key: ValueKey(themeService.isDarkMode.value),
//                         ),
//                       ),
//                       color: Colors.white,
//                       onPressed: () => themeService.switchTheme(),
//                     )),
//               ),
//               actions: [
//                 Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarActions) {
//                     return (currentPage as HasAppBarActions).appBarActions(context);
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarTitle) {
//                     return DefaultTextStyle(
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 23,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                       child: (currentPage as HasAppBarTitle).appBarTitle,
//                     );
//                   }
//                   return const Text(
//                     "PLAYER RECORDS",
//                     style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
//                   );
//                 }),
//                 centerTitle: true,
//               ),
//             ),
//           ],
//           body: Obx(() => IndexedStack(index: selectedIndex.value, children: pages)),
//         );
//       }),
//       bottomNavigationBar: Obx(() {
//         final isLoggedIn = authService.isLoggedIn.value;
//         final isAdmin = (authService.currentUser?.role ?? '').toLowerCase() == "admin";

//         final items = <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Players"),
//           const BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clubs"),
//           if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
//           const BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
//           BottomNavigationBarItem(icon: Icon(isLoggedIn ? Icons.logout : Icons.login), label: isLoggedIn ? "Logout" : "Login"),
//         ];

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(height: 5, color: Colors.deepPurple),
//             BottomNavigationBar(
//               currentIndex: selectedIndex.value,
//               onTap: (index) {
//                 if (index == items.length - 1) {
//                   isLoggedIn ? confirmLogout() : _showLoginModal();
//                 } else {
//                   selectedIndex.value = index;
//                   currentTabIndex.value = index;
//                 }
//               },
//               type: BottomNavigationBarType.fixed,
//               selectedItemColor: Colors.deepPurple,
//               unselectedItemColor: Colors.grey[600],
//               showUnselectedLabels: true,
//               items: items,
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/services/theme_service.dart';
// import 'package:precords_android/widgets/all_players.dart';
// import 'package:precords_android/widgets/clubs.dart';
// import 'package:precords_android/widgets/users.dart';
// import 'package:precords_android/widgets/settings.dart';
// import 'package:precords_android/widgets/user/auth/login.dart';

// final RxInt currentTabIndex = 0.obs;

// class Menu extends StatefulWidget {
//   const Menu({super.key});

//   @override
//   State<Menu> createState() => _MenuState();
// }

// class _MenuState extends State<Menu> {
//   final RxInt selectedIndex = 0.obs;

//   List<Widget> buildPages(bool isAdmin) {
//     return [
//       const AllPlayers(),
//       const Clubs(),      
//       if (isAdmin) const Users(),
//       const Settings(),
//        const SizedBox(),
      
//     ];
//   }

//   void _showLoginModal() {
//     Get.bottomSheet(
//       const Login(),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//     );
//   }

//   void _confirmLogout() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("Log out?"),
//         content: const Text("Sure to log out?"),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () async {
//               Get.back();
//               await Get.find<AuthService>().logout();
//             },
//             child: const Text("Log out", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authService = Get.find<AuthService>();
//     final themeService = Get.find<ThemeService>();

//     return Scaffold(
//       body: Obx(() {
//         final isAdmin = authService.currentUser?.role?.toLowerCase() == "admin";

//         final pages = buildPages(isAdmin);

//         return NestedScrollView(
//           headerSliverBuilder: (context, _) => [
//             SliverAppBar(
//               expandedHeight: 50,
//               floating: true,
//               pinned: true,
//               backgroundColor: Colors.deepPurple,
//               foregroundColor: Colors.white,
//               elevation: 5,
//               leading: Padding(
//                 padding: const EdgeInsets.only(left: 8),
//                 child: Obx(() => IconButton(
//                       icon: AnimatedSwitcher(
//                         duration: const Duration(milliseconds: 300),
//                         child: Icon(
//                           themeService.isDarkMode.value
//                               ? Icons.light_mode
//                               : Icons.dark_mode,
//                           key: ValueKey(themeService.isDarkMode.value),
//                         ),
//                       ),
//                       color: Colors.white,
//                       onPressed: () => themeService.switchTheme(),
//                     )),
//               ),
//               actions: [
//                 Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarActions) {
//                     return (currentPage as HasAppBarActions)
//                         .appBarActions(context);
//                   }
//                   return const SizedBox.shrink();
//                 }),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Obx(() {
//                   final currentPage = pages[selectedIndex.value];
//                   if (currentPage is HasAppBarTitle) {
//                     return DefaultTextStyle(
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,              // ← Change this number to make titles bigger/smaller
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                       child: (currentPage as HasAppBarTitle).appBarTitle,
//                     );
//                   }
//                   return const Text(
//                     "PLAYER RECORDS",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   );
//                 }),
//                 centerTitle: true,
//               ),
              
//             ),
//           ],
//           body: Obx(
//             () => IndexedStack(
//               index: selectedIndex.value,
//               children: pages,
//             ),
//           ),
//         );
//       }),
//       bottomNavigationBar: Obx(() {
//         final isLoggedIn = authService.isLoggedIn.value;
//         final isAdmin = authService.currentUser?.role?.toLowerCase() == "admin";

//         // build navigation items dynamically
//         final items = <BottomNavigationBarItem>[
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.sports_soccer), label: "Players"),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.people), label: "Clubs"),
//           if (isAdmin)
//             const BottomNavigationBarItem(
//                 icon: Icon(Icons.group), label: "Users"),
//           const BottomNavigationBarItem(
//               icon: Icon(Icons.settings), label: "Settings"),
//           BottomNavigationBarItem(
//             icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
//             label: isLoggedIn ? "Logout" : "Login",
//           ),
//         ];

//         final pages = buildPages(isAdmin);

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(height: 5, color: Colors.deepPurple),
//             BottomNavigationBar(
//               currentIndex: selectedIndex.value,
//               onTap: (index) {
//                 // last item = login/logout
//                 if (index == items.length - 1) {
//                   isLoggedIn ? _confirmLogout() : _showLoginModal();
//                 } else {
//                   selectedIndex.value = index;
//                   currentTabIndex.value = index;
//                 }
//               },
//               type: BottomNavigationBarType.fixed,
//               selectedItemColor: Colors.deepPurple,
//               unselectedItemColor: Colors.grey[600],
//               showUnselectedLabels: true,
//               items: items,
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }

// // mixins
// mixin HasAppBarTitle on Widget {
//   Widget get appBarTitle;
// }

// mixin HasAppBarActions on Widget {
//   Widget appBarActions(BuildContext context);
// }


