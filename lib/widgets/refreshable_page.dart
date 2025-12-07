import 'package:flutter/material.dart';

typedef RefreshCallback = Future<void> Function();

class RefreshablePage extends StatelessWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const RefreshablePage({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

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
