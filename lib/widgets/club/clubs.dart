import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/widgets/refreshable_page.dart';
import 'package:precords_android/widgets/skeletons/clubs_skeleton.dart';
import 'club_details.dart';

class Clubs extends StatefulWidget {
  const Clubs({super.key});

  @override
  State<Clubs> createState() => ClubsState();
}

class ClubsState extends State<Clubs> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final api = Get.find<ApiService>();
  final auth = Get.find<AuthService>();
  late Future<List<ClubModel>> clubsFuture;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void handleMenuAction(String action) {
    if (action == "refresh") {
      refresh();
    }
  }

  Future<void> refresh() async {
    setState(() {
      clubsFuture = api.getAllClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshablePage(
      onRefresh: refresh,
      child: FutureBuilder<List<ClubModel>>(
        future: clubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 8,
              itemBuilder: (_, __) => const ClubCardSkeleton(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  const Text("Error loading clubs"),
                  const SizedBox(height: 8),
                  Text("${snapshot.error}",
                      style: TextStyle(color: Colors.red.shade400)),
                ],
              ),
            );
          }

          final clubs = snapshot.data ?? [];
          if (clubs.isEmpty) {
            return const Center(child: Text("No clubs found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clubs.length,
            itemBuilder: (context, index) {
              final club = clubs[index];
              final initial = club.shortName?.trim().isNotEmpty == true
                  ? club.shortName!.trim()[0].toUpperCase()
                  : "?";

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () async {
                    try {
                      final fullClub = await api.getClubDetailsById(club.id);
                      Get.to(() => ClubDetailsScreen(fullClub: fullClub),
                          transition: Transition.rightToLeft);
                      print("${fullClub.name}");
                    } catch (e) {
                      Get.snackbar("Error", "Failed to load club details",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                  leading: Hero(
                    tag: "club_${club.id}", // Use _id for hero tag
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.deepPurple.shade100,
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: club.logo?.isNotEmpty == true
                            ? CachedNetworkImageProvider(club.logo!)
                            : null,
                        child: club.logo?.isNotEmpty != true
                            ? Text(initial,
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.deepPurple))
                            : null,
                      ),
                    ),
                  ),
                  title: Text(club.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      "${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}"),
                  trailing: Chip(
                    backgroundColor: Colors.deepPurple.shade100,
                    label: Text("${club.playersCount ?? 0} players",
                        style: TextStyle(
                            color: Colors.deepPurple.shade800,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
