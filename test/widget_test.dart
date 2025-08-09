// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:omnom/app.dart';
import 'package:omnom/src/routing/app_router.dart' show goRouterProvider, ProfileScreen, ScrapbookScreen;
import 'package:omnom/src/routing/scaffold_with_nav_bar.dart';
import 'package:omnom/src/features/auth/application/auth_service.dart';
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/countries/presentation/countries_screen.dart';
import 'package:omnom/src/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('App shows Login screen when logged out', (WidgetTester tester) async {
    final overrides = <Override>[
      // Simulate logged-out state without touching Firebase
      authStateChangesProvider.overrideWith((ref) => Stream<User?>.value(null)),
      currentUserProvider.overrideWith((ref) => null),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const CulinaryCoupleApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Culinary Couple'), findsOneWidget);
    expect(find.text('Enter Our Culinary World'), findsOneWidget);
  });

  testWidgets('Countries screen renders and bottom nav is present', (WidgetTester tester) async {
    final sampleCountries = <Country>[
      Country(id: 'it', name: 'Italy', flagEmoji: '🇮🇹', continent: 'Europe'),
      Country(id: 'jp', name: 'Japan', flagEmoji: '🇯🇵', continent: 'Asia'),
    ];

    final overrides = <Override>[
      // Provide a custom router that starts at /countries and skips auth redirects
      goRouterProvider.overrideWithValue(
        GoRouter(
          initialLocation: '/countries',
          routes: [
            ShellRoute(
              builder: (context, state, child) => ScaffoldWithNavBar(child: child),
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
                ),
                GoRoute(
                  path: '/countries',
                  pageBuilder: (context, state) => const NoTransitionPage(child: CountriesScreen()),
                ),
                GoRoute(
                  path: '/scrapbook',
                  pageBuilder: (context, state) => const NoTransitionPage(child: ScrapbookScreen()),
                ),
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
      // Stub country data providers to avoid Firestore
      countriesStreamProvider.overrideWith((ref) => Stream.value(sampleCountries)),
      countriesWithExplorationStatusProvider.overrideWith(
        (ref) => Stream.value(
          sampleCountries
              .map((c) => CountryWithExplorationStatus(country: c, isExplored: false))
              .toList(),
        ),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const CulinaryCoupleApp(),
      ),
    );

    await tester.pumpAndSettle();

    // AppBar title of Countries screen
    expect(find.text('Countries'), findsWidgets);

    // Stubbed countries render
    expect(find.text('Italy'), findsOneWidget);
    expect(find.text('Japan'), findsOneWidget);

    // Bottom navigation labels
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Countries'), findsWidgets); // label + app bar
    expect(find.text('Scrapbook'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
