import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/models/player_model.dart';
import 'package:precords_android/widgets/club/clubs.dart';
import 'package:precords_android/widgets/player/player_details.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/forms/club_form.dart';
import 'package:precords_android/widgets/bottom_menu.dart';

class ClubDetailsScreen extends StatelessWidget {
  final ClubModel fullClub;

  const ClubDetailsScreen({super.key, required this.fullClub});

  String _countryCodeToFlag(String code) {
    if (code.length < 2) return code;
    final c = code.substring(0, 2).toUpperCase();
    return c
        .split('')
        .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
        .join();
  }

  int get _playerCount =>
      fullClub.players?.length ?? fullClub.playersCount ?? 0;

  void _deleteClub(BuildContext context) async {
    final auth = Get.find<AuthService>();
    final api = Get.find<ApiService>();

    if (auth.currentUser?.role.toLowerCase() != 'admin') return;

    if (_playerCount > 0) {
      Get.snackbar(
        "Cannot Delete",
        "Club has $_playerCount player(s). Remove or transfer them first.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Delete Club"),
        content:
            Text("Deleting ${fullClub.name} cannot be undone. Are you sure?"),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await api.deleteClub(fullClub.id);
      Get.back();

      // Show success message
      Get.snackbar("Success", "Club deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2));

      // Get.back();

      // Refresh the Clubs list after a tiny delay to ensure navigation completed
      Future.delayed(const Duration(milliseconds: 15), () {
        Get.back(); //I doubt if working
        clubsGlobalKey.currentState?.refresh();
      });
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    print(
        'ClubDetails received club: ${fullClub.name} (ID: ${fullClub.id}), Players: ${fullClub.players?.length ?? 0}');
    final isTablet = MediaQuery.of(context).size.width > 600;
    final auth = Get.find<AuthService>();
    final isAdmin = auth.currentUser?.role.toLowerCase() == 'admin';
    final canDelete = isAdmin && _playerCount == 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Row(
              children: [
                if (fullClub.logo?.isNotEmpty == true)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: fullClub.logo!,
                      width: 32,
                      height: 32,
                      placeholder: (_, __) => const SizedBox(width: 32),
                    ),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fullClub.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'delete') {
                    _deleteClub(context);
                  } else if (value == 'edit' && isAdmin) {
                    Get.bottomSheet(
                      ClubForm(mode: ClubFormMode.edit, club: fullClub),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                    ).then((result) async {
                      if (result == true || result is ClubModel) {
                        try {
                          final freshClub = await Get.find<ApiService>()
                              .getClubDetailsById(fullClub.id);
                          Get.off(() => ClubDetailsScreen(fullClub: freshClub));
                          clubsGlobalKey.currentState?.refresh();
                        } catch (e) {
                          Get.snackbar("Error", "Failed to reload club",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          Get.back();
                          clubsGlobalKey.currentState?.refresh();
                        }
                      }
                    });
                  }
                },
                itemBuilder: (_) => [
                  if (canDelete)
                    const PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 12),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  if (isAdmin)
                    const PopupMenuItem(
                      value: "edit",
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 12),
                          Text("Edit"),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: "share",
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 12),
                        Text("Share"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Hero logo
          SliverToBoxAdapter(
            child: Center(
              child: Hero(
                tag: "club_${fullClub.id}",
                child: Container(
                  margin: const EdgeInsets.only(top: 16, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: isTablet ? 60 : 48,
                    backgroundColor: Colors.white,
                    backgroundImage: fullClub.logo?.isNotEmpty == true
                        ? CachedNetworkImageProvider(fullClub.logo!)
                        : null,
                    child: fullClub.logo?.isNotEmpty != true
                        ? Text(
                            fullClub.name.isNotEmpty
                                ? fullClub.name[0].toUpperCase()
                                : "C",
                            style: TextStyle(
                                fontSize: isTablet ? 44 : 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Compact info card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _compactInfo(Icons.flag,
                          "${_countryCodeToFlag(fullClub.country ?? "??")} ${fullClub.country ?? "—"}"),
                      _compactInfo(Icons.emoji_events, fullClub.level ?? "—"),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SQUAD header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    "PLAYERS",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[900],
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(
                      "$_playerCount",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Players list
          fullClub.players == null || fullClub.players!.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(60),
                    child: Center(
                      child: Text("No players in squad",
                          style:
                              TextStyle(fontSize: 17, color: Colors.grey[600])),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = fullClub.players![index];
                      final fullPlayer = Player.fromPlayerInClub(p);
                      return _compactPlayerCard(p, fullPlayer, isTablet);
                    },
                    childCount: fullClub.players!.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _compactPlayerCard(PlayerInClub p, Player fullPlayer, bool isTablet) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
          transition: Transition.zoom),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.deepPurple.shade50,
                    backgroundImage: p.photo?.isNotEmpty == true
                        ? CachedNetworkImageProvider(p.photo!)
                        : null,
                    child: p.photo?.isNotEmpty != true
                        ? Text(fullPlayer.initials,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple))
                        : null,
                  ),
                  if (p.jerseyNumber != null)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.deepPurple, shape: BoxShape.circle),
                        child: Text("${p.jerseyNumber}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 16.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (p.age?.isNotEmpty == true) ...[
                          Text(p.age!,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                          const Text(" • ",
                              style: TextStyle(color: Colors.grey)),
                        ],
                        if (p.position?.name != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.deepPurple.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              p.position!.shortName ?? p.position!.name,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple[900]),
                            ),
                          ),
                        if (p.country != null) ...[
                          const Text(" • ",
                              style: TextStyle(color: Colors.grey)),
                          Text(_countryCodeToFlag(p.country!),
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _compactInfo(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple[700], size: 28),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
      ],
    );
  }
}
