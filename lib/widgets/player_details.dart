import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/models/player.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/widgets/club_details.dart';

import 'package:precords_android/services/api_service.dart';

class PlayerDetails extends StatelessWidget {
  final Player player;

  const PlayerDetails({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final photoRadius = isTablet ? 110.0 : 85.0;

    final String initial = player.name.isNotEmpty ? player.name[0].toUpperCase() : "?";
    final bool hasPhoto = player.photo?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          player.name,
          style: TextStyle(fontSize: isTablet ? 28 : 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
                ),
              ),
              child: Center(
                child: Hero(
                  tag: "player_${player.id}",
                  child: CircleAvatar(
                    radius: photoRadius,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: photoRadius - 4,
                      backgroundColor: Colors.grey[200],
                      child: hasPhoto
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(photoRadius),
                              child: CachedNetworkImage(
                                imageUrl: player.photo!,
                                width: (photoRadius - 4) * 2,
                                height: (photoRadius - 4) * 2,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Center(child: Text(initial, style: TextStyle(fontSize: photoRadius * 0.9, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                errorWidget: (_, __, ___) => Center(child: Text(initial, style: TextStyle(fontSize: photoRadius * 0.9, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
                                fadeInDuration: const Duration(milliseconds: 200),
                              ),
                            )
                          : Text(initial, style: TextStyle(fontSize: photoRadius * 0.9, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (player.jerseyNumber != null)
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(color: Colors.deepPurple[100], borderRadius: BorderRadius.circular(40)),
                  child: Text("#${player.jerseyNumber}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple[900])),
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 32 : 20),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: Column(
                    children: [
                      if (player.club != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final fullClub = await Get.find<ApiService>().getClubDetailsByName(player.club!.name);
                              Get.to(() => ClubDetailsScreen(fullClub: fullClub));
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(16)),
                                    child: Icon(Icons.people, color: Colors.deepPurple[700], size: isTablet ? 32 : 26),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Club", style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Text(player.club!.name, style: TextStyle(fontSize: isTablet ? 22 : 20, fontWeight: FontWeight.bold, color: Colors.deepPurple[900])),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple[700]),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        _buildInfoRow(Icons.people, "Club", "Free Agent", isTablet),

                      const Divider(height: 22, thickness: 1, color: Colors.grey),

                      _buildInfoRow(Icons.flag, "Nationality", player.country, isTablet),
                      _buildInfoRow(Icons.sports_soccer, "Position", player.position?.name ?? "Not specified", isTablet),
                      _buildInfoRow(Icons.cake, "Age", player.age, isTablet),
                      _buildInfoRow(player.gender?.toLowerCase() == "female" ? Icons.female : Icons.male, "Gender", (player.gender ?? "Not specified"), isTablet),
                      if (player.phone?.isNotEmpty == true) _buildInfoRow(Icons.phone, "Phone", player.phone!, isTablet),
                      if (player.email?.isNotEmpty == true) _buildInfoRow(Icons.email, "Email", player.email!, isTablet),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: Colors.deepPurple[700], size: isTablet ? 32 : 26),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value, style: TextStyle(fontSize: isTablet ? 22 : 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:precords_android/models/club_model.dart';
// // lib/widgets/player_details.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/models/player.dart';
// import 'package:precords_android/widgets/club_details.dart';
// import 'package:precords_android/services/api_service.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final photoRadius = isTablet ? 110.0 : 85.0;

//     final String initial = player.name.isNotEmpty ? player.name[0].toUpperCase() : "?";
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
//             fontSize: isTablet ? 28 : 24,  // BIGGER & BOLDER
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
//                       backgroundImage: hasPhoto ? NetworkImage(player.photo!) : null,
//                       child: !hasPhoto
//                           ? Text(
//                               initial,
//                               style: TextStyle(fontSize: photoRadius * 0.9, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
//                   padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
//                   decoration: BoxDecoration(color: Colors.deepPurple[100], borderRadius: BorderRadius.circular(40)),
//                   child: Text("#${player.jerseyNumber}", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple[900])),
//                 ),
//               ),
//             ),

//           // INFO CARD
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.all(isTablet ? 32 : 20),
//               child: Card(
//                 elevation: 12,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
//                               final fullClub = await Get.find<ApiService>().getClubDetailsByName(player.club!.name);
//                               Get.to(() => ClubDetailsScreen(fullClub: fullClub));
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 18),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(14),
//                                     decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(16)),
//                                     child: Icon(Icons.people, color: Colors.deepPurple[700], size: isTablet ? 32 : 26),
//                                   ),
//                                   const SizedBox(width: 20),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text("Club", style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           player.club!.name,
//                                           style: TextStyle(fontSize: isTablet ? 22 : 20, fontWeight: FontWeight.bold, color: Colors.deepPurple[900]),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Icon(Icons.arrow_forward_ios, size: 18, color: Colors.deepPurple[700]),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         )
//                       else
//                         _buildInfoRow(Icons.people, "Club", "Free Agent", isTablet),

//                       const Divider(height: 22, thickness: 1, color: Colors.grey),

//                       _buildInfoRow(Icons.flag, "Nationality", player.country, isTablet),
//                       _buildInfoRow(Icons.sports_soccer, "Position", player.position?.name ?? "Not specified", isTablet),
//                       _buildInfoRow(Icons.cake, "Age", player.age, isTablet),
//                       _buildInfoRow(
//                         player.gender?.toLowerCase() == "female" ? Icons.female : Icons.male,
//                         "Gender",
//                         player.gender?.capitalize ?? "Not specified",
//                         isTablet,
//                       ),
//                       if (player.phone?.isNotEmpty == true)
//                         _buildInfoRow(Icons.phone, "Phone", player.phone!, isTablet),
//                       if (player.email?.isNotEmpty == true)
//                         _buildInfoRow(Icons.email, "Email", player.email!, isTablet),
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

//   Widget _buildInfoRow(IconData icon, String label, String value, bool isTablet) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(16)),
//             child: Icon(icon, color: Colors.deepPurple[700], size: isTablet ? 32 : 26),
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(fontSize: isTablet ? 16 : 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 6),
//                 Text(value, style: TextStyle(fontSize: isTablet ? 22 : 20, fontWeight: FontWeight.bold, color: Colors.black87)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
 

















// lib/widgets/player_details.dart
// import 'package:flutter/material.dart';
// import 'package:precords_android/models/player.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   @override
//   Widget build(BuildContext context) {
//     final String initial = player.name.isNotEmpty ? player.name[0].toUpperCase() : "?";
//     final bool hasPhoto = player.photo?.isNotEmpty == true;

//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           // HERO APP BAR WITH GRADIENT
//           SliverAppBar(
//             expandedHeight: 320,
//             floating: false,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(
//                 player.name,
//                 style: const TextStyle(fontWeight: FontWeight.bold, shadows: [
//                   Shadow(color: Colors.black45, blurRadius: 10)
//                 ]),
//               ),
//               centerTitle: true,
//               background: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [Colors.transparent, Colors.black54],
//                         stops: [0.4, 1.0],
//                       ),
//                     ),
//                   ),
//                   Center(
//                     child: Hero(
//                       tag: "player_${player.id}",
//                       child: CircleAvatar(
//                         radius: 90,
//                         backgroundColor: Colors.white,
//                         child: CircleAvatar(
//                           radius: 86,
//                           backgroundImage: hasPhoto ? NetworkImage(player.photo!) : null,
//                           child: !hasPhoto
//                               ? Text(
//                                   initial,
//                                   style: const TextStyle(
//                                     fontSize: 90,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.deepPurple,
//                                   ),
//                                 )
//                               : null,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             backgroundColor: Colors.deepPurple[700],
//             foregroundColor: Colors.white,
//             elevation: 0,
//           ),

//           // PLAYER INFO CARD
//           SliverToBoxAdapter(
//             child: Container(
//               margin: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.deepPurple.withOpacity(0.15),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   children: [
//                     // Jersey Number Badge
//                     if (player.jerseyNumber != null)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         decoration: BoxDecoration(
//                           color: Colors.deepPurple[100],
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Text(
//                           "#${player.jerseyNumber}",
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.deepPurple[800],
//                           ),
//                         ),
//                       ),
//                     if (player.jerseyNumber != null) const SizedBox(height: 20),

//                     // Info Rows
//                     _buildInfoRow(Icons.flag, "Nationality", player.country),
//                     _buildInfoRow(Icons.sports_soccer, "Position", player.position?.name ?? "Not specified"),
//                     _buildInfoRow(Icons.people, "Club", player.club?.name ?? "Free Agent"),
//                     _buildInfoRow(Icons.cake, "Age", player.age),
//                     _buildInfoRow(
//                       player.gender?.toLowerCase() == "female" ? Icons.female : Icons.male,
//                       "Gender",
//                       player.gender?.capitalizeFirst ?? "Not specified",
//                     ),
//                     if (player.phone?.isNotEmpty == true)
//                       _buildInfoRow(Icons.phone, "Phone", player.phone!),
//                     if (player.email?.isNotEmpty == true)
//                       _buildInfoRow(Icons.email, "Email", player.email!),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           const SliverToBoxAdapter(child: SizedBox(height: 40)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.deepPurple[50],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: Colors.deepPurple[700], size: 26),
//           ),
//           const SizedBox(width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 value,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Helper
// extension StringExtension on String {
//   String get capitalizeFirst => isNotEmpty ? this[0].toUpperCase() + substring(1).toLowerCase() : this;
// }


















// import 'package:flutter/material.dart';
// import 'package:precords_android/models/player.dart';

// class PlayerDetails extends StatelessWidget {
//   final Player player;

//   const PlayerDetails({super.key, required this.player});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(player.name),
//         backgroundColor: Colors.deepPurple[600],
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 80,
//                 backgroundImage: player.photo != null && player.photo!.isNotEmpty
//                     ? NetworkImage(player.photo!)
//                     : null,
//                 child: player.photo == null || player.photo!.isEmpty
//                     ? Text(
//                         player.name.isNotEmpty ? player.name[0].toUpperCase() : "?",
//                         style: const TextStyle(fontSize: 60, color: Colors.white),
//                       )
//                     : null,
//                 backgroundColor: Colors.deepPurple[400],
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildDetailRow("Country", player.country),
//             _buildDetailRow("Club", player.club?.name ?? "Free Agent"),
//             _buildDetailRow("Position", player.position?.name ?? "Not specified"),
//             _buildDetailRow("Age", player.age), 
//             _buildDetailRow("Gender", player.gender ?? " - "),
//             _buildDetailRow("Email", player.email ?? " - "),
//             if (player.phone != null && player.phone!.isNotEmpty)

//             const Spacer(),
    
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 110,
//             child: Text(
//               "$label:",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }
// }