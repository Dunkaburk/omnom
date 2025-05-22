import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/routing/app_router.dart';
import 'package:omnom/src/features/countries/presentation/countries_screen.dart';
import 'package:omnom/src/features/home/presentation/home_screen.dart';
import 'package:omnom/src/features/profile/presentation/profile_screen.dart';
import 'package:omnom/src/features/scrapbook/presentation/scrapbook_screen.dart';

class CulinaryCoupleApp extends ConsumerWidget {
  const CulinaryCoupleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Culinary Couple',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Replace with your app's color scheme
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins', // Assuming a custom font like Poppins
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange.shade700,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Ensures labels are always visible
        ),
      ),
    );
  }
} 