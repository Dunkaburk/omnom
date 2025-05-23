import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart'; // Import repository
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/auth/data/auth_repository.dart'; // Corrected import
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async'; // Required for StreamController and other async operations
// TODO: Import Meal model and providers if needed for future 'isExplored' logic

part 'country_service.g.dart'; // For Riverpod generator

// Wrapper class
class CountryWithExplorationStatus {
  final Country country;
  final bool isExplored;

  CountryWithExplorationStatus({required this.country, required this.isExplored});
}

// Enum for filtering
enum CountryFilterType {
  all,
  explored, // Cooked at least one meal from
  toCook    // No meals cooked from yet
}

// Provider for the stream of countries from the repository
final countriesStreamProvider = StreamProvider<List<Country>>((ref) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.getCountriesStream(); // Renamed from watchCountries
});

// Provider for the current filter type
final countryFilterTypeProvider = StateProvider<CountryFilterType>((ref) => CountryFilterType.all);

// Provider for the search query
final countrySearchQueryProvider = StateProvider<String>((ref) => '');

// Provider for the selected filter type (All, To Cook, Explored)
final countryFilterProvider = StateProvider<CountryFilterType>((ref) => CountryFilterType.all);

// Provider for the selected continent filter
final selectedContinentProvider = StateProvider<String?>((ref) => null);

// Provider for the list of unique continents (derived from the countries list from Firestore)
final uniqueContinentsProvider = Provider<List<String>>((ref) {
  // Watch the stream and get data, or default to empty list on error/loading
  final countriesData = ref.watch(countriesStreamProvider);
  return countriesData.when(
    data: (countries) {
      if (countries.isEmpty) return [];
      final continents = countries.map((c) => c.continent).toSet().toList();
      continents.sort();
      return continents;
    },
    loading: () => [], // Return empty list while loading
    error: (_, __) => [], // Return empty list on error
  );
});

// New provider for countries with their exploration status
final countriesWithExplorationStatusProvider = StreamProvider<List<CountryWithExplorationStatus>>((ref) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  
  return ref.watch(countriesStreamProvider.stream).asyncMap((countries) async {
    if (countries.isEmpty) {
      return [];
    }
    List<CountryWithExplorationStatus> result = [];
    for (final country in countries) {
      bool explored = false;
      try {
        final mealsStream = countryRepository.getMealsForCountryStream(country.id);
        final firstMealBatch = await mealsStream.first;
        if (firstMealBatch.isNotEmpty) {
          explored = true;
        }
      } catch (e) {
        // print('Error checking meals for country ${country.id} in countriesWithExplorationStatusProvider: $e');
      }
      result.add(CountryWithExplorationStatus(country: country, isExplored: explored));
    }
    return result;
  });
});

// Filtered countries provider (operates on data from countriesWithExplorationStatusProvider)
final filteredCountriesProvider = Provider<List<Country>>((ref) {
  final countriesWithStatusAsync = ref.watch(countriesWithExplorationStatusProvider);
  
  return countriesWithStatusAsync.when(
    data: (countriesWithStatus) {
      final filterType = ref.watch(countryFilterTypeProvider);
      final searchQuery = ref.watch(countrySearchQueryProvider).toLowerCase();
      final selectedContinent = ref.watch(selectedContinentProvider);

      List<CountryWithExplorationStatus> filteredList = countriesWithStatus;

      // Apply continent filter first (if a continent is selected)
      if (selectedContinent != null) {
        filteredList = filteredList.where((cws) => cws.country.continent == selectedContinent).toList();
      }

      // Apply filter type (explored/toCook)
      if (filterType == CountryFilterType.explored) {
        filteredList = filteredList.where((cws) => cws.isExplored).toList();
      } else if (filterType == CountryFilterType.toCook) {
        filteredList = filteredList.where((cws) => !cws.isExplored).toList();
      }

      // Apply search query
      if (searchQuery.isNotEmpty) {
        filteredList = filteredList.where((cws) {
          return cws.country.name.toLowerCase().contains(searchQuery) ||
                 cws.country.continent.toLowerCase().contains(searchQuery);
        }).toList();
      }
      
      return filteredList.map((cws) => cws.country).toList();
    },
    loading: () => [],
    error: (err, stack) {
      return [];
    }
  );
});

// Simple provider to get a country by its ID (example, if needed elsewhere)
final countryByIdProvider = Provider.family<Country?, String>((ref, id) {
  final countries = ref.watch(countriesStreamProvider).value ?? [];
  try {
    return countries.firstWhere((country) => country.id == id);
  } catch (e) {
    return null; // Not found
  }
});

// We are no longer using @riverpod for these specific providers, so the .g.dart part is not strictly necessary
// unless other providers in this file still use it. If CountriesList was the only one, we can remove the part directive.
// For now, I'll assume it might be used by others or can be cleaned up later.
// The old CountriesList provider is removed as it's replaced by countriesStreamProvider.

@riverpod
Stream<int> cookedCountriesCount(CookedCountriesCountRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final countryRepository = ref.watch(countryRepositoryProvider);

  // Get the current user. If no user, emit 0.
  final user = authRepository.getCurrentUser();
  if (user == null) {
    return Stream.value(0);
  }

  // This stream will react to changes in the main countries collection.
  return countryRepository.getCountriesStream().asyncMap((countries) async {
    if (countries.isEmpty) {
      return 0;
    }
    int cookedCount = 0;
    // For each country, check if it has any meals.
    // This involves potentially many reads if done naively for all countries every time.
    // A more optimized approach might involve listening to meals subcollections or denormalization.
    for (final country in countries) {
      try {
        // Check if there's at least one meal for this country.
        // We only need to know if the stream is not empty.
        final mealsStream = countryRepository.getMealsForCountryStream(country.id);
        final firstMealBatch = await mealsStream.first; // Get the first list of meals
        if (firstMealBatch.isNotEmpty) {
          cookedCount++;
        }
      } catch (e) {
        // Handle cases where a country might not have a meals subcollection
        // or other errors during fetch. Log or ignore as appropriate.
        // print('Error checking meals for country ${country.id}: $e');
      }
    }
    return cookedCount;
  });
}

// Placeholder for the total number of countries.
const int totalGlobalCountries = 195; // As per initial UI

@riverpod
Future<double> cookedCountriesProgress(CookedCountriesProgressRef ref) async {
  // Wait for the stream to emit its first value (or latest)
  final count = await ref.watch(cookedCountriesCountProvider.stream).first;
  if (totalGlobalCountries == 0) return 0.0;
  return count / totalGlobalCountries;
}

// Consolidated provider for (cookedCount, totalCount)
@riverpod
class CookedCountriesData extends _$CookedCountriesData {
  @override
  Future<(int, int)> build() async {
    // Use .stream.first to get the current value from the StreamProvider
    final count = await ref.watch(cookedCountriesCountProvider.stream).first;
    return (count, totalGlobalCountries);
  }
} 