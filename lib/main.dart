import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart'; // Assuming you have this file after FlutterFire setup

import 'package:omnom/app.dart';
import 'package:omnom/firebase_options.dart'; // Assuming this file exists after flutterfire configure
import 'package:omnom/src/features/countries/data/country_repository.dart'; // Import repository
import 'package:omnom/src/features/countries/domain/country.dart'; // Import Country model

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Firebase: Initializing...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase: Initialized successfully.');

    // Only attempt to add initial countries if Firebase initialized successfully
    print('Firestore: Checking to add initial countries...');
    final countryRepository = CountryRepository(FirebaseFirestore.instance);
    await countryRepository.addInitialCountries(_getInitialCountriesData());
    print('Firestore: Initial countries check complete.');

  } catch (e) {
    print('Error during app initialization: ${e.toString()}');
    // Optionally, you could show an error screen here instead of just running the app
    // For now, we'll print and let it try to run, but it might be unstable.
  }
  runApp(const ProviderScope(child: CulinaryCoupleApp()));
}

// Helper function to provide the initial list of countries
// Note: These countries won't have Firestore IDs initially; the repository will assign them.
List<Country> _getInitialCountriesData() {
  return [
    Country(id: '', name: 'Italy', flagEmoji: '🇮🇹', continent: 'Europe', dishes: []),
    Country(id: '', name: 'Japan', flagEmoji: '🇯🇵', continent: 'Asia', dishes: []),
    Country(id: '', name: 'Mexico', flagEmoji: '🇲🇽', continent: 'North America', dishes: []),
    Country(id: '', name: 'France', flagEmoji: '🇫🇷', continent: 'Europe', dishes: []),
    Country(id: '', name: 'India', flagEmoji: '🇮🇳', continent: 'Asia', dishes: []),
    Country(id: '', name: 'Spain', flagEmoji: '🇪🇸', continent: 'Europe', dishes: []),
    Country(id: '', name: 'Brazil', flagEmoji: '🇧🇷', continent: 'South America', dishes: []),
    Country(id: '', name: 'China', flagEmoji: '🇨🇳', continent: 'Asia', dishes: []),
    Country(id: '', name: 'Germany', flagEmoji: '🇩🇪', continent: 'Europe', dishes: []),
    Country(id: '', name: 'United States', flagEmoji: '🇺🇸', continent: 'North America', dishes: []),
    Country(id: '', name: 'Thailand', flagEmoji: '🇹🇭', continent: 'Asia', dishes: []),
    Country(id: '', name: 'Greece', flagEmoji: '🇬🇷', continent: 'Europe', dishes: []),
    Country(id: '', name: 'Morocco', flagEmoji: '🇲🇦', continent: 'Africa', dishes: []),
    Country(id: '', name: 'Argentina', flagEmoji: '🇦🇷', continent: 'South America', dishes: []),
    Country(id: '', name: 'Australia', flagEmoji: '🇦🇺', continent: 'Oceania', dishes: []),
  ];
}
