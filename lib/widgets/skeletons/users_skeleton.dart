// lib/widgets/skeletons/users_skeleton.dart
import 'package:flutter/material.dart';

class UserCardSkeleton extends StatelessWidget {
  const UserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: shimmer),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            Container(height: 18, width: 140, color: shimmer),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            Container(height: 14, width: 100, color: shimmer),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Container(height: 12, color: shimmer)),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 12, color: shimmer)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(
                3,
                (_) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(width: 70, height: 24, color: shimmer),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
