import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/models/player.dart';
import 'package:precords_android/widgets/player_details.dart';

class ClubDetailsScreen extends StatelessWidget {
  final ClubModel fullClub;
  final double headerFontSize;
  final Color headerColor;

  const ClubDetailsScreen({
    super.key,
    required this.fullClub,
    this.headerFontSize = 20,
    this.headerColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(fullClub.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,centerTitle:true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // Future actions: share, edit
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "share", child: Text("Share Club")),
              const PopupMenuItem(value: "edit", child: Text("Edit Club")),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Banner =====
            Stack(
              children: [
                Container(
                  height: isTablet ? 200 : 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(42)),
                    image: fullClub.logo != null && fullClub.logo!.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(fullClub.logo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.deepPurple.shade200,
                  ),
                ),
                Container(
                  height: isTablet ? 300 : 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepPurple.withOpacity(0.2),
                        Colors.deepPurple.shade900.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: Text(
                    fullClub.name,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black38,
                          offset: Offset(1, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== Club Info =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _infoRow(Icons.flag, "Country", fullClub.country ?? "", isTablet),
                      const SizedBox(height: 12),
                      _infoRow(Icons.location_city, "City", fullClub.city ?? "", isTablet),
                      const SizedBox(height: 12),
                      _infoRow(Icons.layers, "Level", fullClub.level ?? "", isTablet),
                      const SizedBox(height: 12),
           
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Players List =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child:Text(
                    "${fullClub.playersCount ?? (fullClub.players?.length ?? 0)} PLAYERS",
                    style: TextStyle(
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.bold,
                      color: headerColor,
                    ),
                  ),),
                  const SizedBox(height: 12),
                  if (fullClub.players != null && fullClub.players!.isNotEmpty)
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: fullClub.players!.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final p = fullClub.players![index];
                        return _playerCard(p, isTablet);
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          "No players available",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ===== Player Card =====
  Widget _playerCard(PlayerInClub p, bool isTablet) {
    final info = [
      if ((p.age ?? "").isNotEmpty) p.age,
      if ((p.position?.name ?? "").isNotEmpty) p.position?.name,
      if ((p.country ?? "").isNotEmpty) p.country,
    ].join(", ");

    return InkWell(
      onTap: () {
  // Convert PlayerInClub -> Player for PlayerDetails
  final player = Player(
    id: p.id,
    name: p.name ?? "",
    age: p.age ?? "",           // Keep as String
    country: p.country ?? "",
    position: p.position,
    jerseyNumber: p.jerseyNumber,
    photo: p.photo,
  );
  Get.to(() => PlayerDetails(player: player));
},

      // onTap: () {
      //   // Convert PlayerInClub -> Player for PlayerDetails
      //   final player = Player(
      //     id: p.id,
      //     name: p.name ?? "",
      //     age: p.age != null ? int.tryParse(p.age!) : null,
      //     country: p.country ?? "",
      //     position: p.position,
      //     jerseyNumber: p.jerseyNumber,
      //     photo: p.photo,
      //   );
      //   Get.to(() => PlayerDetails(player: player));
      // },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.deepPurple.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.name ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              if (info.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: isTablet ? 14 : 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===== Info Row =====
  Widget _infoRow(IconData icon, String label, String value, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.deepPurple.shade700, size: isTablet ? 32 : 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player.dart';
// import 'package:precords_android/widgets/player_details.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;
//   final double titleFontSize;
//   final Color titleColor;

//   const ClubDetailsScreen({
//     super.key,
//     required this.fullClub,
//     this.titleFontSize = 24,
//     this.titleColor = Colors.deepPurple,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
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
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ======= Banner =======
//             Stack(
//               children: [
//                 Container(
//                   height: isTablet ? 200 : 140,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(
//                         bottom: Radius.circular(42)),
//                     image: fullClub.logo != null && fullClub.logo!.isNotEmpty
//                         ? DecorationImage(
//                             image:
//                                 CachedNetworkImageProvider(fullClub.logo!),
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
//                         bottom: Radius.circular(32)),
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
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ======= Club Info =======
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(24)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       final isWide = constraints.maxWidth > 400;
//                       final children = [
//                         _infoRow(Icons.flag, "Country",
//                             fullClub.country ?? "", isTablet),
//                         _infoRow(Icons.location_city, "City",
//                             fullClub.city ?? "", isTablet),
//                         _infoRow(
//                             Icons.layers, "Level", fullClub.level ?? "", isTablet),
//                       ];
//                       if (isWide) {
//                         return Wrap(
//                           spacing: 16,
//                           runSpacing: 16,
//                           children: children
//                               .map((c) => SizedBox(
//                                   width: (constraints.maxWidth - 16) / 2,
//                                   child: c))
//                               .toList(),
//                         );
//                       }
//                       return Column(
//                         children: children
//                             .map((c) => Padding(
//                                 padding: const EdgeInsets.only(bottom: 16),
//                                 child: c))
//                             .toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ======= Players Header =======
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   Text(
//                     "Players (${fullClub.players?.length ?? 0})",
//                     style: TextStyle(
//                         fontSize: isTablet ? 22 : 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.deepPurple.shade900),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // ======= Players List =======
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 children: fullClub.players != null && fullClub.players!.isNotEmpty
//                     ? fullClub.players!.map((p) => _playerListTile(p, isTablet))
//                         .toList()
//                     : [
//                         Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Text(
//                               "No players available",
//                               style: TextStyle(color: Colors.grey.shade600),
//                             ),
//                           ),
//                         )
//                       ],
//               ),
//             ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   // ======= Player List Tile =======
//   Widget _playerListTile(PlayerInClub p, bool isTablet) {
//     String subtitleText = [
//       p.age?.toString() ?? "",
//       p.position?.name ?? "",
//       p.country ?? ""
//     ].where((e) => e.isNotEmpty).join(", ");

//     return InkWell(
//       onTap: () {
//         // Navigate to PlayerDetails
//         Get.to(() => PlayerDetails(
//               player: Player(
//                 id: p.id ?? "",
//                 name: p.name ?? "",
//                 age: p.age?.toString() ?? "",
//                 country: p.country ?? "",
//                 photo: p.photo ?? "",
//                 position: p.position,
//               ),
//             ));
//       },
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 p.name ?? "",
//                 style: TextStyle(
//                   fontSize: isTablet ? 18 : 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.deepPurple.shade900,
//                 ),
//               ),
//               if (subtitleText.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     subtitleText,
//                     style: TextStyle(
//                       fontSize: isTablet ? 16 : 14,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ======= Info Row =======
//   Widget _infoRow(IconData icon, String label, String value, bool isTablet) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.deepPurple.shade50,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: Colors.deepPurple.shade700, size: isTablet ? 32 : 24),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       fontSize: isTablet ? 16 : 14,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w600)),
//               const SizedBox(height: 4),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: isTablet ? 20 : 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   // Optional header style
//   final double headerFontSize;
//   final Color headerColor;

//   const ClubDetailsScreen({
//     super.key,
//     required this.fullClub,
//     this.headerFontSize = 20,
//     this.headerColor = Colors.deepPurple,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
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
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ======= Banner =======
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   height: isTablet ? 220 : 160,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.deepPurple.shade200,
//                     borderRadius: const BorderRadius.vertical(bottom: Radius.circular(42)),
//                     image: fullClub.logo != null && fullClub.logo!.isNotEmpty
//                         ? DecorationImage(
//                             image: CachedNetworkImageProvider(fullClub.logo!),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                 ),
//                 Container(
//                   height: isTablet ? 220 : 160,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(bottom: Radius.circular(42)),
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.deepPurple.withOpacity(0.15),
//                         Colors.deepPurple.shade900.withOpacity(0.75),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 16,
//                   left: 24,
//                   child: Text(
//                     fullClub.name,
//                     style: TextStyle(
//                       fontSize: isTablet ? 32 : 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       shadows: const [
//                         Shadow(blurRadius: 4, color: Colors.black38, offset: Offset(1, 2))
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // ======= Club Info Card =======
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       final isWide = constraints.maxWidth > 400;
//                       final children = [
//                         _infoRow(Icons.flag, "Country", fullClub.country, isTablet),
//                         _infoRow(Icons.location_city, "City", fullClub.city, isTablet),
//                         _infoRow(Icons.layers, "Level", fullClub.level, isTablet),
//                       ];
//                       if (isWide) {
//                         return Wrap(
//                           spacing: 16,
//                           runSpacing: 16,
//                           children: children
//                               .map((c) => SizedBox(width: (constraints.maxWidth - 16) / 2, child: c))
//                               .toList(),
//                         );
//                       }
//                       return Column(
//                         children: children
//                             .map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c))
//                             .toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ======= Players List =======
//             if (fullClub.players != null && fullClub.players!.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Players (${fullClub.players!.length})",
//                       style: TextStyle(
//                         fontSize: headerFontSize,
//                         fontWeight: FontWeight.bold,
//                         color: headerColor,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ListView.separated(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: fullClub.players!.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 8),
//                       itemBuilder: (context, index) {
//                         final p = fullClub.players![index];
//                         return _playerListTile(p);
//                       },
//                     ),
//                   ],
//                 ),
//               )
//             else
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Center(
//                   child: Text(
//                     "No players available",
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   // ======= Player List Tile =======
//   Widget _playerListTile(PlayerInClub p) {
//     final infoList = [
//       if (p.age != null) "${p.age} yrs",
//       if (p.position?.name != null) p.position!.name!,
//       if (p.country != null) p.country!,
//     ];
//     final infoLine = infoList.join(", ");

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               radius: 24,
//               backgroundColor: Colors.deepPurple.shade200,
//               backgroundImage:
//                   p.photo != null && p.photo!.isNotEmpty ? NetworkImage(p.photo!) : null,
//               child: p.photo == null || p.photo!.isEmpty
//                   ? Text(
//                       (p.name ?? "?")
//                           .split(' ')
//                           .map((e) => e[0])
//                           .take(2)
//                           .join()
//                           .toUpperCase(),
//                       style: const TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold))
//                   : null,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     p.name ?? "",
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   if (infoLine.isNotEmpty)
//                     const SizedBox(height: 4),
//                   if (infoLine.isNotEmpty)
//                     Text(
//                       infoLine,
//                       style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ======= Info Row =======
//   Widget _infoRow(IconData icon, String label, String? value, bool isTablet) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.deepPurple.shade50,
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.deepPurple.shade200,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: Colors.deepPurple.shade900, size: isTablet ? 32 : 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label,
//                     style: TextStyle(
//                         fontSize: isTablet ? 16 : 14,
//                         color: Colors.deepPurple.shade700,
//                         fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 4),
//                 Text(value ?? "",
//                     style: TextStyle(
//                         fontSize: isTablet ? 20 : 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/models/player.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   const ClubDetailsScreen({super.key, required this.fullClub});

//   @override
//   Widget build(BuildContext context) {
//     final isTablet = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
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
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ======= Banner =======
//             Stack(
//               children: [
//                 Container(
//                   height: isTablet ? 200 : 140,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.vertical(bottom: Radius.circular(42)),
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
//                     borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // ======= Club Info =======
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       final isWide = constraints.maxWidth > 400;
//                       final children = [
//                         _infoRow(Icons.flag, "Country", fullClub.country ?? "Unknown", isTablet),
//                         _infoRow(Icons.location_city, "City", fullClub.city ?? "Unknown", isTablet),
//                         _infoRow(Icons.layers, "Level", fullClub.level ?? "Unknown", isTablet),
//                         _infoRow(Icons.groups, "Players",
//                             "${fullClub.playersCount ?? (fullClub.players?.length ?? 0)}", isTablet),
//                       ];
//                       if (isWide) {
//                         return Wrap(
//                           spacing: 16,
//                           runSpacing: 16,
//                           children: children
//                               .map((c) => SizedBox(width: (constraints.maxWidth - 16) / 2, child: c))
//                               .toList(),
//                         );
//                       }
//                       return Column(
//                         children: children
//                             .map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c))
//                             .toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ======= Players Horizontal Scroll =======
//             if (fullClub.players != null && fullClub.players!.isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Divider(thickness: 3, color: Colors.transparent),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     height: 160,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       itemCount: fullClub.players!.length,
//                       separatorBuilder: (_, __) => const SizedBox(width: 12),
//                       itemBuilder: (context, index) {
//                         final p = fullClub.players![index];
//                         return _playerCard(p);
//                       },
//                     ),
//                   ),
//                 ],
//               )
//             else
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Center(
//                   child: Text(
//                     "No players available",
//                     style: TextStyle(color: Colors.grey.shade600),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }

//   // ======= Player Card =======
//   Widget _playerCard(PlayerInClub p) {
//     final initials = (p.name ?? "?")
//         .split(' ')
//         .where((e) => e.isNotEmpty)
//         .map((e) => e[0])
//         .take(2)
//         .join()
//         .toUpperCase();

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SizedBox(
//         width: 140,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 36,
//               backgroundColor: Colors.deepPurple.shade200,
//               backgroundImage:
//                   p.photo != null && p.photo!.isNotEmpty ? NetworkImage(p.photo!) : null,
//               child: p.photo == null || p.photo!.isEmpty
//                   ? Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
//                   : null,
//             ),
//             const SizedBox(height: 8),
//             Text(p.name ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 4),
//             Text(p.position?.name ?? "-", style: TextStyle(color: Colors.grey.shade700)),
//             const SizedBox(height: 4),
//             if (p.jerseyNumber != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.deepPurple.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text("#${p.jerseyNumber}",
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ======= Info Row =======
//   Widget _infoRow(IconData icon, String label, String value, bool isTablet) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.deepPurple.shade50,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: Colors.deepPurple.shade700, size: isTablet ? 32 : 24),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: TextStyle(
//                       fontSize: isTablet ? 16 : 14,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w600)),
//               const SizedBox(height: 4),
//               Text(value,
//                   style: TextStyle(
//                       fontSize: isTablet ? 20 : 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/player_details.dart';
// import 'package:precords_android/models/player.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   const ClubDetailsScreen({super.key, required this.fullClub});

//   @override
//   Widget build(BuildContext context) {
//     final players = fullClub.players ?? <PlayerInClub>[];
//     final initial = fullClub.shortName?.trim().isNotEmpty == true
//         ? fullClub.shortName!.trim()[0].toUpperCase()
//         : "?";

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple[500],
//         foregroundColor: Colors.white,centerTitle:true,
//         elevation: 0,
//       ),
//       body: CustomScrollView(
//         slivers: [
//           // CLUB HEADER
//           SliverToBoxAdapter(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Hero(
//                     tag: "club_${fullClub.id}",
//                     child: CircleAvatar(
//                       radius: 70,
//                       backgroundColor: Colors.white,
//                       child: CircleAvatar(
//                         radius: 66,
//                         backgroundImage: fullClub.logo?.isNotEmpty == true
//                             ? CachedNetworkImageProvider(fullClub.logo!)
//                             : null,
//                         child: fullClub.logo?.isNotEmpty != true
//                             ? Text(initial, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.deepPurple))
//                             : null,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
             
//                   const SizedBox(height: 8),
//                   Text(
//                     "${fullClub.country ?? 'Unknown'} • ${fullClub.city ?? 'Unknown City'}",
//                     style: const TextStyle(fontSize: 16, color: Colors.white70),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       "${players.length} Player${players.length == 1 ? '' : 's'}",
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // SECTION TITLE
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Row(
//                 children: [
//                   Divider(
//                     thickness: 2,
//                     color: Colors.deepPurple[200],
//                     endIndent: 12,
//                     indent: 0,
//                     height: 0,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // PLAYERS LIST
//           if (players.isEmpty)
//             const SliverFillRemaining(
//               child: Center(
//                 child: Text(
//                   "No players in this club yet",
//                   style: TextStyle(fontSize: 18, color: Colors.grey),
//                 ),
//               ),
//             )
//           else
//             SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final player = players[index];
//                   final name = player.name?.trim().isNotEmpty == true ? player.name! : "Unknown Player";
//                   final position = player.position?.shortName ?? player.position?.name ?? "Unknown";
//                   final country = player.country ?? "Unknown";
//                   final photoUrl = player.photo?.isNotEmpty == true ? player.photo! : null;

//                   return Card(
//                     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     child: ListTile(
//                       onTap: () {
//                         final fullPlayer = Player.fromPlayerInClub(player, club: fullClub);
//                         Get.to(() => PlayerDetails(player: fullPlayer));
//                       },
//                       leading: Hero(
//                         tag: "player_${player.id}",
//                         child: CircleAvatar(
//                           radius: 30,
//                           backgroundImage: photoUrl != null
//                               ? CachedNetworkImageProvider(photoUrl)
//                               : null,
//                           child: photoUrl == null
//                               ? Text(
//                                   name.isNotEmpty ? name[0].toUpperCase() : "?",
//                                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                                 )
//                               : null,
//                           backgroundColor: Colors.deepPurple[100],
//                         ),
//                       ),
//                       title: Text(
//                         name,
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(Icons.sports, size: 16, color: Colors.deepPurple[600]),
//                               const SizedBox(width: 6),
//                               Text(position, style: TextStyle(color: Colors.deepPurple[700], fontWeight: FontWeight.w600)),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               const Icon(Icons.flag, size: 16, color: Colors.grey),
//                               const SizedBox(width: 6),
//                               Text(country),
//                             ],
//                           ),
//                         ],
//                       ),
                  
//                     ),
//                   );
//                 },
//                 childCount: players.length,
//               ),
//             ),

//           const SliverToBoxAdapter(child: SizedBox(height: 40)),
//         ],
//       ),
//     );
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/player_details.dart';
// import 'package:precords_android/models/player.dart';

// class ClubDetailsScreen extends StatelessWidget {
//   final ClubModel fullClub;

//   const ClubDetailsScreen({super.key, required this.fullClub});

//   @override
//   Widget build(BuildContext context) {
//     final players = fullClub.players ?? <PlayerInClub>[];

//     // Safe initial letter
//     final String initial = fullClub.shortName?.trim().isNotEmpty == true
//         ? fullClub.shortName!.trim()[0].toUpperCase()
//         : "?";

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fullClub.name),
//         backgroundColor: Colors.deepPurple[600],
//         foregroundColor: Colors.white,
//         centerTitle: true,
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage: fullClub.logo?.isNotEmpty == true
//                         ? NetworkImage(fullClub.logo!)
//                         : null,
//                     child: fullClub.logo?.isNotEmpty != true
//                         ? Text(
//                             initial,
//                             style: const TextStyle(fontSize: 50, color: Colors.white, fontWeight: FontWeight.bold),
//                           )
//                         : null,
//                     backgroundColor: Colors.deepPurple[400],
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     fullClub.name,
//                     style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "${fullClub.country ?? 'Unknown'} • ${fullClub.city ?? 'Unknown City'}",
//                     style: const TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "${fullClub.playersCount ?? players.length} player${(fullClub.playersCount ?? players.length) == 1 ? '' : 's'}",
//                     style: TextStyle(fontSize: 18, color: Colors.deepPurple[700], fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
//               child: Divider(
//                 thickness: 1,
//             ),
//             ),
//           ),

//           if (players.isEmpty)
//             const SliverToBoxAdapter(
//               child: Padding(
//                 padding: EdgeInsets.all(40),
//                 child: Center(
//                   child: Text("No players in this club yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
//                 ),
//               ),
//             )
//           else
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 0.78,
//                   mainAxisSpacing: 16,
//                   crossAxisSpacing: 16,
//                 ),
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final player = players[index];
//                     final displayName = player.name?.trim().isNotEmpty == true ? player.name! : "Unknown Player";
//                     final firstLetter = displayName[0].toUpperCase();
//                     final lastName = displayName.contains(' ') ? displayName.split(' ').last : displayName;

//                     return GestureDetector(
//                       onTap: () {
//                         final fullPlayer = Player.fromPlayerInClub(player, club: fullClub);
//                         Get.to(() => PlayerDetails(player: fullPlayer));
//                       },
//                       child: Column(
//                         children: [
//                           CircleAvatar(
//                             radius: 36,
//                             backgroundImage: player.photo?.isNotEmpty == true
//                                 ? CachedNetworkImageProvider(player.photo!)
//                                 : null,
//                             child: player.photo?.isNotEmpty != true
//                                 ? Text(firstLetter, style: const TextStyle(fontSize: 30, color: Colors.white))
//                                 : null,
//                             backgroundColor: Colors.deepPurple[300],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             lastName,
//                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                             textAlign: TextAlign.center,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             player.position?.shortName ?? "??",
//                             style: TextStyle(color: Colors.deepPurple[700], fontWeight: FontWeight.bold, fontSize: 14),
//                           ),
//                           if (player.jerseyNumber != null)
//                             Text("#${player.jerseyNumber}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                         ],
//                       ),
//                     );
//                   },
//                   childCount: players.length,
//                 ),
//               ),
//             ),

//           const SliverToBoxAdapter(child: SizedBox(height: 30)),
//         ],
//       ),
//     );
//   }
// }