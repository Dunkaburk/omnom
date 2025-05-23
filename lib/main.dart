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
    Country(id: '', name: 'Italy', flagEmoji: '🇮🇹', continent: 'Europe', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/0/03/Flag_of_Italy.svg/2560px-Flag_of_Italy.svg.png'),
    Country(id: '', name: 'Japan', flagEmoji: '🇯🇵', continent: 'Asia', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/2560px-Flag_of_Japan.svg.png'),
    Country(id: '', name: 'Mexico', flagEmoji: '🇲🇽', continent: 'North America', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Flag_of_Mexico.svg/2560px-Flag_of_Mexico.svg.png'),
    Country(id: '', name: 'France', flagEmoji: '🇫🇷', continent: 'Europe', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/c/c3/Flag_of_France.svg/2560px-Flag_of_France.svg.png'),
    Country(id: '', name: 'India', flagEmoji: '🇮🇳', continent: 'Asia', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/2560px-Flag_of_India.svg.png'),
    Country(id: '', name: 'Spain', flagEmoji: '🇪🇸', continent: 'Europe', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9a/Flag_of_Spain.svg/2560px-Flag_of_Spain.svg.png'),
    Country(id: '', name: 'Brazil', flagEmoji: '🇧🇷', continent: 'South America', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/0/05/Flag_of_Brazil.svg/2200px-Flag_of_Brazil.svg.png'),
    Country(id: '', name: 'China', flagEmoji: '🇨🇳', continent: 'Asia', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/2560px-Flag_of_the_People%27s_Republic_of_China.svg.png'),
    Country(id: '', name: 'Germany', flagEmoji: '🇩🇪', continent: 'Europe', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/b/ba/Flag_of_Germany.svg/2560px-Flag_of_Germany.svg.png'),
    Country(id: '', name: 'United States', flagEmoji: '🇺🇸', continent: 'North America', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/en/thumb/a/a4/Flag_of_the_United_States.svg/2560px-Flag_of_the_United_States.svg.png'),
    Country(id: '', name: 'Thailand', flagEmoji: '🇹🇭', continent: 'Asia', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Flag_of_Thailand.svg/2560px-Flag_of_Thailand.svg.png'),
    Country(id: '', name: 'Greece', flagEmoji: '🇬🇷', continent: 'Europe', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/Flag_of_Greece.svg/2560px-Flag_of_Greece.svg.png'),
    Country(id: '', name: 'Morocco', flagEmoji: '🇲🇦', continent: 'Africa', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Morocco.svg/2560px-Flag_of_Morocco.svg.png'),
    Country(id: '', name: 'Argentina', flagEmoji: '🇦🇷', continent: 'South America', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Flag_of_Argentina.svg/2560px-Flag_of_Argentina.svg.png'),
    Country(id: '', name: 'Australia', flagEmoji: '🇦🇺', continent: 'Oceania', flagImageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Flag_of_Australia_%28converted%29.svg/2560px-Flag_of_Australia_%28converted%29.svg.png'),
  ];
}
