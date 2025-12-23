import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/models/player_model.dart';
import 'package:precords_android/widgets/player/player_details.dart';

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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
                onSelected: (_) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: "share", child: Text("Share")),
                  const PopupMenuItem(value: "edit", child: Text("Edit")),
                ],
              ),
            ],
          ),
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
                          offset: const Offset(0, 6))
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    "SQUAD",
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
                      // FIXED: Removed the named 'club' parameter
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


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/player/player_details.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   const ClubDetailsScreen({super.key, required this.fullClub});

//   String _countryCodeToFlag(String code) {
//     if (code.length < 2) return code;
//     Player.fromPlayerInClub(p);
//     final c = code.substring(0, 2).toUpperCase();
//     return c
//         .split('')
//         .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
//         .join();
//   }

//   int get _playerCount =>
//       fullClub.players?.length ?? fullClub.playersCount ?? 0;

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // === Compact AppBar with Club Name next to back button ===
//           SliverAppBar(
//             pinned: true,
//             backgroundColor: Colors.deepPurple,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, size: 20),
//               onPressed: () => Get.back(),
//             ),
//             title: Row(
//               children: [
//                 if (fullClub.logo?.isNotEmpty == true)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: CachedNetworkImage(
//                       imageUrl: fullClub.logo!,
//                       width: 32,
//                       height: 32,
//                       placeholder: (_, __) => const SizedBox(width: 32),
//                     ),
//                   ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     fullClub.name,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert),
//                 onSelected: (_) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(value: "share", child: Text("Share")),
//                   const PopupMenuItem(value: "edit", child: Text("Edit")),
//                 ],
//               ),
//             ],
//           ),

//           // === Floating Hero Logo (still there, but smaller) ===
//           SliverToBoxAdapter(
//             child: Center(
//               child: Hero(
//                 tag: "club_${fullClub.id}",
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 16, bottom: 8),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 12,
//                           offset: const Offset(0, 6))
//                     ],
//                   ),
//                   child: CircleAvatar(
//                     radius: isTablet ? 60 : 48,
//                     backgroundColor: Colors.white,
//                     backgroundImage: fullClub.logo?.isNotEmpty == true
//                         ? CachedNetworkImageProvider(fullClub.logo!)
//                         : null,
//                     child: fullClub.logo?.isNotEmpty != true
//                         ? Text(
//                             fullClub.name.isNotEmpty
//                                 ? fullClub.name[0].toUpperCase()
//                                 : "C",
//                             style: TextStyle(
//                                 fontSize: isTablet ? 44 : 36,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.deepPurple),
//                           )
//                         : null,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // === Compact Club Info ===
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Card(
//                 elevation: 5,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _compactInfo(Icons.flag,
//                           "${_countryCodeToFlag(fullClub.country ?? "??")} ${fullClub.country ?? "—"}"),
//                       _compactInfo(Icons.emoji_events, fullClub.level ?? "—"),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // === SQUAD • 23 ===
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Row(
//                 children: [
//                   Text(
//                     "SQUAD",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple[900],
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                         color: Colors.deepPurple.shade100,
//                         borderRadius: BorderRadius.circular(16)),
//                     child: Text(
//                       "$_playerCount",
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.deepPurple[900]),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // === Compact Player List with Stats ===
//           fullClub.players == null || fullClub.players!.isEmpty
//               ? SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(60),
//                     child: Center(
//                       child: Text("No players in squad",
//                           style:
//                               TextStyle(fontSize: 17, color: Colors.grey[600])),
//                     ),
//                   ),
//                 )
//               : SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final p = fullClub.players![index];
//                       final fullPlayer =
//                           Player.fromPlayerInClub(p);
//                       return _compactPlayerCard(p, fullPlayer, isTablet);
//                     },
//                     childCount: fullClub.players!.length,
//                   ),
//                 ),

//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),
//     );
//   }

//   // === Super Compact Player Card with Stats ===
//   Widget _compactPlayerCard(PlayerInClub p, Player fullPlayer, bool isTablet) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(16),
//       onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
//           transition: Transition.zoom),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // Avatar + Jersey
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 36,
//                     backgroundColor: Colors.deepPurple.shade50,
//                     backgroundImage: p.photo?.isNotEmpty == true
//                         ? CachedNetworkImageProvider(p.photo!)
//                         : null,
//                     child: p.photo?.isNotEmpty != true
//                         ? Text(fullPlayer.initials,
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.deepPurple))
//                         : null,
//                   ),
//                   if (p.jerseyNumber != null)
//                     Positioned(
//                       bottom: -2,
//                       right: -2,
//                       child: Container(
//                         padding: const EdgeInsets.all(5),
//                         decoration: const BoxDecoration(
//                             color: Colors.deepPurple, shape: BoxShape.circle),
//                         child: Text("${p.jerseyNumber}",
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold)),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 12),

