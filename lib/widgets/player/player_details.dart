import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/models/player_model.dart';
import 'package:precords_android/widgets/club/club_details.dart';
import 'package:precords_android/services/api_service.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;

  const PlayerDetails({super.key, required this.player});

  String _countryCodeToFlag(String code) {
    if (code.length < 2) return code;
    final String country = code.substring(0, 2).toUpperCase();
    return country
        .split('')
        .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
        .join();
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
          // === AppBar with Player Name next to back button ===
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

          // === Hero Photo + Jersey Badge ===
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

          // === Info Card (No divider between Position and Age) ===
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
                      // Club
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
                                      .getClubDetailsByName(player.club!.name);
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

                      // Nationality
                      _buildInfoRow(
                        context,
                        icon: Icons.flag,
                        label: "Nationality",
                        value:
                            "${_countryCodeToFlag(player.country)}  ${player.country}",
                        isTablet: isTablet,
                      ),

                      const SizedBox(height: 20),

                      // Position Chip
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

                      // Age
                      _buildInfoRow(context,
                          icon: Icons.cake,
                          label: "Age",
                          value: player.age,
                          isTablet: isTablet),

                      // Gender
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
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/club/club_details.dart';
// import 'package:precords_android/services/api_service.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   // Convert country code (e.g. "KE", "br", "US") → flag emoji
//   String _countryCodeToFlag(String code) {
//     if (code.length < 2) return code;
//     final String country = code.substring(0, 2).toUpperCase();
//     return country
//         .split('')
//         .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
//         .join();
//   }

//   // Contact options bottom sheet
//   void _showContactOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
//       builder: (_) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text("Contact Player",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),
//               if (player.phone?.isNotEmpty == true)
//                 ListTile(
//                   leading: const Icon(Icons.phone, color: Colors.green),
//                   title: const Text("Call"),
//                   subtitle: Text(player.phone!),
//                   onTap: () => Get.back(), // Add url_launcher later
//                 ),
//               if (player.email?.isNotEmpty == true)
//                 ListTile(
//                   leading: const Icon(Icons.email, color: Colors.blue),
//                   title: const Text("Email"),
//                   subtitle: Text(player.email!),
//                   onTap: () => Get.back(), // Add url_launcher later
//                 ),
//               const SizedBox(height: 10),
//               TextButton(
//                   onPressed: () => Get.back(), child: const Text("Close")),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;

//     return Scaffold(
//       floatingActionButton:
//           (player.phone?.isNotEmpty == true || player.email?.isNotEmpty == true)
//               ? FloatingActionButton.extended(
//                   onPressed: () => _showContactOptions(context),
//                   backgroundColor: Colors.deepPurple,
//                   icon: const Icon(Icons.contact_phone),
//                   label: const Text("Contact"),
//                 )
//               : null,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: isTablet ? 340 : 280,
//             pinned: true,
//             backgroundColor: Colors.deepPurple[700],
//             foregroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//               onPressed: () => Get.back(),
//             ),
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(
//                 player.name,
//                 style: TextStyle(
//                     fontSize: isTablet ? 26 : 22, fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                       ),
//                     ),
//                   ),
//                   // Hero Avatar with Jersey Badge
//                   Center(
//                     child: Hero(
//                       tag: "player_${player.id}",
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           CircleAvatar(
//                             radius: isTablet ? 100 : 80,
//                             backgroundColor: Colors.white,
//                             backgroundImage: player.photo != null
//                                 ? CachedNetworkImageProvider(player.photo!)
//                                 : null,
//                             child: player.photo == null
//                                 ? Text(
//                                     player.initials,
//                                     style: TextStyle(
//                                       fontSize: isTablet ? 48 : 36,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.deepPurple,
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                           if (player.jerseyNumber != null)
//                             Positioned(
//                               bottom: 8,
//                               right: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.all(10),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.deepPurple,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                         color: Colors.black26, blurRadius: 6)
//                                   ],
//                                 ),
//                                 child: Text(
//                                   "${player.jerseyNumber}",
//                                   style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: isTablet ? 32 : 16, vertical: 20),
//               child: Card(
//                 elevation: 8,
//                 shadowColor: Colors.deepPurple.withOpacity(0.2),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(28)),
//                 child: Padding(
//                   padding: EdgeInsets.all(isTablet ? 36 : 24),
//                   child: Column(
//                     children: [
//                       // Club
//                       _buildInfoRow(
//                         context,
//                         icon: Icons.people,
//                         label: "Club",
//                         value: player.club?.name ?? "Free Agent",
//                         trailing: player.club?.logo != null
//                             ? ClipRRect(
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: CachedNetworkImage(
//                                   imageUrl: player.club!.logo!,
//                                   width: 40,
//                                   height: 40,
//                                   placeholder: (_, __) =>
//                                       const SizedBox(width: 40),
//                                   errorWidget: (_, __, ___) =>
//                                       const Icon(Icons.sports_soccer, size: 32),
//                                 ),
//                               )
//                             : null,
//                         isInteractive: player.club != null,
//                         onTap: player.club != null
//                             ? () async {
//                                 try {
//                                   Get.dialog(const Center(
//                                       child: CircularProgressIndicator()));
//                                   final fullClub = await Get.find<ApiService>()
//                                       .getClubDetailsByName(player.club!.name);
//                                   Get.back(); // close loading
//                                   Get.to(
//                                       () =>
//                                           ClubDetailsScreen(fullClub: fullClub),
//                                       transition: Transition.rightToLeft);
//                                 } catch (e) {
//                                   Get.back();
//                                   Get.snackbar(
//                                       "Error", "Could not load club details");
//                                 }
//                               }
//                             : null,
//                         isTablet: isTablet,
//                       ),

//                       const Divider(height: 32),

//                       // Nationality with Flag
//                       _buildInfoRow(
//                         context,
//                         icon: Icons.flag,
//                         label: "Nationality",
//                         value:
//                             "${_countryCodeToFlag(player.country)}  ${player.country}",
//                         isTablet: isTablet,
//                       ),

//                       const SizedBox(height: 16),

//                       // Position as Chip
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                                 color: Colors.deepPurple[50],
//                                 borderRadius: BorderRadius.circular(16)),
//                             child: Icon(Icons.sports_soccer,
//                                 color: Colors.deepPurple[700],
//                                 size: isTablet ? 32 : 28),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Position",
//                                     style: TextStyle(
//                                         fontSize: isTablet ? 16 : 14,
//                                         fontWeight: FontWeight.w600,
//                                         color: Colors.grey[700])),
//                                 const SizedBox(height: 8),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 10),
//                                   decoration: BoxDecoration(
//                                     color: Colors.deepPurple.shade100,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     player.position?.shortName ??
//                                         player.position?.name ??
//                                         "Not specified",
//                                     style: TextStyle(
//                                         fontSize: isTablet ? 20 : 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.deepPurple[900]),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),

//                       const Divider(height: 32),

//                       // Age
//                       _buildInfoRow(context,
//                           icon: Icons.cake,
//                           label: "Age",
//                           value: player.age,
//                           isTablet: isTablet),

//                       // Gender
//                       _buildInfoRow(
//                         context,
//                         icon: player.gender?.toLowerCase() == "female"
//                             ? Icons.female
//                             : Icons.male,
//                         label: "Gender",
//                         value: player.gender ?? "Not specified",
//                         isTablet: isTablet,
//                       ),

//                       if (player.phone?.isNotEmpty == true) ...[
//                         const Divider(height: 32),
//                         _buildInfoRow(context,
//                             icon: Icons.phone,
//                             label: "Phone",
//                             value: player.phone!,
//                             isTablet: isTablet),
//                       ],

//                       if (player.email?.isNotEmpty == true) ...[
//                         const Divider(height: 32),
//                         _buildInfoRow(context,
//                             icon: Icons.email,
//                             label: "Email",
//                             value: player.email!,
//                             isTablet: isTablet),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required String value,
//     Widget? trailing,
//     bool isTablet = false,
//     bool isInteractive = false,
//     VoidCallback? onTap,
//   }) {
//     final row = Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//                 color: Colors.deepPurple[50],
//                 borderRadius: BorderRadius.circular(16)),
//             child: Icon(icon,
//                 color: Colors.deepPurple[700], size: isTablet ? 32 : 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: isTablet ? 16 : 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700])),
//                 const SizedBox(height: 6),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: isTablet ? 22 : 19,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87)),
//               ],
//             ),
//           ),
//           if (trailing != null) trailing,
//           if (isInteractive)
//             Icon(Icons.arrow_forward_ios,
//                 size: 18, color: Colors.deepPurple[700]),
//         ],
//       ),
//     );

//     return isInteractive
//         ? InkWell(
//             onTap: onTap, borderRadius: BorderRadius.circular(16), child: row)
//         : row;
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/club/club_details.dart';
// import 'package:precords_android/services/api_service.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;

//     return Scaffold(
//       body: SafeArea(
//         child: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               expandedHeight: isTablet ? 320 : 260,
//               pinned: true,
//               backgroundColor: Colors.deepPurple[700],
//               foregroundColor: Colors.white,
//               elevation: 0,
//               centerTitle: true,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//                 onPressed: () => Get.back(),
//               ),
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Text(
//                   player.name,
//                   style: TextStyle(
//                     fontSize: isTablet ? 24 : 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 0.5,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 background: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.deepPurple[700]!,
//                             Colors.deepPurple[900]!
//                           ],
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                         ),
//                       ),
//                     ),
//                     Hero(
//                       tag: "player_${player.id}",
//                       child: CircleAvatar(
//                         radius: isTablet ? 100 : 70,
//                         backgroundColor: Colors.white,
//                         backgroundImage: player.photo != null
//                             ? NetworkImage(player.photo!)
//                             : null,
//                         child: player.photo == null
//                             ? Text(
//                                 player.initials,
//                                 style: TextStyle(
//                                   fontSize: isTablet ? 48 : 32,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple,
//                                 ),
//                               )
//                             : null,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Floating Jersey Badge
//             if (player.jerseyNumber != null)
//               SliverToBoxAdapter(
//                 child: Center(
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 12, bottom: 20),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 24, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.deepPurple[100],
//                       borderRadius: BorderRadius.circular(50),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       "#${player.jerseyNumber}",
//                       style: TextStyle(
//                         fontSize: isTablet ? 32 : 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple[900],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             // Info Card
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: isTablet ? 32 : 16, vertical: 8),
//                 child: Card(
//                   elevation: 6,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(isTablet ? 32 : 20),
//                     child: Column(
//                       children: [
//                         _buildInfoRow(
//                           context,
//                           icon: Icons.people,
//                           label: "Club",
//                           value: player.club?.name ?? "Free Agent",
//                           isInteractive: player.club != null,
//                           onTap: player.club != null
//                               ? () async {
//                                   final fullClub = await Get.find<ApiService>()
//                                       .getClubDetailsByName(player.club!.name);
//                                   Get.to(
//                                     () => ClubDetailsScreen(fullClub: fullClub),
//                                     opaque: true,
//                                     transition: Transition.rightToLeft,
//                                     curve: Curves.easeInOut,
//                                     duration: const Duration(milliseconds: 350),
//                                   );
//                                 }
//                               : null,
//                           isTablet: isTablet,
//                         ),
//                         const Divider(color: Colors.grey, height: 22),
//                         _buildInfoRow(
//                           context,
//                           icon: Icons.flag,
//                           label: "Nationality",
//                           value: player.country,
//                           isTablet: isTablet,
//                         ),
//                         _buildInfoRow(
//                           context,
//                           icon: Icons.sports_soccer,
//                           label: "Position",
//                           value: player.position?.name ?? "Not specified",
//                           isTablet: isTablet,
//                         ),
//                         _buildInfoRow(
//                           context,
//                           icon: Icons.cake,
//                           label: "Age",
//                           value: player.age,
//                           isTablet: isTablet,
//                         ),
//                         _buildInfoRow(
//                           context,
//                           icon: player.gender?.toLowerCase() == "female"
//                               ? Icons.female
//                               : Icons.male,
//                           label: "Gender",
//                           value: player.gender ?? "Not specified",
//                           isTablet: isTablet,
//                         ),
//                         if (player.phone?.isNotEmpty == true)
//                           _buildInfoRow(
//                             context,
//                             icon: Icons.phone,
//                             label: "Phone",
//                             value: player.phone!,
//                             isTablet: isTablet,
//                           ),
//                         if (player.email?.isNotEmpty == true)
//                           _buildInfoRow(
//                             context,
//                             icon: Icons.email,
//                             label: "Email",
//                             value: player.email!,
//                             isTablet: isTablet,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SliverToBoxAdapter(child: SizedBox(height: 40)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required String value,
//     bool isTablet = false,
//     bool isInteractive = false,
//     VoidCallback? onTap,
//   }) {
//     final row = Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.deepPurple[50],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(icon,
//                 color: Colors.deepPurple[700], size: isTablet ? 32 : 26),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: isTablet ? 16 : 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700])),
//                 const SizedBox(height: 4),
//                 Text(value,
//                     style: TextStyle(
//                         fontSize: isTablet ? 22 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: isInteractive
//                             ? Colors.deepPurple[900]
//                             : Colors.black87)),
//               ],
//             ),
//           ),
//           if (isInteractive)
//             Icon(Icons.arrow_forward_ios,
//                 size: 18, color: Colors.deepPurple[700]),
//         ],
//       ),
//     );

//     return isInteractive
//         ? InkWell(
//             borderRadius: BorderRadius.circular(16),
//             onTap: onTap,
//             splashColor: Colors.deepPurple.withOpacity(0.1),
//             child: row,
//           )
//         : row;
//   }
// }










// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/club/club_details.dart';
// import 'package:precords_android/services/api_service.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final photoRadius = isTablet ? 110.0 : 85.0;

//     final String initial =
//         player.name.isNotEmpty ? player.name[0].toUpperCase() : "?";
//     final bool hasPhoto = player.photo?.isNotEmpty == true;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.deepPurple[700],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           player.name,
//           style: TextStyle(
//             fontSize: isTablet ? 28 : 24, // BIGGER & BOLDER
//             fontWeight: FontWeight.bold,
//             letterSpacing: 0.5,
//           ),
//         ),
//       ),
//       body: CustomScrollView(
//         slivers: [
//           // HERO PHOTO
//           SliverToBoxAdapter(
//             child: Container(
//               padding: const EdgeInsets.only(top: 20, bottom: 30),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
//                 ),
//               ),
//               child: Center(
//                 child: Hero(
//                   tag: "player_${player.id}",
//                   child: CircleAvatar(
//                     radius: photoRadius,
//                     backgroundColor: Colors.white,
//                     child: CircleAvatar(
//                       radius: photoRadius - 4,
//                       backgroundImage:
//                           hasPhoto ? NetworkImage(player.photo!) : null,
//                       child: !hasPhoto
//                           ? Text(
//                               initial,
//                               style: TextStyle(
//                                 fontSize: photoRadius * 0.9,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.deepPurple,
//                               ),
//                             )
//                           : null,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // JERSEY NUMBER
//           if (player.jerseyNumber != null)
//             SliverToBoxAdapter(
//               child: Center(
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 28,
//                     vertical: 14,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.deepPurple[100],
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Text(
//                     "#${player.jerseyNumber}",
//                     style: TextStyle(
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple[900],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // INFO CARD
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.all(isTablet ? 32 : 20),
//               child: Card(
//                 elevation: 12,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(28),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(isTablet ? 32 : 24),
//                   child: Column(
//                     children: [
//                       // CLUB ROW — YOUR PREFERRED CLEAN STYLE
//                       if (player.club != null)
//                         Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(16),
//                             onTap: () async {
//                               final fullClub = await Get.find<ApiService>()
//                                   .getClubDetailsByName(player.club!.name);
//                               Get.to(
//                                 () => ClubDetailsScreen(fullClub: fullClub),
//                                 opaque: true,
//                                 transition: Transition.rightToLeft,
//                                 curve: Curves.easeInOut,
//                                 duration: const Duration(milliseconds: 350),
//                               );
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 18),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(14),
//                                     decoration: BoxDecoration(
//                                       color: Colors.deepPurple[50],
//                                       borderRadius: BorderRadius.circular(16),
//                                     ),
//                                     child: Icon(
//                                       Icons.people,
//                                       color: Colors.deepPurple[700],
//                                       size: isTablet ? 32 : 26,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 20),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Club",
//                                           style: TextStyle(
//                                             fontSize: isTablet ? 16 : 14,
//                                             color: Colors.grey[600],
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           player.club!.name,
//                                           style: TextStyle(
//                                             fontSize: isTablet ? 22 : 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.deepPurple[900],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.arrow_forward_ios,
//                                     size: 18,
//                                     color: Colors.deepPurple[700],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                       else
//                         _buildInfoRow(
//                           Icons.people,
//                           "Club",
//                           "Free Agent",
//                           isTablet,
//                         ),

//                       const Divider(
//                         height: 22,
//                         thickness: 1,
//                         color: Colors.grey,
//                       ),

//                       _buildInfoRow(
//                         Icons.flag,
//                         "Nationality",
//                         player.country,
//                         isTablet,
//                       ),
//                       _buildInfoRow(
//                         Icons.sports_soccer,
//                         "Position",
//                         player.position?.name ?? "Not specified",
//                         isTablet,
//                       ),
//                       _buildInfoRow(Icons.cake, "Age", player.age, isTablet),
//                       _buildInfoRow(
//                         player.gender?.toLowerCase() == "female"
//                             ? Icons.female
//                             : Icons.male,
//                         "Gender",
//                         player.gender?.capitalize ?? "Not specified",
//                         isTablet,
//                       ),
//                       if (player.phone?.isNotEmpty == true)
//                         _buildInfoRow(
//                           Icons.phone,
//                           "Phone",
//                           player.phone!,
//                           isTablet,
//                         ),
//                       if (player.email?.isNotEmpty == true)
//                         _buildInfoRow(
//                           Icons.email,
//                           "Email",
//                           player.email!,
//                           isTablet,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const SliverToBoxAdapter(child: SizedBox(height: 40)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(
//     IconData icon,
//     String label,
//     String value,
//     bool isTablet,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.deepPurple[50],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.deepPurple[700],
//               size: isTablet ? 32 : 26,
//             ),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: isTablet ? 16 : 14,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: isTablet ? 22 : 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
