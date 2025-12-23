import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../forms/player_form.dart';
import 'package:precords_android/widgets/player/all_players.dart';
import 'package:precords_android/widgets/user/users.dart';
import 'package:precords_android/widgets/club/clubs.dart';
import 'package:precords_android/widgets/settings.dart';
import 'package:precords_android/widgets/user/auth/login.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/services/theme_service.dart';

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
    final themeService = Get.find<ThemeService>();

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

