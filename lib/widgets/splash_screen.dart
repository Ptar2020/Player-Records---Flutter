import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:precords_android/widgets/bottom_menu.dart';
import 'package:precords_android/widgets/all_players.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds before navigating to BottomMenu
    Timer(const Duration(seconds: 2), () {
      // Navigate to BottomMenu which has AllPlayers as first page
      Get.offAll(const BottomMenu());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[700],
      body: Center(
        child: Text(
          "Precords",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
