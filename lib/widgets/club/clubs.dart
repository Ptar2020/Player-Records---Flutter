import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/services/api_service.dart';
import 'package:precords_android/services/auth_service.dart';
import 'package:precords_android/models/club_model.dart';
import 'package:precords_android/widgets/refreshable_page.dart';
import 'package:precords_android/widgets/skeletons/clubs_skeleton.dart';
import 'new_club.dart';
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

  /// Public method — called from BottomMenu via GlobalKey
  void handleMenuAction(String action) {
    if (action == "refresh") {
      refresh();
    }
    // TODO: Add sort/filter later
  }

  Future<void> refresh() async {
    setState(() {
      clubsFuture = api.getAllClubs();
    });
  }

  void _showCreateClubSheet() {
    Get.bottomSheet(
      CreateClubScreen(
        onSuccess: refresh, // Refresh list after creating club
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUser = auth.currentUser;
    final admin = currentUser?.role.toLowerCase() == 'admin';

    return RefreshablePage(
      onRefresh: refresh,
      child: Stack(
        children: [
          FutureBuilder<List<ClubModel>>(
            future: clubsFuture,
            builder: (context, snapshot) {
              // SKELETON LOADING
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: 8,
                  itemBuilder: (_, __) => const ClubCardSkeleton(),
                );
              }

              // ERROR STATE
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade400),
                      const SizedBox(height: 16),
                      Text(
                        "Error loading clubs",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${snapshot.error}",
                        style: TextStyle(color: Colors.red.shade400),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              // EMPTY STATE
              final clubs = snapshot.data ?? [];
              if (clubs.isEmpty) {
                return Center(
                  child: Text(
                    "No clubs found",
                    style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                );
              }

              // REAL LIST
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
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () async {
                        final fullClub =
                            await api.getClubDetailsByName(club.name);
                        Get.to(() => ClubDetailsScreen(fullClub: fullClub),
                            transition: Transition.rightToLeft);
                      },
                      leading: Hero(
                        tag: "club_${club.id}",
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: club.logo?.isNotEmpty == true
                                ? CachedNetworkImageProvider(club.logo!)
                                : null,
                            child: club.logo?.isNotEmpty != true
                                ? Text(
                                    initial,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.deepPurple,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      title: Text(
                        club.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        "${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                      trailing: Chip(
                        backgroundColor: Colors.deepPurple.shade100,
                        label: Text(
                          "${club.playersCount ?? 0} players",
                          style: TextStyle(
                            color: Colors.deepPurple.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // ADMIN ONLY: CREATE CLUB BUTTON
          if (admin)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton.extended(
                onPressed: _showCreateClubSheet,
                backgroundColor: Colors.deepPurple,
                icon: const Icon(Icons.add),
                label: const Text("Create Club"),
              ),
            ),
        ],
      ),
    );
  }
}











// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/services/auth_service.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'package:precords_android/widgets/skeletons/clubs_skeleton.dart'; 
// import 'club_details.dart';

// class Clubs extends StatefulWidget {
//   const Clubs({super.key});

//   @override
//   State<Clubs> createState() => ClubsState();
// }


// class ClubsState extends State<Clubs> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   List<ClubModel> clubs = [];
//   bool isLoading = true;
//   String? errorMessage;
  

//   final api = Get.find<ApiService>();
//   final user = Get.find<AuthService>().currentUser;
//   late Future<List<ClubModel>> clubsFuture;

//   Future<void> loadClubs() async {
//     setState(() => isLoading = true);
//     try {
//       final fetched = await Get.find<ApiService>().getAllClubs();
//       setState(() {
//         clubs = fetched;
//       });
//     } catch (e) {
//       setState(
//           () => errorMessage = e.toString().replaceFirst("Exception: ", ""));
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void handleMenuAction(String action) {
//     if (action == "refresh") loadClubs();
//     if (action == "sort") {
//       // TODO: implement sorting
//     }
//     if (action == "filter") {
//       // TODO: implement filtering
//     }
//   }
  
//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   Future<void> refresh() async {
//     setState(() {
//       clubsFuture = api.getAllClubs();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: FutureBuilder<List<ClubModel>>(
//         future: clubsFuture,
//         builder: (context, snapshot) {
//           // ====== SKELETON LOADING ======
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: 8,
//               itemBuilder: (_, __) => const ClubCardSkeleton(),
//             );
//           }

//           // ====== ERROR ======
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline,
//                       size: 64, color: Colors.red.shade400),
//                   const SizedBox(height: 16),
//                   Text("Error loading clubs",
//                       style:
//                           TextStyle(color: theme.textTheme.bodyLarge?.color)),
//                   Text("${snapshot.error}",
//                       style: TextStyle(color: Colors.red.shade400)),
//                 ],
//               ),
//             );
//           }

//           final clubs = snapshot.data ?? [];
//           if (clubs.isEmpty) {
//             return Center(
//               child: Text("No clubs found",
//                   style: TextStyle(
//                       fontSize: 18, color: theme.textTheme.bodyMedium?.color)),
//             );
//           }

//           // ====== REAL CLUB LIST — DARK MODE READY ======
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
//                 color: theme.cardColor,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18)),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(16),
//                   onTap: () async {
//                     final fullClub = await api.getClubDetailsByName(club.name);
//                     Get.to(() => ClubDetailsScreen(fullClub: fullClub),
//                         transition: Transition.rightToLeft);
//                   },
//                   leading: Hero(
//                     tag: "club_${club.id}",
//                     child: CircleAvatar(
//                       radius: 34,
//                       backgroundColor: Colors.deepPurple.shade100,
//                       child: CircleAvatar(
//                         radius: 32,
//                         backgroundImage: club.logo?.isNotEmpty == true
//                             ? CachedNetworkImageProvider(club.logo!)
//                             : null,
//                         child: club.logo?.isNotEmpty != true
//                             ? Text(
//                                 initial,
//                                 style: TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Theme.of(context).brightness ==
//                                           Brightness.dark
//                                       ? Colors.white
//                                       : Colors.deepPurple,
//                                 ),
//                               )
//                             : null,
          
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     club.name,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: theme.textTheme.bodyLarge?.color,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}",
//                     style: TextStyle(color: theme.textTheme.bodyMedium?.color),
//                   ),
//                   trailing: Chip(
//                     backgroundColor: Colors.deepPurple.shade100,
//                     label: Text(
//                       "${club.playersCount ?? 0} players",
//                       style: TextStyle(
//                         color: Colors.deepPurple.shade800,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
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







// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:precords_android/services/api_service.dart';
// import 'package:precords_android/models/club_model.dart';
// import 'package:precords_android/widgets/refreshable_page.dart';
// import 'club_details.dart';

// class Clubs extends StatefulWidget {
//   const Clubs({super.key});

//   @override
//   State<Clubs> createState() => ClubsState();
// }

// class ClubsState extends State<Clubs> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   final api = Get.find<ApiService>();
//   late Future<List<ClubModel>> clubsFuture;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   // Public method — called from BottomMenu via GlobalKey
//   Future<void> refresh() async {
//     setState(() {
//       clubsFuture = api.getAllClubs();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Required for AutomaticKeepAliveClientMixin

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: FutureBuilder<List<ClubModel>>(
//         future: clubsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.deepPurple),
//             );
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
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(16),
//                   onTap: () async {
//                     final fullClub = await Get.find<ApiService>()
//                         .getClubDetailsByName(club.name);
//                     Get.to(
//                       () => ClubDetailsScreen(fullClub: fullClub),
//                       opaque: true,
//                       transition: Transition.rightToLeft,
//                       curve: Curves.easeInOut,
//                       duration: const Duration(milliseconds: 350),
//                     );
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
//                             ? Text(
//                                 initial,
//                                 style: const TextStyle(
//                                   fontSize: 28,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.deepPurple,
//                                 ),
//                               )
//                             : null,
//                       ),
//                     ),
//                   ),
//                   title: Text(
//                     club.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   subtitle: Text(
//                     "${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}",
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   trailing: Chip(
//                     backgroundColor: Colors.deepPurple[50],
//                     label: Text(
//                       "${club.playersCount ?? 0} players",
//                       style: TextStyle(
//                         color: Colors.deepPurple[800],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
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
