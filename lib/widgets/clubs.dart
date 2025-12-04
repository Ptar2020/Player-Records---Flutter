import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/widgets/refreshable_page.dart';
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
  late Future<List<ClubModel>> clubsFuture;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  // Public method — called from BottomMenu via GlobalKey
  Future<void> refresh() async {
    setState(() {
      clubsFuture = api.getAllClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return RefreshablePage(
      onRefresh: refresh,
      child: FutureBuilder<List<ClubModel>>(
        future: clubsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () async {
                    final fullClub = await Get.find<ApiService>()
                        .getClubDetailsByName(club.name);
                    Get.to(() => ClubDetailsScreen(fullClub: fullClub));
                  },
                  leading: Hero(
                    tag: "club_${club.id}",
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.deepPurple[100],
                      child: CircleAvatar(
                        radius: 32,
                        backgroundImage: club.logo?.isNotEmpty == true
                            ? NetworkImage(club.logo!)
                            : null,
                        child: club.logo?.isNotEmpty != true
                            ? Text(initial,
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple))
                            : null,
                      ),
                    ),
                  ),
                  title: Text(club.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}",
                      style: TextStyle(color: Colors.grey[700])),
                  trailing: Chip(
                    backgroundColor: Colors.deepPurple[50],
                    label: Text("${club.playersCount ?? 0} players",
                        style: TextStyle(
                            color: Colors.deepPurple[800], fontWeight: FontWeight.bold)),
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





// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/app_bar_mixins.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'club_details.dart';

// class Clubs extends StatefulWidget with HasAppBarTitle, HasAppBarActions {
//   const Clubs({super.key});


//   @override
//   Widget appBarActions(BuildContext context) {
//     return PopupMenuButton<String>(
//       icon: const Icon(Icons.more_vert, color: Colors.white),
//       onSelected: (value) {
//         final state = context.findAncestorStateOfType<ClubsState>();
//         if (value == 'refresh') state?._refresh();
//         if (value == 'logout') Get.find<AuthService>().logout();
//       },
//       itemBuilder: (_) => const [
//         PopupMenuItem(value: 'refresh', child: Text("Refresh")),
//         PopupMenuItem(value: 'logout', child: Text("Logout")),
//       ],
//     );
//   }
// }

// class ClubsState extends State<Clubs> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final api = Get.find<ApiService>();
//   late Future<List<ClubModel>> clubsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _refresh();
//   }

//   void _refresh() {
//     setState(() {
//       clubsFuture = api.getAllClubs();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: () async => _refresh(),
//       child: FutureBuilder<List<ClubModel>>(
//         future: clubsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           }
//           final clubs = snapshot.data ?? [];
//           if (clubs.isEmpty) {
//             return const Center(child: Text("No clubs found"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: clubs.length,
//             itemBuilder: (context, index) {
//               final club = clubs[index];

//               final initial = club.shortName?.trim().isNotEmpty == true
//                   ? club.shortName!.trim()[0].toUpperCase()
//                   : "?";

//               return Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(16),
//                   onTap: () async {
//                     final fullClub = await Get.find<ApiService>().getClubDetailsByName(club.name);
//                     Get.to(() => ClubDetailsScreen(fullClub: fullClub));
//                   },
//                   leading: Hero(
//                     tag: "club_${club.id}",
//                     child: CircleAvatar(
//                       radius: 34,
//                       backgroundColor: Colors.deepPurple[100],
//                       child: CircleAvatar(
//                         radius: 32,
//                         backgroundImage: club.logo?.isNotEmpty == true
//                             ? NetworkImage(club.logo!)
//                             : null,
//                         child: club.logo?.isNotEmpty != true
//                             ? Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple))
//                             : null,
//                       ),
//                     ),
//                   ),
//                   title: Text(club.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   subtitle: Text("${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}", style: TextStyle(color: Colors.grey[700])),
//                   trailing: Chip(
//                     backgroundColor: Colors.deepPurple[50],
//                     label: Text("${club.playersCount ?? 0} players", style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
