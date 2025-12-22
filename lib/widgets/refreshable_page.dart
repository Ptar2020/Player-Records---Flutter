import 'package:flutter/material.dart';

typedef RefreshCallback = Future<void> Function();

class RefreshablePage extends StatelessWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const RefreshablePage({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.deepPurple,
      backgroundColor: Colors.white,
      child: child,
    );
  }
}

// // // lib/widgets/refreshable_page.dart