//               // Name + Stats
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       p.name ?? "Unknown",
//                       style: const TextStyle(
//                           fontSize: 16.5, fontWeight: FontWeight.bold),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Stats Row: Age • Position • Country
//                     Row(
//                       children: [
//                         if (p.age?.isNotEmpty == true) ...[
//                           Text(p.age!,
//                               style: const TextStyle(
//                                   fontSize: 13, color: Colors.grey)),
//                           const Text(" • ",
//                               style: TextStyle(color: Colors.grey)),
//                         ],
//                         if (p.position?.name != null)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                                 color: Colors.deepPurple.shade100,
//                                 borderRadius: BorderRadius.circular(10)),
//                             child: Text(
//                               p.position!.shortName ?? p.position!.name,
//                               style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.deepPurple[900]),
//                             ),
//                           ),
//                         if (p.country != null) ...[
//                           const Text(" • ",
//                               style: TextStyle(color: Colors.grey)),
//                           Text(_countryCodeToFlag(p.country!),
//                               style: const TextStyle(fontSize: 18)),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _compactInfo(IconData icon, String value) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.deepPurple[700], size: 28),
//         const SizedBox(height: 6),
//         Text(value,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//             textAlign: TextAlign.center),
//       ],
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/player/player_details.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   const ClubDetailsScreen({super.key, required this.fullClub});

//   String _countryCodeToFlag(String code) {
//     if (code.length < 2) return code;
//     final c = code.substring(0, 2).toUpperCase();
//     return c
//         .split('')
//         .map((l) => String.fromCharCode(0x1F1E6 + l.codeUnitAt(0) - 65))
//         .join();
//   }

//   int get _playerCount =>
//       fullClub.players?.length ?? fullClub.playersCount ?? 0;

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // Header (unchanged - beautiful)
//           SliverAppBar(
//             expandedHeight: isTablet ? 320 : 260,
//             pinned: true,
//             backgroundColor: Colors.deepPurple,
//             foregroundColor: Colors.white,
//             elevation: 0,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new),
//               onPressed: () => Get.back(),
//             ),
//             actions: [
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.more_vert),
//                 onSelected: (_) {},
//                 itemBuilder: (_) => [
//                   const PopupMenuItem(
//                       value: "share", child: Text("Share Club")),
//                   const PopupMenuItem(value: "edit", child: Text("Edit Club")),
//                 ],
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(fullClub.name,
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Color(0xFF6A1B9A), Color(0xFF311B92)],
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Hero(
//                       tag: "club_${fullClub.id}",
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                                 color: Colors.black45,
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10)),
//                           ],
//                         ),
//                         child: CircleAvatar(
//                           radius: isTablet ? 90 : 70,
//                           backgroundColor: Colors.white,
//                           backgroundImage: fullClub.logo?.isNotEmpty == true
//                               ? CachedNetworkImageProvider(fullClub.logo!)
//                               : null,
//                           child: fullClub.logo?.isNotEmpty != true
//                               ? Text(
//                                   fullClub.name.isNotEmpty
//                                       ? fullClub.name[0].toUpperCase()
//                                       : "C",
//                                   style: TextStyle(
//                                       fontSize: isTablet ? 60 : 48,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.deepPurple),
//                                 )
//                               : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Club Info Card (removed player count)
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: isTablet ? 32 : 16, vertical: 20),
//               child: Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(28)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     children: [
//                       _infoRow(
//                           Icons.flag,
//                           "Country",
//                           "${_countryCodeToFlag(fullClub.country ?? "??")}  ${fullClub.country ?? "Unknown"}",
//                           isTablet),
//                       const SizedBox(height: 20),
//                       _infoRow(Icons.location_city, "City",
//                           fullClub.city ?? "Not specified", isTablet),
//                       const SizedBox(height: 20),
//                       _infoRow(Icons.emoji_events, "Level",
//                           fullClub.level ?? "Unknown", isTablet),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // SQUAD • 23
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
//               child: Row(
//                 children: [
//                   Text(
//                     "SQUAD",
//                     style: TextStyle(
//                       fontSize: isTablet ? 30 : 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.deepPurple[900],
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.deepPurple.shade100,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       "$_playerCount",
//                       style: TextStyle(
//                         fontSize: isTablet ? 18 : 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple[900],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Vertical Player List (No overflow, smaller fonts)
//           fullClub.players == null || fullClub.players!.isEmpty
//               ? SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.all(60),
//                     child: Center(
//                       child: Column(
//                         children: [
//                           Icon(Icons.sentiment_dissatisfied,
//                               size: 80, color: Colors.grey[400]),
//                           const SizedBox(height: 16),
//                           Text("No players in squad",
//                               style: TextStyle(
//                                   fontSize: 18, color: Colors.grey[600])),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               : SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final p = fullClub.players![index];
//                       final fullPlayer =
//                           Player.fromPlayerInClub(p, club: fullClub);

