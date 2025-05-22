import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omnom/src/features/countries/presentation/countries_screen.dart';
import 'package:omnom/src/features/countries/presentation/country_detail_screen.dart';
import 'package:omnom/src/features/home/presentation/home_screen.dart';
import 'package:omnom/src/routing/scaffold_with_nav_bar.dart';

// Placeholder screens for other tabs
// class HomeScreen extends StatelessWidget { // Removed placeholder
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home')));
// }

class ScrapbookScreen extends StatelessWidget {
  const ScrapbookScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Scrapbook')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile')));
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/countries', // Start at countries page as per the sketch
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/countries',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CountriesScreen(),
            ),
            routes: [
              GoRoute(
                path: ':countryName', // Path parameter for country name
                // The parent navigator key ensures this screen covers the nav bar
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final countryName = state.pathParameters['countryName']!;
                  return MaterialPage(
                      child: CountryDetailScreen(countryName: countryName));
                },
              ),
            ],
          ),
          GoRoute(
            path: '/scrapbook',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScrapbookScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      // TODO: Add other routes (e.g., country detail, login)
    ],
  );
}); 