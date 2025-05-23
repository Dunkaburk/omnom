import 'dart:async'; // For StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omnom/src/features/auth/application/auth_service.dart';
import 'package:omnom/src/features/auth/presentation/login_screen.dart';
import 'package:omnom/src/features/countries/presentation/countries_screen.dart';
import 'package:omnom/src/features/countries/presentation/country_detail_screen.dart';
import 'package:omnom/src/features/dishes/presentation/log_meal_screen.dart';
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
// final _loginNavigatorKey = GlobalKey<NavigatorState>(); // Not strictly needed if LoginScreen doesn't host sub-navigation

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/countries', // Default, redirect handles auth
    // Use authStateAsync.stream for GoRouterRefreshStream if it's an AsyncNotifier
    // If authStateChangesProvider is a direct StreamProvider, its stream is accessible.
    // Forcing dynamic for broader compatibility, ensure your stream emits on auth changes.
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream) as Stream<dynamic>),

    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authStateAsync.valueOrNull != null;
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/countries';
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        // No specific navigatorKey needed for a simple screen unless it manages its own stack.
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      ShellRoute(
        // Removed navigatorKey from ShellRoute as it might be deprecated or not needed here
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
                path: ':countryName',
                parentNavigatorKey: _rootNavigatorKey,
                pageBuilder: (context, state) {
                  final countryName = state.pathParameters['countryName']!;
                  return MaterialPage(
                      child: CountryDetailScreen(countryName: countryName));
                },
                routes: [
                  GoRoute(
                    path: 'log-meal',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final countryName = state.pathParameters['countryName']!;
                      return MaterialPage(
                        child: LogMealScreen(countryName: countryName),
                      );
                    },
                  ),
                ],
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
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Initial notification
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners(); // Notify on every stream event
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 