//                       return Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 6),
//                         child: _playerCard(p, fullPlayer, isTablet),
//                       );
//                     },
//                     childCount: fullClub.players!.length,
//                   ),
//                 ),

//           const SliverToBoxAdapter(child: SizedBox(height: 100)),
//         ],
//       ),
//     );
//   }

//   // Fixed player card — no overflow, smaller fonts
//   Widget _playerCard(PlayerInClub p, Player fullPlayer, bool isTablet) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () => Get.to(() => PlayerDetails(player: fullPlayer),
//           transition: Transition.zoom,
//           duration: const Duration(milliseconds: 400)),
//       child: Card(
//         elevation: 6,
//         shadowColor: Colors.deepPurple.withOpacity(0.2),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Row(
//             children: [
//               // Avatar + Jersey
//               Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: isTablet ? 44 : 38,
//                     backgroundColor: Colors.deepPurple.shade50,
//                     backgroundImage: p.photo?.isNotEmpty == true
//                         ? CachedNetworkImageProvider(p.photo!)
//                         : null,
//                     child: p.photo?.isNotEmpty != true
//                         ? Text(
//                             fullPlayer.initials,
//                             style: TextStyle(
//                                 fontSize: isTablet ? 24 : 20,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.deepPurple),
//                           )
//                         : null,
//                   ),
//                   if (p.jerseyNumber != null)
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.all(5),
//                         decoration: const BoxDecoration(
//                             color: Colors.deepPurple, shape: BoxShape.circle),
//                         child: Text(
//                           "${p.jerseyNumber}",
//                           style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(width: 14),

//               // Name, Position, Country — smaller & balanced
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       p.name ?? "Unknown Player",
//                       style: TextStyle(
//                           fontSize: isTablet ? 18 : 16.5,
//                           fontWeight: FontWeight.bold),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     if (p.position?.name != null)
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 4),
//                         decoration: BoxDecoration(
//                             color: Colors.deepPurple.shade100,
//                             borderRadius: BorderRadius.circular(12)),
//                         child: Text(
//                           p.position!.shortName ?? p.position!.name,
//                           style: TextStyle(
//                               color: Colors.deepPurple[900],
//                               fontWeight: FontWeight.w600,
//                               fontSize: 12.5),
//                         ),
//                       ),
//                     const SizedBox(height: 6),
//                     Row(
//                       children: [
//                         Text(
//                           p.country != null
//                               ? _countryCodeToFlag(p.country!)
//                               : "Unknown",
//                           style: const TextStyle(fontSize: 22),
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             p.country ?? "Unknown",
//                             style: TextStyle(
//                                 fontSize: 13.5, color: Colors.grey[700]),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String label, String value, bool isTablet) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//               color: Colors.deepPurple.shade100,
//               borderRadius: BorderRadius.circular(16)),
//           child: Icon(icon,
//               color: Colors.deepPurple[700], size: isTablet ? 32 : 28),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       fontSize: isTablet ? 16 : 14,
//                       color: Colors.grey[600],
//                       fontWeight: FontWeight.w600)),
//               const SizedBox(height: 4),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: isTablet ? 22 : 18,
//                       fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }











// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player_model.dart';
// import 'package:precords_android/widgets/player/player_details.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;
//   final double headerFontSize;
//   final Color headerColor;

//   const ClubDetailsScreen({
//     super.key,
//     required this.fullClub,
//     this.headerFontSize = 20,
//     this.headerColor = Colors.black87,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert),
//             onSelected: (value) {
//               // Future actions: share, edit
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(value: "share", child: Text("Share Club")),
//               const PopupMenuItem(value: "edit", child: Text("Edit Club")),
//             ],
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ===== Banner =====
//             Stack(
//               children: [
//                 Container(
//                   height: isTablet ? 200 : 140,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(
//                       bottom: Radius.circular(42),
//                     ),
//                     image: fullClub.logo != null && fullClub.logo!.isNotEmpty
//                         ? DecorationImage(
//                             image: CachedNetworkImageProvider(fullClub.logo!),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                     color: Colors.deepPurple.shade200,
//                   ),
//                 ),
//                 Container(
//                   height: isTablet ? 300 : 200,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(
//                       bottom: Radius.circular(32),
//                     ),
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.deepPurple.withOpacity(0.2),
//                         Colors.deepPurple.shade900.withOpacity(0.7),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 24,
//                   left: 24,
//                   child: Text(
//                     fullClub.name,
//                     style: TextStyle(
//                       fontSize: isTablet ? 32 : 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       shadows: const [
//                         Shadow(
//                           blurRadius: 4,
//                           color: Colors.black38,
//                           offset: Offset(1, 2),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ===== Club Info =====
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(24),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       _infoRow(
//                         Icons.flag,
//                         "Country",
//                         fullClub.country ?? "",
//                         isTablet,
//                       ),
//                       const SizedBox(height: 12),
//                       _infoRow(
//                         Icons.location_city,
//                         "City",
//                         fullClub.city ?? "",
//                         isTablet,
//                       ),
//                       const SizedBox(height: 12),
//                       _infoRow(
//                         Icons.layers,
//                         "Level",
//                         fullClub.level ?? "",
//                         isTablet,
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ===== Players List =====
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Text(
//                       "${fullClub.playersCount ?? (fullClub.players?.length ?? 0)} PLAYERS",
//                       style: TextStyle(
//                         fontSize: headerFontSize,
//                         fontWeight: FontWeight.bold,
//                         color: headerColor,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   if (fullClub.players != null && fullClub.players!.isNotEmpty)
//                     ListView.separated(
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: fullClub.players!.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 12),
//                       itemBuilder: (context, index) {
//                         final p = fullClub.players![index];
//                         return _playerCard(p, isTablet);
//                       },
//                     )
//                   else
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       child: Center(
//                         child: Text(
//                           "No players available",
//                           style: TextStyle(color: Colors.grey.shade600),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===== Player Card =====
//   Widget _playerCard(PlayerInClub p, bool isTablet) {
//     final info = [
//       if ((p.age ?? "").isNotEmpty) p.age,
//       if ((p.position?.name ?? "").isNotEmpty) p.position?.name,
//       if ((p.country ?? "").isNotEmpty) p.country,
//     ].join(", ");

//     return InkWell(
//       onTap: () {
//         final player = Player(
//           id: p.id,
//           name: p.name ?? "",
//           age: p.age ?? "",
//           country: p.country ?? "",
//           position: p.position,
//           jerseyNumber: p.jerseyNumber,
//           photo: p.photo,
//         );
//         Get.to(
//           () => PlayerDetails(player: player),
//           opaque: true,
//           transition: Transition.rightToLeft,
//           curve: Curves.easeInOut,
//           duration: const Duration(milliseconds: 350),
//         );
//       },
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         color: Colors.deepPurple.shade50,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 p.name ?? "",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isTablet ? 18 : 16,
//                 ),
//               ),
//               if (info.isNotEmpty) ...[
//                 const SizedBox(height: 4),
//                 Text(
//                   info,
//                   style: TextStyle(
//                     color: Colors.grey.shade700,
//                     fontSize: isTablet ? 14 : 12,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ===== Info Row =====
//   Widget _infoRow(IconData icon, String label, String value, bool isTablet) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.deepPurple.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: Colors.deepPurple.shade700,
//             size: isTablet ? 32 : 24,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: isTablet ? 16 : 14,
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: isTablet ? 20 : 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
