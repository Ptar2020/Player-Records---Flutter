import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/player_model.dart';
import '../../widgets/player/player_details.dart';
import '../skeletons/all_players_skeleton.dart';

class AllPlayers extends StatefulWidget {
  const AllPlayers({super.key});

  @override
  State<AllPlayers> createState() => AllPlayersState();
}

class AllPlayersState extends State<AllPlayers> {
  final ApiService api = Get.find<ApiService>();
  final auth = Get.find<AuthService>();
  List<PlayerInClub> players = [];
  List<PlayerInClub> filteredPlayers = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

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
    setState(() => isLoading = true);
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

  // Required by bottom_menu.dart
  void handleMenuAction(String action) {
    if (action == "refresh") {
      loadPlayers();
    }
    // Add sort/filter later if needed
  }


  Widget _buildPlayerCard(PlayerInClub player) {
    final fullPlayer = Player.fromPlayerInClub(player);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Hero(
        tag: "player_${player.id}",
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: Theme.of(context).cardColor,
              child: InkWell(
                onTap: () {
                  print(
                      "Player: ${player.name} - CLUB: ${player.club} AGE ${player.age}"
                      ", COUNTRY :${player.country} - POSITION ${player.position}");
                  print(
                    "FullPayer name: ${fullPlayer.name}, CLUB:${fullPlayer.club?.name}, AGE:${fullPlayer.age}, COUNTRY: ${fullPlayer.country}, POSITION : ${fullPlayer.position?.name}",
                  );
                  Get.to(() => PlayerDetails(player: fullPlayer),
                      transition: Transition.zoom,
                      duration: const Duration(milliseconds: 400));
                },
                // onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
                //     transition: Transition.zoom,
                //     duration: const Duration(milliseconds: 400)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        height: 84,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.deepPurple,
                              backgroundImage: player.photo?.isNotEmpty == true
                                  ? CachedNetworkImageProvider(player.photo!)
                                  : null,
                              child: player.photo?.isNotEmpty != true
                                  ? Text(
                                      fullPlayer.initials,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )
                                  : null,
                            ),
                            if (player.jerseyNumber != null)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: Colors.deepPurple,
                                      shape: BoxShape.circle),
                                  child: Text(
                                    "${player.jerseyNumber}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name ?? "Unknown Player",
                              style: const TextStyle(
                                  fontSize: 17.5, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
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
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepPurple),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (player.club?.logo != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: CachedNetworkImage(
                                      imageUrl: player.club!.logo!,
                                      width: 18,
                                      height: 18,
                                      placeholder: (_, __) =>
                                          const SizedBox(width: 18),
                                      errorWidget: (_, __, ___) => const Icon(
                                          Icons.sports_soccer,
                                          size: 18),
                                    ),
                                  )
                                else
                                  const Icon(Icons.sports_soccer,
                                      size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    player.club?.name ?? "No Club",
                                    style: const TextStyle(
                                        fontSize: 13.5, color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(player.country ?? "Unknown"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      auth.currentUser?.role.toLowerCase() == 'admin'
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.grey),
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirm = await Get.dialog(
                                    AlertDialog(
                                      title: const Text("Delete Player"),
                                      content: Text(
                                          "Delete ${player.name ?? "this player"}?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text("Cancel")),
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          child: const Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      await api.deletePlayer(player.id);
                                      loadPlayers();
                                      Get.snackbar("Success", "Player deleted",
                                          backgroundColor: Colors.green,
                                          colorText: Colors.white);
                                    } catch (e) {
                                      Get.snackbar("Error", e.toString(),
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white);
                                    }
                                  }
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : const Icon(Icons.chevron_right,
                              color: Colors.grey, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const PlayerCardSkeleton(),
      );
    }

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
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search players...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        if (searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Wrap(
              spacing: 6,
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
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
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
