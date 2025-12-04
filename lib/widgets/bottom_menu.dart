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
      actions: <Widget>[ ],
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
          Container(height: 1.5, color: Colors.deepPurple), 
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
