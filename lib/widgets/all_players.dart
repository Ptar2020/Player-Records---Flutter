// lib/widgets/all_players.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:precords_android/models/player.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/widgets/player_details.dart';
import 'package:precords_android/widgets/refreshable_page.dart';

class AllPlayers extends StatefulWidget {
  const AllPlayers({super.key}); // ← now const works!

  @override
  State<AllPlayers> createState() => AllPlayersState();
}

class AllPlayersState extends State<AllPlayers> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ApiService api = Get.find<ApiService>();

  List<Player> allPlayers = [];
  List<Player> filteredPlayers = [];

  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  bool isLoading = true;
  bool _isRefreshing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    loadPlayers();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _filterPlayers);
  }

  Future<void> loadPlayers() async {
    if (_isRefreshing || !mounted) return;
    _isRefreshing = true;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final rawPlayers = await api.getAllPlayers();
      final players = rawPlayers.map(Player.fromPlayerInClub).toList();

      if (!mounted) return;

      setState(() {
        allPlayers = players;
        filteredPlayers = players;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    } finally {
      _isRefreshing = false;
    }
  }

  void _filterPlayers() {
    final query = searchController.text.toLowerCase().trim();
    final newList = query.isEmpty
        ? allPlayers
        : allPlayers.where((p) {
            final name = (p.name ?? "").toLowerCase();
            final country = (p.country ?? "").toLowerCase();
            final position = (p.position?.name ?? "").toLowerCase();
            final club = (p.club?.name ?? "").toLowerCase();
            return name.contains(query) ||
                country.contains(query) ||
                position.contains(query) ||
                club.contains(query);
          }).toList();

    if (!listEquals(newList, filteredPlayers)) {
      setState(() => filteredPlayers = newList);
    }
  }

  void showSortOptions() {
    Get.snackbar("Sort", "Sort options coming soon...", snackPosition: SnackPosition.BOTTOM);
  }

  void showFilterOptions() {
    Get.snackbar("Filter", "Filter options coming soon...", snackPosition: SnackPosition.BOTTOM);
  }

  Widget _avatarPlaceholder(String initials) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? "?" : initials,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for AutomaticKeepAliveClientMixin

    return RefreshablePage(
      onRefresh: loadPlayers,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search by name, position, country or club...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
                : errorMessage != null
                    ? Center(child: Text("Error: $errorMessage"))
                    : ListView.builder(
                        itemCount: filteredPlayers.length,
                        itemBuilder: (context, index) {
                          final player = filteredPlayers[index];
                          final initials = player.initials;

                          return ListTile(
                            onTap: () => Get.to(() => PlayerDetails(player: player)),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: player.photo?.isNotEmpty == true
                                  ? CachedNetworkImage(
                                      imageUrl: player.photo!,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => _avatarPlaceholder(initials),
                                      errorWidget: (_, __, ___) => _avatarPlaceholder(initials),
                                    )
                                  : _avatarPlaceholder(initials),
                            ),
                            title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${player.position?.name ?? '-'} • ${player.country ?? '-'}"),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                player.club?.name ?? "Free Agent",
                                style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';
// import '../services/api_service.dart';
// import '../models/player.dart';
// import 'player_details.dart';
// import 'refreshable_page.dart';

// class AllPlayers extends StatefulWidget
//     with HasAppBarTitle, HasAppBarActions {
//   const AllPlayers({super.key});

//   // App bar title
//   @override
//   Widget get appBarTitle => const Text("PLAYER RECORDS");

//   // App bar actions (three buttons)
//   @override
//   Widget appBarActions(BuildContext context) {
//     final state = context.findAncestorStateOfType<AllPlayersState>();
//     if (state == null) return const SizedBox.shrink();

//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         switch (value) {
//           case 'refresh':
//             state.loadPlayers();
//             break;
//           case 'sort':
//             state.showSortOptions(context);
//             break;
//           case 'filter':
//             state.showFilterOptions(context);
//             break;
//         }
//       },
//       itemBuilder: (context) => const [
//         PopupMenuItem(value: 'refresh', child: Text('Refresh')),
//         PopupMenuItem(value: 'sort', child: Text('Sort')),
//         PopupMenuItem(value: 'filter', child: Text('Filter')),
//       ],
//     );
//   }

//   @override
//   State<AllPlayers> createState() => AllPlayersState();
// }

// class AllPlayersState extends State<AllPlayers>
//     with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();
//   List<Player> allPlayers = [];
//   List<Player> filteredPlayers = [];
//   final TextEditingController searchController = TextEditingController();
//   Timer? _searchDebounce;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//     loadPlayers();
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     _searchDebounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 150), _filterPlayers);
//   }

//   // --- LOAD PLAYERS ---
//   Future<void> loadPlayers() async {
//     if (!mounted) return;

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final List<PlayerInClub> rawPlayers = await api.getAllPlayers();
//       final players = rawPlayers.map((p) => Player.fromPlayerInClub(p)).toList();

//       if (!mounted) return;
//       setState(() {
//         allPlayers = players;
//         filteredPlayers = players;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   // --- FILTER PLAYERS (search bar) ---
//   void _filterPlayers() {
//     final query = searchController.text.toLowerCase().trim();

//     final newList = query.isEmpty
//         ? allPlayers
//         : allPlayers.where((player) {
//             final name = (player.name ?? "").toLowerCase();
//             final country = (player.country ?? "").toLowerCase();
//             final position = (player.position?.name ?? "").toLowerCase();
//             final club = (player.club?.name ?? "").toLowerCase();
//             return name.contains(query) ||
//                 country.contains(query) ||
//                 position.contains(query) ||
//                 club.contains(query);
//           }).toList();

//     if (!listEquals(newList, filteredPlayers)) {
//       setState(() => filteredPlayers = newList);
//     }
//   }

//   // --- SORT BUTTON ---
//   void showSortOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.sort_by_alpha),
//             title: const Text('Sort by Name'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => a.name.compareTo(b.name));
//               });
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.flag),
//             title: const Text('Sort by Country'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => (a.country ?? "").compareTo(b.country ?? ""));
//               });
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.sports_soccer),
//             title: const Text('Sort by Club'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => (a.club?.name ?? "").compareTo(b.club?.name ?? ""));
//               });
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // --- FILTER BUTTON ---
//   void showFilterOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.person),
//             title: const Text('Only Free Agents'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers = allPlayers.where((p) => p.club == null).toList();
//               });
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.groups),
//             title: const Text('Players in Clubs'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers = allPlayers.where((p) => p.club != null).toList();
//               });
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.refresh),
//             title: const Text('Reset Filter'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers = List.from(allPlayers);
//               });
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _avatarPlaceholder(String initials) {
//     return Container(
//       width: 70,
//       height: 70,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         initials.isEmpty ? "?" : initials,
//         style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: loadPlayers,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: "Search by name, position, country or club...",
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Theme.of(context).brightness == Brightness.dark
//                     ? Colors.grey[800]
//                     : Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text(
//               "${filteredPlayers.length} player${filteredPlayers.length != 1 ? 's' : ''}",
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
//                 : filteredPlayers.isEmpty
//                     ? const Center(child: Text("No players found"))
//                     : ListView.builder(
//                         itemCount: filteredPlayers.length,
//                         itemBuilder: (context, index) {
//                           final player = filteredPlayers[index];
//                           final initials = player.initials;
//                           return ListTile(
//                             leading: player.photo != null
//                                 ? CachedNetworkImage(
//                                     imageUrl: player.photo!,
//                                     width: 70,
//                                     height: 70,
//                                     fit: BoxFit.cover,
//                                     placeholder: (_, __) => _avatarPlaceholder(initials),
//                                     errorWidget: (_, __, ___) => _avatarPlaceholder(initials),
//                                   )
//                                 : _avatarPlaceholder(initials),
//                             title: Text(player.name),
//                             subtitle: Text("${player.position?.name ?? '–'} • ${player.country ?? 'Unknown'}"),
//                             onTap: () => Get.to(() => PlayerDetails(player: player)),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }




// // all_players.dart
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// import '../services/api_service.dart';
// import '../models/player.dart';
// import 'player_details.dart';
// import 'refreshable_page.dart';

// class AllPlayers extends StatefulWidget with HasAppBarTitle, HasAppBarActions {
//   const AllPlayers({super.key});

//   @override
//   State<AllPlayers> createState() => AllPlayersState();

//   @override
//   Widget get appBarTitle => const Text("PLAYER RECORDS");

//   @override
//   Widget appBarActions(BuildContext context) {
//     final state = context.findAncestorStateOfType<AllPlayersState>();
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         if (state == null) return;
//         switch (value) {
//           case 'refresh':
//             state._refresh();
//             break;
//           case 'sort':
//             state.showSortOptions();
//             break;
//           case 'filter':
//             state.showFilterOptions();
//             break;
//         }
//       },
//       itemBuilder: (context) => const [
//         PopupMenuItem(value: 'refresh', child: Text('Refresh')),
//         PopupMenuItem(value: 'sort', child: Text('Sort')),
//         PopupMenuItem(value: 'filter', child: Text('Filter')),
//       ],
//     );
//   }
// }

// class AllPlayersState extends State<AllPlayers> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();

//   List<Player> allPlayers = [];
//   List<Player> filteredPlayers = [];

//   final TextEditingController searchController = TextEditingController();
//   Timer? _searchDebounce;
//   Timer? _refreshDebounce;

//   bool isLoading = true;
//   String? errorMessage;
//   bool _isRefreshing = false;

//   // Filters
//   String? selectedClub;
//   String? selectedPosition;
//   String? selectedCountry;

//   // Sorting
//   String? sortField; // 'name', 'club', 'country'
//   bool ascending = true;

//   @override
//   void initState() {
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//     loadPlayers();
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     _searchDebounce?.cancel();
//     _refreshDebounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 150), _filterPlayers);
//   }

//   void _refresh() {
//     _refreshDebounce?.cancel();
//     _refreshDebounce = Timer(const Duration(milliseconds: 200), loadPlayers);
//   }

//   Future<void> loadPlayers() async {
//     if (_isRefreshing || !mounted) return;
//     _isRefreshing = true;

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final List<PlayerInClub> rawPlayers = await api.getAllPlayers();
//       final players = rawPlayers.map((p) => Player.fromPlayerInClub(p)).toList();

//       if (!mounted) return;

//       setState(() {
//         allPlayers = players;
//         filteredPlayers = players;
//         isLoading = false;
//       });

//       _filterPlayers();
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     } finally {
//       _isRefreshing = false;
//     }
//   }

//   void _filterPlayers() {
//     final query = searchController.text.toLowerCase().trim();

//     final newList = allPlayers.where((player) {
//       final matchesSearch = query.isEmpty
//           ? true
//           : (player.name?.toLowerCase().contains(query) ?? false) ||
//             (player.country?.toLowerCase().contains(query) ?? false) ||
//             (player.position?.name.toLowerCase().contains(query) ?? false) ||
//             (player.club?.name.toLowerCase().contains(query) ?? false);

//       final matchesClub = selectedClub == null || player.club?.name == selectedClub;
//       final matchesPosition = selectedPosition == null || player.position?.name == selectedPosition;
//       final matchesCountry = selectedCountry == null || player.country == selectedCountry;

//       return matchesSearch && matchesClub && matchesPosition && matchesCountry;
//     }).toList();

//     // Apply sorting
//     if (sortField != null) {
//       newList.sort((a, b) {
//         int cmp = 0;
//         switch (sortField) {
//           case 'name':
//             cmp = a.name.compareTo(b.name);
//             break;
//           case 'club':
//             cmp = (a.club?.name ?? "").compareTo(b.club?.name ?? "");
//             break;
//           case 'country':
//             cmp = (a.country ?? "").compareTo(b.country ?? "");
//             break;
//         }
//         return ascending ? cmp : -cmp;
//       });
//     }

//     if (!listEquals(newList, filteredPlayers)) {
//       setState(() {
//         filteredPlayers = newList;
//       });
//     }
//   }

//   void showSortOptions() {
//     Get.bottomSheet(
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             title: const Text('Sort by Name'),
//             trailing: sortField == 'name' ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward) : null,
//             onTap: () {
//               setState(() {
//                 if (sortField == 'name') ascending = !ascending;
//                 else {
//                   sortField = 'name';
//                   ascending = true;
//                 }
//                 _filterPlayers();
//               });
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Sort by Club'),
//             trailing: sortField == 'club' ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward) : null,
//             onTap: () {
//               setState(() {
//                 if (sortField == 'club') ascending = !ascending;
//                 else {
//                   sortField = 'club';
//                   ascending = true;
//                 }
//                 _filterPlayers();
//               });
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Sort by Country'),
//             trailing: sortField == 'country' ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward) : null,
//             onTap: () {
//               setState(() {
//                 if (sortField == 'country') ascending = !ascending;
//                 else {
//                   sortField = 'country';
//                   ascending = true;
//                 }
//                 _filterPlayers();
//               });
//               Get.back();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//     );
//   }

//   void showFilterOptions() {
//     final clubs = allPlayers.map((p) => p.club?.name).whereType<String>().toSet().toList();
//     final positions = allPlayers.map((p) => p.position?.name).whereType<String>().toSet().toList();
//     final countries = allPlayers.map((p) => p.country).whereType<String>().toSet().toList();

//     Get.bottomSheet(
//       SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(title: const Text('Filter by Club')),
//             ...clubs.map((club) => RadioListTile<String>(
//                   title: Text(club),
//                   value: club,
//                   groupValue: selectedClub,
//                   onChanged: (v) => setState(() => selectedClub = v),
//                 )),
//             ListTile(title: const Text('Filter by Position')),
//             ...positions.map((pos) => RadioListTile<String>(
//                   title: Text(pos),
//                   value: pos,
//                   groupValue: selectedPosition,
//                   onChanged: (v) => setState(() => selectedPosition = v),
//                 )),
//             ListTile(title: const Text('Filter by Country')),
//             ...countries.map((c) => RadioListTile<String>(
//                   title: Text(c),
//                   value: c,
//                   groupValue: selectedCountry,
//                   onChanged: (v) => setState(() => selectedCountry = v),
//                 )),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: ElevatedButton(
//                 onPressed: () {
//                   _filterPlayers();
//                   Get.back();
//                 },
//                 child: const Text('Apply Filters'),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   selectedClub = null;
//                   selectedPosition = null;
//                   selectedCountry = null;
//                   _filterPlayers();
//                 });
//                 Get.back();
//               },
//               child: const Text('Clear Filters'),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
//     );
//   }

//   Widget _avatarPlaceholder(String initials) {
//     return Container(
//       width: 70,
//       height: 70,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         initials.isEmpty ? "?" : initials,
//         style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: loadPlayers,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: "Search by name, position, country or club...",
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text(
//               "${filteredPlayers.length} player${filteredPlayers.length != 1 ? 's' : ''}",
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
//                 : errorMessage != null
//                     ? Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                             const SizedBox(height: 16),
//                             Text("Failed to load players", style: TextStyle(color: Colors.grey[700])),
//                             Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               onPressed: _refresh,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text("Retry"),
//                             ),
//                           ],
//                         ),
//                       )
//                     : filteredPlayers.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
//                                 const SizedBox(height: 16),
//                                 const Text("No players match your search", style: TextStyle(fontSize: 16)),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             cacheExtent: 2000,
//                             itemCount: filteredPlayers.length,
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             itemBuilder: (context, index) {
//                               final player = filteredPlayers[index];
//                               final initials = player.initials;

//                               return Card(
//                                 elevation: 4,
//                                 margin: const EdgeInsets.symmetric(vertical: 6),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                                 child: ListTile(
//                                   contentPadding: const EdgeInsets.all(16),
//                                   onTap: () => Get.to(() => PlayerDetails(player: player), transition: Transition.cupertino),
//                                   leading: ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: player.photo?.isNotEmpty == true
//                                         ? CachedNetworkImage(
//                                             imageUrl: player.photo!,
//                                             width: 70,
//                                             height: 70,
//                                             fit: BoxFit.cover,
//                                             placeholder: (_, __) => _avatarPlaceholder(initials),
//                                             errorWidget: (_, __, ___) => _avatarPlaceholder(initials),
//                                           )
//                                         : _avatarPlaceholder(initials),
//                                   ),
//                                   title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
//                                   subtitle: Text(
//                                     "${player.position?.name ?? '–'} • ${player.country ?? 'Unknown'}",
//                                     style: TextStyle(color: Colors.grey[700]),
//                                   ),
//                                   trailing: Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                                     decoration: BoxDecoration(
//                                       color: Colors.deepPurple[50],
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       player.club?.name ?? "Free Agent",
//                                       style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold, fontSize: 13),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//           ),
//         ],
//       ),
//     );
//   }
// }












// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';

// import '../services/api_service.dart';
// import '../models/player.dart';
// import 'player_details.dart';
// import 'refreshable_page.dart';

// class AllPlayers extends StatefulWidget with HasAppBarTitle, HasAppBarActions {
//   const AllPlayers({super.key});

//   @override
//   State<AllPlayers> createState() => AllPlayersState();

//   @override
//   Widget get appBarTitle => const Text("PLAYER RECORDS");

//   @override
//   Widget appBarActions(BuildContext context) {
//     final state = context.findAncestorStateOfType<AllPlayersState>();
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         if (state == null) return;
//         switch (value) {
//           case 'refresh':
//             state._refresh();
//             break;
//           case 'sort':
//             state.showSortOptions();
//             break;
//           case 'filter':
//             state.showFilterOptions();
//             break;
//         }
//       },
//       itemBuilder: (context) => const [
//         PopupMenuItem(value: 'refresh', child: Text('Refresh')),
//         PopupMenuItem(value: 'sort', child: Text('Sort')),
//         PopupMenuItem(value: 'filter', child: Text('Filter')),
//       ],
//     );
//   }
// }

// class AllPlayersState extends State<AllPlayers> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final ApiService api = Get.find<ApiService>();

//   List<Player> allPlayers = [];
//   List<Player> filteredPlayers = [];

//   final TextEditingController searchController = TextEditingController();
//   Timer? _searchDebounce;
//   Timer? _refreshDebounce;

//   bool isLoading = true;
//   String? errorMessage;
//   bool _isRefreshing = false;

//   @override
//   void initState() {
//     super.initState();
//     searchController.addListener(_onSearchChanged);
//     loadPlayers();
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_onSearchChanged);
//     searchController.dispose();
//     _searchDebounce?.cancel();
//     _refreshDebounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 150), _filterPlayers);
//   }

//   void _refresh() {
//     _refreshDebounce?.cancel();
//     _refreshDebounce = Timer(const Duration(milliseconds: 200), loadPlayers);
//   }

//   Future<void> loadPlayers() async {
//     if (_isRefreshing || !mounted) return;
//     _isRefreshing = true;

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final List<PlayerInClub> rawPlayers = await api.getAllPlayers();
//       final players = rawPlayers.map((p) => Player.fromPlayerInClub(p)).toList();

//       if (!mounted) return;

//       setState(() {
//         allPlayers = players;
//         filteredPlayers = players;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     } finally {
//       _isRefreshing = false;
//     }
//   }

//   void _filterPlayers() {
//     final query = searchController.text.toLowerCase().trim();

//     final newList = query.isEmpty
//         ? allPlayers
//         : allPlayers.where((player) {
//             final name = (player.name ?? "").toLowerCase();
//             final country = (player.country ?? "").toLowerCase();
//             final position = (player.position?.name ?? "").toLowerCase();
//             final club = (player.club?.name ?? "").toLowerCase();
//             return name.contains(query) ||
//                 country.contains(query) ||
//                 position.contains(query) ||
//                 club.contains(query);
//           }).toList();

//     if (!listEquals(newList, filteredPlayers)) {
//       setState(() {
//         filteredPlayers = newList;
//       });
//     }
//   }

//   // Sort options
//   void showSortOptions() {
//     Get.bottomSheet(
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             title: const Text('Sort by Name'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => a.name.compareTo(b.name));
//               });
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Sort by Club'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => (a.club?.name ?? "").compareTo(b.club?.name ?? ""));
//               });
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Sort by Country'),
//             onTap: () {
//               setState(() {
//                 filteredPlayers.sort((a, b) => (a.country ?? "").compareTo(b.country ?? ""));
//               });
//               Get.back();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//     );
//   }

//   // Filter options
//   void showFilterOptions() {
//     Get.bottomSheet(
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             title: const Text('Filter by Club'),
//             onTap: () {
//               // Implement a dialog or filter logic
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Filter by Position'),
//             onTap: () {
//               // Implement a dialog or filter logic
//               Get.back();
//             },
//           ),
//           ListTile(
//             title: const Text('Filter by Country'),
//             onTap: () {
//               // Implement a dialog or filter logic
//               Get.back();
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//     );
//   }

//   Widget _avatarPlaceholder(String initials) {
//     return Container(
//       width: 70,
//       height: 70,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))],
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         initials.isEmpty ? "?" : initials,
//         style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: loadPlayers,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 hintText: "Search by name, position, country or club...",
//                 prefixIcon: const Icon(Icons.search),
//                 filled: true,
//                 fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text(
//               "${filteredPlayers.length} player${filteredPlayers.length != 1 ? 's' : ''}",
//               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Expanded(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
//                 : errorMessage != null
//                     ? Center(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                             const SizedBox(height: 16),
//                             Text("Failed to load players", style: TextStyle(color: Colors.grey[700])),
//                             Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               onPressed: _refresh,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text("Retry"),
//                             ),
//                           ],
//                         ),
//                       )
//                     : filteredPlayers.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
//                                 const SizedBox(height: 16),
//                                 const Text("No players match your search", style: TextStyle(fontSize: 16)),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             physics: const BouncingScrollPhysics(),
//                             cacheExtent: 2000,
//                             itemCount: filteredPlayers.length,
//                             padding: const EdgeInsets.symmetric(horizontal: 12),
//                             itemBuilder: (context, index) {
//                               final player = filteredPlayers[index];
//                               final initials = player.initials;

//                               return Card(
//                                 elevation: 4,
//                                 margin: const EdgeInsets.symmetric(vertical: 6),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                                 child: ListTile(
//                                   contentPadding: const EdgeInsets.all(16),
//                                   onTap: () => Get.to(() => PlayerDetails(player: player), transition: Transition.cupertino),
//                                   leading: ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: player.photo?.isNotEmpty == true
//                                         ? CachedNetworkImage(
//                                             imageUrl: player.photo!,
//                                             width: 70,
//                                             height: 70,
//                                             fit: BoxFit.cover,
//                                             placeholder: (_, __) => _avatarPlaceholder(initials),
//                                             errorWidget: (_, __, ___) => _avatarPlaceholder(initials),
//                                             fadeInDuration: const Duration(milliseconds: 180),
//                                             fadeOutDuration: const Duration(milliseconds: 120),
//                                           )
//                                         : _avatarPlaceholder(initials),
//                                   ),
//                                   title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
//                                   subtitle: Text(
//                                     "${player.position?.name ?? '–'} • ${player.country ?? 'Unknown'}",
//                                     style: TextStyle(color: Colors.grey[700]),
//                                   ),
//                                   trailing: Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//                                     decoration: BoxDecoration(
//                                       color: Colors.deepPurple[50],
//                                       borderRadius: BorderRadius.circular(20),
//                                     ),
//                                     child: Text(
//                                       player.club?.name ?? "Free Agent",
//                                       style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold, fontSize: 13),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//           ),
//         ],
//       ),
//     );
//   }
// }








