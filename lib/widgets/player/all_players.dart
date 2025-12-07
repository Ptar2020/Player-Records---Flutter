import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_service.dart';
import '../../models/player_model.dart';
import '../../widgets/player/player_details.dart';

class AllPlayers extends StatefulWidget {
  const AllPlayers({Key? key}) : super(key: key);

  @override
  State<AllPlayers> createState() => AllPlayersState();
}

class AllPlayersState extends State<AllPlayers> {
  final ApiService api = Get.find<ApiService>();
  List<PlayerInClub> players = [];
  List<PlayerInClub> filteredPlayers = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  // Search filters
  bool searchName = true;
  bool searchPosition = true;
  bool searchClub = true;
  bool searchCountry = true;
  bool searchJersey = true;

  @override
  void initState() {
    super.initState();
    loadPlayers();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadPlayers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetched = await api.getAllPlayers();
      setState(() {
        players = fetched;
        filteredPlayers = fetched;
      });
    } catch (e) {
      setState(
          () => errorMessage = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterPlayers);
  }

  void _filterPlayers() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredPlayers = players.where((p) {
        final name = (p.name ?? "").toLowerCase();
        final position = (p.position?.name ?? "").toLowerCase();
        final club = (p.club?.name ?? "").toLowerCase();
        final country = (p.country ?? "").toLowerCase();
        final jersey = p.jerseyNumber?.toString() ?? "";

        return (searchName && name.contains(query)) ||
            (searchPosition && position.contains(query)) ||
            (searchClub && club.contains(query)) ||
            (searchCountry && country.contains(query)) ||
            (searchJersey && jersey.contains(query));
      }).toList();
    });
  }

  void handleMenuAction(String action) {
    if (action == "refresh") loadPlayers();
    if (action == "sort") _showSortSheet();
    if (action == "filter") _showFilterSheet();
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text("Sort Players",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text("Name A-Z"),
              onTap: () {
                setState(() => filteredPlayers
                    .sort((a, b) => (a.name ?? "").compareTo(b.name ?? "")));
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text("Jersey Number"),
              onTap: () {
                setState(() => filteredPlayers.sort((a, b) =>
                    (a.jerseyNumber ?? 999).compareTo(b.jerseyNumber ?? 999)));
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Search In",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text("Name"),
                    selected: searchName,
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (v) => setModalState(() => searchName = v),
                  ),
                  FilterChip(
                    label: const Text("Position"),
                    selected: searchPosition,
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (v) => setModalState(() => searchPosition = v),
                  ),
                  FilterChip(
                    label: const Text("Club"),
                    selected: searchClub,
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (v) => setModalState(() => searchClub = v),
                  ),
                  FilterChip(
                    label: const Text("Country"),
                    selected: searchCountry,
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (v) => setModalState(() => searchCountry = v),
                  ),
                  FilterChip(
                    label: const Text("Jersey #"),
                    selected: searchJersey,
                    selectedColor: Colors.deepPurple.shade100,
                    onSelected: (v) => setModalState(() => searchJersey = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    _filterPlayers();
                    Get.back();
                  },
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _countryCodeToFlag(String? code) {
    if (code == null || code.length < 2) return "Unknown";
    final country = code.substring(0, 2).toUpperCase();
    return country
        .split('')
        .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
        .join();
  }

  Widget _buildPlayerCard(PlayerInClub player) {
    final fullPlayer = Player.fromPlayerInClub(player);

    return Hero(
      tag: "player_${player.id}",
      child: Card(
        elevation: 8,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
              transition: Transition.zoom,
              duration: const Duration(milliseconds: 400)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.deepPurple.shade100,
                      backgroundImage: player.photo != null
                          ? CachedNetworkImageProvider(player.photo!)
                          : null,
                      child: player.photo == null
                          ? Text(fullPlayer.initials,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple))
                          : null,
                    ),
                    if (player.jerseyNumber != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.deepPurple, shape: BoxShape.circle),
                          child: Text("${player.jerseyNumber}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player.name ?? "Unknown Player",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      if (player.position?.name != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                              player.position!.shortName ??
                                  player.position!.name,
                              style: TextStyle(
                                  color: Colors.deepPurple.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (player.club?.logo != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: player.club!.logo!,
                                width: 20,
                                height: 20,
                                placeholder: (_, __) =>
                                    const SizedBox(width: 20),
                                errorWidget: (_, __, ___) => const Icon(
                                    Icons.sports_soccer,
                                    size: 20,
                                    color: Colors.grey),
                              ),
                            )
                          else
                            const Icon(Icons.sports_soccer,
                                size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(player.club?.name ?? "No Club",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Text(
                              player.country != null
                                  ? _countryCodeToFlag(player.country)
                                  : "Unknown",
                              style: const TextStyle(fontSize: 24)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple));
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("Connection Error",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loadPlayers,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Player name, club, position, country or jersey number...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.deepPurple.shade50,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        if (searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                if (searchName)
                  Chip(
                      label: const Text("Name"),
                      backgroundColor: Colors.deepPurple.shade100),
                if (searchPosition)
                  Chip(
                      label: const Text("Position"),
                      backgroundColor: Colors.deepPurple.shade100),
                if (searchClub)
                  Chip(
                      label: const Text("Club"),
                      backgroundColor: Colors.deepPurple.shade100),
                if (searchCountry)
                  Chip(
                      label: const Text("Country"),
                      backgroundColor: Colors.deepPurple.shade100),
                if (searchJersey)
                  Chip(
                      label: const Text("Jersey #"),
                      backgroundColor: Colors.deepPurple.shade100),
              ],
            ),
          ),
        Expanded(
          child: filteredPlayers.isEmpty
              ? const Center(
                  child: Text("No players found",
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: loadPlayers,
                  color: Colors.deepPurple,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredPlayers.length,
                    itemBuilder: (context, i) =>
                        _buildPlayerCard(filteredPlayers[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../services/api_service.dart';
// import '../../models/player_model.dart';
// import '../../widgets/player/player_details.dart';

// class AllPlayers extends StatefulWidget {
//   const AllPlayers({Key? key}) : super(key: key);

//   @override
//   State<AllPlayers> createState() => AllPlayersState();
// }

// class AllPlayersState extends State<AllPlayers> {
//   final ApiService api = Get.find<ApiService>();
//   List<PlayerInClub> players = [];
//   List<PlayerInClub> filteredPlayers = [];
//   bool isLoading = true;
//   String? errorMessage;
//   final TextEditingController searchController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadPlayers();
//     searchController.addListener(_filterPlayers);
//   }

//   @override
//   void dispose() {
//     searchController.removeListener(_filterPlayers);
//     searchController.dispose();
//     super.dispose();
//   }

//   Future<void> loadPlayers() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });
//     try {
//       final fetched = await api.getAllPlayers();
//       setState(() {
//         players = fetched;
//         filteredPlayers = fetched;
//       });
//     } catch (e) {
//       setState(
//           () => errorMessage = e.toString().replaceFirst("Exception: ", ""));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _filterPlayers() {
//     final query = searchController.text.toLowerCase();
//     setState(() {
//       filteredPlayers = players.where((p) {
//         final name = p.name?.toLowerCase() ?? '';
//         final club = p.club?.name?.toLowerCase() ?? '';
//         final country = p.country?.toLowerCase() ?? '';
//         return name.contains(query) ||
//             club.contains(query) ||
//             country.contains(query);
//       }).toList();
//     });
//   }

//   void handleMenuAction(String action) {
//     switch (action) {
//       case "refresh":
//         loadPlayers();
//         break;
//       case "sort":
//         _showSortSheet();
//         break;
//       case "filter":
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Filter coming soon")),
//         );
//         break;
//     }
//   }

//   void _showSortSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text("Sort Players",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//             const Divider(height: 1),
//             ListTile(
//               leading: const Icon(Icons.sort_by_alpha),
//               title: const Text("Name A-Z"),
//               onTap: () {
//                 setState(() {
//                   filteredPlayers
//                       .sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
//                 });
//                 Get.back();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.confirmation_number),
//               title: const Text("Jersey Number"),
//               onTap: () {
//                 setState(() {
//                   filteredPlayers.sort((a, b) =>
//                       (a.jerseyNumber ?? 999).compareTo(b.jerseyNumber ?? 999));
//                 });
//                 Get.back();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _countryCodeToFlag(String? code) {
//     if (code == null || code.length < 2) return "Unknown";
//     final String country = code.substring(0, 2).toUpperCase();
//     return country
//         .split('')
//         .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
//         .join();
//   }

//   Widget _buildPlayerCard(PlayerInClub player) {
//     final fullPlayer = Player.fromPlayerInClub(player);

//     return Hero(
//       tag: "player_${player.id}",
//       child: Card(
//         elevation: 8,
//         shadowColor: Colors.deepPurple.withOpacity(0.3),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         margin: const EdgeInsets.only(bottom: 16),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(20),
//           onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
//               transition: Transition.zoom,
//               duration: const Duration(milliseconds: 400)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Photo + Jersey Badge
//                 Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 42,
//                       backgroundColor: Colors.deepPurple.shade100,
//                       backgroundImage: player.photo != null
//                           ? CachedNetworkImageProvider(player.photo!)
//                           : null,
//                       child: player.photo == null
//                           ? Text(fullPlayer.initials,
//                               style: const TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple))
//                           : null,
//                     ),
//                     if (player.jerseyNumber != null)
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: const BoxDecoration(
//                               color: Colors.deepPurple, shape: BoxShape.circle),
//                           child: Text("${player.jerseyNumber}",
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14)),
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(player.name ?? "Unknown Player",
//                           style: const TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis),
//                       const SizedBox(height: 6),
//                       if (player.position?.name != null)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 4),
//                           decoration: BoxDecoration(
//                               color: Colors.deepPurple.shade50,
//                               borderRadius: BorderRadius.circular(12)),
//                           child: Text(
//                               player.position!.shortName ??
//                                   player.position!.name,
//                               style: TextStyle(
//                                   color: Colors.deepPurple.shade700,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13)),
//                         ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           if (player.club?.logo != null)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(4),
//                               child: CachedNetworkImage(
//                                   imageUrl: player.club!.logo!,
//                                   width: 20,
//                                   height: 20,
//                                   placeholder: (_, __) =>
//                                       const SizedBox(width: 20),
//                                   errorWidget: (_, __, ___) => const Icon(
//                                       Icons.sports_soccer,
//                                       size: 20,
//                                       color: Colors.grey)),
//                             )
//                           else
//                             const Icon(Icons.sports_soccer,
//                                 size: 20, color: Colors.grey),
//                           const SizedBox(width: 6),
//                           Expanded(
//                               child: Text(player.club?.name ?? "No Club",
//                                   style: const TextStyle(
//                                       fontSize: 14, color: Colors.grey),
//                                   overflow: TextOverflow.ellipsis)),
//                           const SizedBox(width: 8),
//                           Text(
//                               player.country != null
//                                   ? _countryCodeToFlag(player.country)
//                                   : "Unknown",
//                               style: const TextStyle(fontSize: 24)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Icon(Icons.chevron_right, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading)
//       return const Center(
//           child: CircularProgressIndicator(color: Colors.deepPurple));
//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text("Connection Error",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text(errorMessage!,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.grey)),
//             const SizedBox(height: 20),
//             ElevatedButton.icon(
//                 onPressed: loadPlayers,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text("Retry"),
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple)),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//           child: TextField(
//             controller: searchController,
//             decoration: InputDecoration(
//               hintText: "Search players, clubs, countries...",
//               prefixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: Colors.deepPurple.shade50,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none),
//             ),
//           ),
//         ),
//         Expanded(
//           child: filteredPlayers.isEmpty && !isLoading
//               ? const Center(
//                   child: Text("No players match your search",
//                       style: TextStyle(fontSize: 18, color: Colors.grey)))
//               : RefreshIndicator(
//                   onRefresh: loadPlayers,
//                   color: Colors.deepPurple,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
//                     itemCount: filteredPlayers.length,
//                     itemBuilder: (context, i) =>
//                         _buildPlayerCard(filteredPlayers[i]),
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../services/api_service.dart';
// import '../../models/player_model.dart';
// import '../../widgets/player/player_details.dart';

// class AllPlayers extends StatefulWidget {
//   const AllPlayers({Key? key}) : super(key: key);

//   @override
//   State<AllPlayers> createState() => AllPlayersState();
// }

// class AllPlayersState extends State<AllPlayers> {
//   final ApiService api = Get.find<ApiService>();

//   List<PlayerInClub> players = [];
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     loadPlayers();
//   }

//   Future<void> loadPlayers() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final fetchedPlayers = await api.getAllPlayers();
//       setState(() => players = fetchedPlayers);
//     } catch (e) {
//       setState(
//           () => errorMessage = e.toString().replaceFirst("Exception: ", ""));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void handleMenuAction(String action) {
//     switch (action) {
//       case "refresh":
//         loadPlayers();
//         break;
//       case "sort":
//         showSortOptions();
//         break;
//       case "filter":
//         showFilterOptions();
//         break;
//     }
//   }

//   void showSortOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.sort_by_alpha),
//             title: const Text("Name A-Z"),
//             onTap: () {
//               setState(() {
//                 players.sort((a, b) => a.name?.compareTo(b.name ?? "") ?? 0);
//               });
//               Navigator.pop(context);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.confirmation_number),
//             title: const Text("Jersey Number"),
//             onTap: () {
//               setState(() {
//                 players.sort((a, b) =>
//                     (a.jerseyNumber ?? 999).compareTo(b.jerseyNumber ?? 999));
//               });
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void showFilterOptions() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Filter coming soon")),
//     );
//   }

//   Widget _buildPlayerCard(PlayerInClub player) {
//     final photo = player.photo;
//     final name = player.name ?? "Unknown";
//     final jersey = player.jerseyNumber != null ? "#${player.jerseyNumber}" : "";
//     final position = player.position?.name ?? "";

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(12),
//         leading: CircleAvatar(
//           radius: 32,
//           backgroundColor: Colors.deepPurple.shade100,
//           backgroundImage:
//               photo != null ? CachedNetworkImageProvider(photo) : null,
//           child: photo == null
//               ? Text(
//                   name.isNotEmpty ? name[0].toUpperCase() : "?",
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 )
//               : null,
//         ),
//         title: Text(name,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(jersey, style: const TextStyle(fontSize: 15)),
//             if (position.isNotEmpty)
//               Text(position,
//                   style: TextStyle(
//                       color: Colors.deepPurple.shade700,
//                       fontWeight: FontWeight.w600)),
//           ],
//         ),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 18),
//         onTap: () {
//           final fullPlayer = Player.fromPlayerInClub(player);

//           Get.to(
//             () => PlayerDetails(player: fullPlayer),
//             opaque: true,
//             transition: Transition.rightToLeft,
//             curve: Curves.easeInOut,
//             duration: const Duration(milliseconds: 350),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             Text("Error: $errorMessage", textAlign: TextAlign.center),
//             const SizedBox(height: 16),
//             ElevatedButton(onPressed: loadPlayers, child: const Text("Retry")),
//           ],
//         ),
//       );
//     }

//     if (players.isEmpty) {
//       return const Center(
//         child: Text("No players found",
//             style: TextStyle(fontSize: 18, color: Colors.grey)),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: loadPlayers,
//       child: ListView.builder(
//         padding: const EdgeInsets.only(top: 8, bottom: 80),
//         itemCount: players.length,
//         itemBuilder: (context, index) => _buildPlayerCard(players[index]),
//       ),
//     );
//   }
// }











// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/widgets/player/player_details.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';

// class AllPlayers extends StatefulWidget {
//   const AllPlayers({super.key});

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
//   bool _isRefreshing = false;
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
//     _searchDebounce = Timer(const Duration(milliseconds: 300), _filterPlayers);
//   }

//   Future<void> loadPlayers() async {
//     if (_isRefreshing || !mounted) return;
//     _isRefreshing = true;

//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final rawPlayers = await api.getAllPlayers();
//       final players = rawPlayers.map(Player.fromPlayerInClub).toList();

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
//         : allPlayers.where((p) {
//             final name = (p.name ?? "").toLowerCase();
//             final country = (p.country ?? "").toLowerCase();
//             final position = (p.position?.name ?? "").toLowerCase();
//             final club = (p.club?.name ?? "").toLowerCase();
//             return name.contains(query) ||
//                 country.contains(query) ||
//                 position.contains(query) ||
//                 club.contains(query);
//           }).toList();

//     if (!listEquals(newList, filteredPlayers)) {
//       setState(() => filteredPlayers = newList);
//     }
//   }

//   void showSortOptions() {
//     Get.snackbar(
//       "Sort",
//       "Sort options coming soon...",
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   void showFilterOptions() {
//     Get.snackbar(
//       "Filter",
//       "Filter options coming soon...",
//       snackPosition: SnackPosition.BOTTOM,
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
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // required for AutomaticKeepAliveClientMixin

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
//           Expanded(
//             child: isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Colors.deepPurple),
//                   )
//                 : errorMessage != null
//                 ? Center(child: Text("Error: $errorMessage"))
//                 : ListView.builder(
//                     itemCount: filteredPlayers.length,
//                     itemBuilder: (context, index) {
//                       final player = filteredPlayers[index];
//                       final initials = player.initials;

//                       return ListTile(
//                         onTap: () => Get.to(
//                           () => PlayerDetails(player: player),
//                           curve: Curves.bounceOut,
//                           opaque: true,
//                           transition: Transition.rightToLeft,
//                         ),
//                         leading: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: player.photo?.isNotEmpty == true
//                               ? CachedNetworkImage(
//                                   imageUrl: player.photo!,
//                                   width: 70,
//                                   height: 70,
//                                   fit: BoxFit.cover,
//                                   placeholder: (_, __) =>
//                                       _avatarPlaceholder(initials),
//                                   errorWidget: (_, __, ___) =>
//                                       _avatarPlaceholder(initials),
//                                 )
//                               : _avatarPlaceholder(initials),
//                         ),
//                         title: Text(
//                           player.name,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         subtitle: Text(
//                           "${player.position?.name ?? '-'} • ${player.country ?? '-'}",
//                         ),
//                         trailing: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.deepPurple[50],
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             player.club?.name ?? "Free Agent",
//                             style: TextStyle(
//                               color: Colors.deepPurple[800],
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
