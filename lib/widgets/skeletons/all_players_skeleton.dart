import 'package:flutter/material.dart';

class PlayerCardSkeleton extends StatelessWidget {
  const PlayerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final avatarBg = isDark ? Colors.grey.shade900 : Colors.grey.shade200;
    final initialsColor = isDark ? Colors.white : Colors.deepPurple;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        color: bg,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar + Jersey Badge
                  SizedBox(
                    width: 84,
                    height: 84,
                    child: Stack(
                      children: [
                        // Outer ring
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.deepPurple.shade900
                                : Colors.deepPurple.shade50,
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Inner avatar
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: avatarBg,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "A",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: initialsColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Jersey badge
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.deepPurple.shade600
                                  : Colors.deepPurple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                "10",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Container(
                          height: 20,
                          width: 160,
                          decoration: BoxDecoration(
                            color: shimmer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Position chip
                        Container(
                          height: 24,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Club + Flag row
                        Row(
                          children: [
                            Container(width: 18, height: 18, color: shimmer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(height: 16, color: shimmer),
                            ),
                            const SizedBox(width: 8),
                            Container(width: 32, height: 24, color: shimmer),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: shimmer, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// // lib/widgets/player/all_players.skeleton.dart
// import 'package:flutter/material.dart';

// class PlayerCardSkeleton extends StatelessWidget {
//   const PlayerCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Card(
//         elevation: 6,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Material(
//             color: Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   // Avatar + Jersey Badge
//                   SizedBox(
//                     width: 84,
//                     height: 84,
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: 84,
//                           height: 84,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: Container(
//                             width: 28,
//                             height: 28,
//                             decoration: const BoxDecoration(
//                               color: Colors.grey,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 14),

//                   // Text Content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Name
//                         Container(
//                           height: 20,
//                           width: 140,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Position chip
//                         Container(
//                           height: 24,
//                           width: 90,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade200,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         const SizedBox(height: 12),

//                         // Club + Flag row
//                         Row(
//                           children: [
//                             Container(
//                                 width: 18,
//                                 height: 18,
//                                 color: Colors.grey.shade200),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Container(
//                                   height: 16, color: Colors.grey.shade200),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                                 width: 32,
//                                 height: 24,
//                                 color: Colors.grey.shade200),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(width: 8),
//                   Icon(Icons.chevron_right,
//                       color: Colors.grey.shade300, size: 22),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
