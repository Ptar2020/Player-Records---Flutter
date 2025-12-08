// lib/widgets/skeletons/clubs_skeleton.dart
import 'package:flutter/material.dart';

class ClubCardSkeleton extends StatelessWidget {
  const ClubCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    final shimmer = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

    return Card(
      color: bg,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: shimmer,
                  shape: BoxShape.circle,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: shimmer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Container(
          height: 18,
          width: 160,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        subtitle: Container(
          height: 14,
          width: 120,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: shimmer.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        trailing: Container(
          width: 80,
          height: 32,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
