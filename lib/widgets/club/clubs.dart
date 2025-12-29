import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:precords_android/forms/club_form.dart';
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
  List<ClubModel> clubs = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void handleMenuAction(String value) {
    if (value == 'refresh') {
      refresh();
    } else if (value == 'sort_name_asc') {
      setState(() {
        clubs.sort((a, b) => a.name.compareTo(b.name));
      });
    } else if (value == 'sort_name_desc') {
      setState(() {
        clubs.sort((a, b) => b.name.compareTo(a.name));
      });
    } else if (value == 'sort_players_desc') {
      setState(() {
        clubs.sort(
            (a, b) => (b.playersCount ?? 0).compareTo(a.playersCount ?? 0));
      });
    } else if (value == 'sort_players_asc') {
      setState(() {
        clubs.sort(
            (a, b) => (a.playersCount ?? 0).compareTo(b.playersCount ?? 0));
      });
    }
  }

  Future<void> refresh() async {
    setState(() {
      clubsFuture = api.getAllClubs();
    });
    final fetched = await clubsFuture;
    setState(() {
      clubs = fetched;
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

          // Use the in-memory clubs list for display (so sorting works)
          final displayClubs = clubs.isEmpty ? snapshot.data ?? [] : clubs;

          if (displayClubs.isEmpty) {
            return const Center(child: Text("No clubs found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: displayClubs.length,
            itemBuilder: (context, index) {
              final club = displayClubs[index];
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
                    } catch (e) {
                      Get.snackbar("Error", "Failed to load club details",
                          backgroundColor: Colors.red, colorText: Colors.white);
                    }
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        backgroundColor: Colors.deepPurple.shade100,
                        label: Text("${club.playersCount ?? 0} players",
                            style: TextStyle(
                                color: Colors.deepPurple.shade800,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      if (auth.currentUser?.role.toLowerCase() == 'admin')
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Get.bottomSheet(
                                ClubForm(mode: ClubFormMode.edit, club: club),
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30)),
                                ),
                              );

                              if (result == true) {
                                refresh();
                              }
                            } else if (value == 'delete') {
                              if (club.playersCount != null &&
                                  club.playersCount! > 0) {
                                Get.snackbar(
                                  "Cannot Delete",
                                  "This club has ${club.playersCount} player(s). Remove or transfer them first.",
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text("Delete Club"),
                                  content: Text(
                                      "Delete ${club.name}? This cannot be undone."),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text("Cancel")),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await api.deleteClub(club.id);
                                  refresh();
                                  Get.snackbar("Success", "Club deleted",
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
                          itemBuilder: (_) {
                            final items = [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.deepPurple),
                                    SizedBox(width: 12),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                            ];

                            if (club.playersCount == null ||
                                club.playersCount == 0) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 12),
                                      Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return items;
                          },
                        )
                      else
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
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
// import 'package:get/Get.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:precords_android/forms/club_form.dart';
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

//   final api = Get.find<ApiService>();
//   final auth = Get.find<AuthService>();
//   late Future<List<ClubModel>> clubsFuture;

//   @override
//   void initState() {
//     super.initState();
//     refresh();
//   }

//   void handleMenuAction(String action) {
//     if (action == "refresh") {
//       refresh();
//     }
//   }

//   Future<void> refresh() async {
//     setState(() {
//       clubsFuture = api.getAllClubs();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);

//     return RefreshablePage(
//       onRefresh: refresh,
//       child: FutureBuilder<List<ClubModel>>(
//         future: clubsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: 8,
//               itemBuilder: (_, __) => const ClubCardSkeleton(),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline,
//                       size: 64, color: Colors.red.shade400),
//                   const SizedBox(height: 16),
//                   const Text("Error loading clubs"),
//                   const SizedBox(height: 8),
//                   Text("${snapshot.error}",
//                       style: TextStyle(color: Colors.red.shade400)),
//                 ],
//               ),
//             );
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
//                     borderRadius: BorderRadius.circular(18)),
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(16),
//                   onTap: () async {
//                     try {
//                       final fullClub = await api.getClubDetailsById(club.id);
//                       Get.to(() => ClubDetailsScreen(fullClub: fullClub),
//                           transition: Transition.rightToLeft);
//                     } catch (e) {
//                       Get.snackbar("Error", "Failed to load club details",
//                           backgroundColor: Colors.red, colorText: Colors.white);
//                     }
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
//                             ? Text(initial,
//                                 style: TextStyle(
//                                     fontSize: 28,
//                                     fontWeight: FontWeight.bold,
//                                     color: Theme.of(context).brightness ==
//                                             Brightness.dark
//                                         ? Colors.white
//                                         : Colors.deepPurple))
//                             : null,
//                       ),
//                     ),
//                   ),
//                   title: Text(club.name,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 18)),
//                   subtitle: Text(
//                       "${club.country ?? 'Unknown'} • ${club.level ?? 'Amateur'}"),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Chip(
//                         backgroundColor: Colors.deepPurple.shade100,
//                         label: Text("${club.playersCount ?? 0} players",
//                             style: TextStyle(
//                                 color: Colors.deepPurple.shade800,
//                                 fontWeight: FontWeight.bold)),
//                       ),
//                       const SizedBox(width: 8),
//                       // Show menu ONLY if user is admin
//                       if (auth.currentUser?.role.toLowerCase() == 'admin')
//                         PopupMenuButton<String>(
//                           icon: const Icon(Icons.more_vert, color: Colors.grey),
//                           onSelected: (value) async {
//                             if (value == 'edit') {
//                               final result = await Get.bottomSheet(
//                                 ClubForm(mode: ClubFormMode.edit, club: club),
//                                 isScrollControlled: true,
//                                 backgroundColor: Colors.transparent,
//                                 shape: const RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(30)),
//                                 ),
//                               );

//                               if (result == true) {
//                                 refresh(); // Refresh the list after edit
//                               }
//                             } else if (value == 'delete') {
//                               // Extra safety: check player count again before showing dialog
//                               if (club.playersCount != null &&
//                                   club.playersCount! > 0) {
//                                 Get.snackbar(
//                                   "Cannot Delete",
//                                   "This club has ${club.playersCount} player(s). Remove or transfer them first.",
//                                   backgroundColor: Colors.orange,
//                                   colorText: Colors.white,
//                                   snackPosition: SnackPosition.TOP,
//                                 );
//                                 return;
//                               }

//                               final confirm = await Get.dialog<bool>(
//                                 AlertDialog(
//                                   title: const Text("Delete Club"),
//                                   content: Text(
//                                       "Delete ${club.name}? This cannot be undone."),
//                                   actions: [
//                                     TextButton(
//                                         onPressed: () =>
//                                             Get.back(result: false),
//                                         child: const Text("Cancel")),
//                                     TextButton(
//                                       onPressed: () => Get.back(result: true),
//                                       child: const Text("Delete",
//                                           style: TextStyle(color: Colors.red)),
//                                     ),
//                                   ],
//                                 ),
//                               );

//                               if (confirm == true) {
//                                 try {
//                                   await api.deleteClub(club.id);
//                                   refresh();
//                                   Get.snackbar("Success", "Club deleted",
//                                       backgroundColor: Colors.green,
//                                       colorText: Colors.white);
//                                 } catch (e) {
//                                   Get.snackbar("Error", e.toString(),
//                                       backgroundColor: Colors.red,
//                                       colorText: Colors.white);
//                                 }
//                               }
//                             }
//                           },
//                           itemBuilder: (_) {
//                             final List<PopupMenuEntry<String>> items = [
//                               const PopupMenuItem(
//                                 value: 'edit',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.edit, color: Colors.deepPurple),
//                                     SizedBox(width: 12),
//                                     Text("Edit"),
//                                   ],
//                                 ),
//                               ),
//                             ];

//                             // Only show Delete if club has 0 players
//                             if (club.playersCount == null ||
//                                 club.playersCount == 0) {
//                               items.add(
//                                 const PopupMenuItem(
//                                   value: 'delete',
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.delete, color: Colors.red),
//                                       SizedBox(width: 12),
//                                       Text("Delete",
//                                           style: TextStyle(color: Colors.red)),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }

//                             return items;
//                           },
//                         )
//                       else
//                         const Icon(Icons.chevron_right, color: Colors.grey),
//                     ],
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
