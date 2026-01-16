import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotelspot/core/services/storage/user_session_service.dart';
import 'package:hotelspot/features/onboarding/presentation/pages/on_boarding_screen.dart';
import 'package:hotelspot/screens/main_bottom_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) return;
      final userSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = userSessionService.isLoggedIn();

      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainBottomScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _timer?.cancel();
          final userSessionService = ref.read(userSessionServiceProvider);
          final isLoggedIn = userSessionService.isLoggedIn();

          if (isLoggedIn) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainBottomScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF183A63), Color(0xFF6B4BCF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.hotel,
                      size: 140,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
