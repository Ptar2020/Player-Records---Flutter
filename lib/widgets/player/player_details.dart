import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/models/player_model.dart';
import 'package:precords_android/widgets/club/club_details.dart';
import 'package:precords_android/services/api_service.dart';
import '../../forms/player_form.dart';

class PlayerDetails extends StatefulWidget {
  final Player player; // ← Back to 'player' to match all existing calls

  const PlayerDetails({super.key, required this.player});

  @override
  State<PlayerDetails> createState() => _PlayerDetailsState();
}

class _PlayerDetailsState extends State<PlayerDetails> {
  late Player player;

  @override
  void initState() {
    super.initState();
    player = widget.player;
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Contact Player",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              if (player.phone?.isNotEmpty == true)
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text("Call"),
                  subtitle: Text(player.phone!),
                  onTap: () => Get.back(),
                ),
              if (player.email?.isNotEmpty == true)
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text("Email"),
                  subtitle: Text(player.email!),
                  onTap: () => Get.back(),
                ),
              const SizedBox(height: 10),
              TextButton(
                  onPressed: () => Get.back(), child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => PlayerForm(mode: PlayerFormMode.edit, player: player),
    ).then((updatedPlayer) {
      if (updatedPlayer is Player) {
        setState(() {
          player = updatedPlayer;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      floatingActionButton:
          (player.phone?.isNotEmpty == true || player.email?.isNotEmpty == true)
              ? FloatingActionButton.extended(
                  onPressed: () => _showContactOptions(context),
                  backgroundColor: Colors.deepPurple,
                  icon: const Icon(Icons.contact_phone),
                  label: const Text("Contact"),
                )
              : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.deepPurple[700],
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Get.back(),
            ),
            title: Row(
              children: [
                if (player.photo != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: CachedNetworkImageProvider(player.photo!),
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      player.initials,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _openEditModal(context),
                ),
                if (player.jerseyNumber != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "#${player.jerseyNumber}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Hero(
                tag: "player_${player.id}",
                child: Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black45,
                          blurRadius: 16,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: isTablet ? 100 : 80,
                        backgroundColor: Colors.white,
                        backgroundImage: player.photo != null
                            ? CachedNetworkImageProvider(player.photo!)
                            : null,
                        child: player.photo == null
                            ? Text(
                                player.initials,
                                style: TextStyle(
                                  fontSize: isTablet ? 48 : 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              )
                            : null,
                      ),
                      if (player.jerseyNumber != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 6)
                              ],
                            ),
                            child: Text(
                              "${player.jerseyNumber}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 16, vertical: 12),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 20),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: Icons.people,
                        label: "Club",
                        value: player.club?.name ?? "Free Agent",
                        trailing: player.club?.logo != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: player.club!.logo!,
                                  width: 40,
                                  height: 40,
                                  placeholder: (_, __) =>
                                      const SizedBox(width: 40),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.sports_soccer, size: 32),
                                ),
                              )
                            : null,
                        isInteractive: player.club != null,
                        onTap: player.club != null
                            ? () async {
                                try {
                                  Get.dialog(const Center(
                                      child: CircularProgressIndicator()));
                                  final fullClub = await Get.find<ApiService>()
                                      .getClubDetailsById(player.club!.id);
                                  Get.back();
                                  Get.to(() =>
                                      ClubDetailsScreen(fullClub: fullClub));
                                } catch (e) {
                                  Get.back();
                                  Get.snackbar(
                                      "Error", "Could not load club details");
                                }
                              }
                            : null,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        context,
                        icon: Icons.flag,
                        label: "Nationality",
                        value: player.country,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                borderRadius: BorderRadius.circular(16)),
                            child: Icon(Icons.sports_soccer,
                                color: Colors.deepPurple[700],
                                size: isTablet ? 32 : 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Position",
                                    style: TextStyle(
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700])),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.deepPurple.shade100,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    player.position?.shortName ??
                                        player.position?.name ??
                                        "Not specified",
                                    style: TextStyle(
                                        fontSize: isTablet ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple[900]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(context,
                          icon: Icons.cake,
                          label: "Age",
                          value: player.age?.toString() ?? "Not specified",
                          isTablet: isTablet),
                      _buildInfoRow(
                        context,
                        icon: player.gender?.toLowerCase() == "female"
                            ? Icons.female
                            : Icons.male,
                        label: "Gender",
                        value: player.gender ?? "Not specified",
                        isTablet: isTablet,
                      ),
                      if (player.phone?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        _buildInfoRow(context,
                            icon: Icons.phone,
                            label: "Phone",
                            value: player.phone!,
                            isTablet: isTablet),
                      ],
                      if (player.email?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        _buildInfoRow(context,
                            icon: Icons.email,
                            label: "Email",
                            value: player.email!,
                            isTablet: isTablet),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
    bool isTablet = false,
    bool isInteractive = false,
    VoidCallback? onTap,
  }) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon,
                color: Colors.deepPurple[700], size: isTablet ? 32 : 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700])),
                const SizedBox(height: 6),
                Text(value,
                    style: TextStyle(
                        fontSize: isTablet ? 22 : 19,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (trailing != null) trailing,
          if (isInteractive)
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.deepPurple),
        ],
      ),
    );

    return isInteractive
        ? InkWell(
            onTap: onTap, borderRadius: BorderRadius.circular(16), child: row)
        : row;
  }
}



