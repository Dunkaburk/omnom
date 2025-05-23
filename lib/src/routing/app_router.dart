import 'dart:async'; // For StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omnom/src/features/auth/application/auth_service.dart';
import 'package:omnom/src/features/auth/presentation/login_screen.dart';
import 'package:omnom/src/features/countries/presentation/countries_screen.dart';
import 'package:omnom/src/features/countries/presentation/country_meals_screen.dart';
import 'package:omnom/src/features/dishes/presentation/log_meal_screen.dart';
import 'package:omnom/src/features/home/presentation/home_screen.dart';
import 'package:omnom/src/routing/scaffold_with_nav_bar.dart';
import 'package:omnom/src/features/meals/presentation/meal_detail_screen.dart';

// Placeholder screens for other tabs
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

// Define your route paths as constants
class AppRoutes {
  // static const String home = '/'; // This was the placeholder home
  static const String login = '/login';
  static const String actualHome = '/home'; // Assuming this is your actual home screen in ShellRoute
  static const String countries = '/countries';
  static const String countryMeals = ':countryId/meals'; // Path for list of meals in a country
  static const String countryDetail = ':countryId'; // Changed from :countryName to :countryId for consistency
  static const String logMeal = ':countryId/log-meal';
  static const String mealDetail = ':countryId/meals/:mealId'; // New path for specific meal detail
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login, // Start at login, redirect will handle auth
    debugLogDiagnostics: true, // Helpful for debugging routes
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream) as Stream<dynamic>),

    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authStateAsync.valueOrNull != null;
      final bool loggingIn = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !loggingIn) {
        return AppRoutes.login;
      }
      if (loggedIn && loggingIn) {
        // If logged in and on the login page, redirect to a default screen e.g., countries or actualHome
        return AppRoutes.countries; 
      }
      // If the user is logged in and tries to go to '/', and '/' is not a defined route anymore,
      // they might get a not found error unless '/' is part of the shell or another route.
      // If '/' was only the sample page, it's fine that it's gone.
      // If they hit '/', and are logged in, but '/' isn't defined they will see the errorBuilder.
      // Consider if you need a default route for '/' if a logged-in user lands there somehow.
      // For now, relying on specific paths like /home, /countries etc.
      return null;
    },

    routes: [
      // Removed the GoRoute for the placeholder home ('/')
      GoRoute(
        path: '${AppRoutes.countries}/${AppRoutes.mealDetail}', // Full path: /countries/:countryId/meals/:mealId
        parentNavigatorKey: _rootNavigatorKey, 
        builder: (context, state) {
          final countryId = state.pathParameters['countryId'];
          final mealId = state.pathParameters['mealId'];
          if (countryId == null || mealId == null) {
            return const Scaffold(
              body: Center(child: Text('Error: Country ID or Meal ID is missing')),
            );
          }
          return MealDetailScreen(countryId: countryId, mealId: mealId);
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.actualHome, // Changed from '/home' to use constant
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(), // Your actual HomeScreen
            ),
          ),
          GoRoute(
            path: AppRoutes.countries, // Changed from '/countries' to use constant
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CountriesScreen(),
            ),
            routes: [
              GoRoute(
                path: AppRoutes.countryMeals, // e.g., /countries/countryXYZ123/meals
                parentNavigatorKey: _rootNavigatorKey, // Show on top of the shell
                pageBuilder: (context, state) {
                  final countryId = state.pathParameters['countryId']!;
                  return MaterialPage(
                    child: CountryMealsScreen(countryId: countryId),
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.logMeal, // e.g., /countries/countryXYZ123/log-meal
                parentNavigatorKey: _rootNavigatorKey, // Show on top of the shell
                pageBuilder: (context, state) {
                  final countryId = state.pathParameters['countryId']!;
                  return MaterialPage(
                    child: LogMealScreen(countryId: countryId),
                  );
                },
              ),
              // The old countryDetail route can be added here too if needed, using :countryId
              // GoRoute(
              //   path: AppRoutes.countryDetail, // e.g. /countries/countryID
              //   parentNavigatorKey: _rootNavigatorKey,
              //   pageBuilder: (context, state) {
              //     final countryId = state.pathParameters['countryId']!;
              //      // return MaterialPage(child: CountryDetailScreen(countryId: countryId)); // If you have this screen adapting to countryId
              //      return MaterialPage(child: Text('Detail for country $countryId')); // Placeholder
              //   }
              // ),
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
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('Oops! The page at ${state.uri} was not found.\nError: ${state.error?.message}'),
      ),
    ),
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 