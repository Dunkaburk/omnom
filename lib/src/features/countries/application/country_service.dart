import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart'; // Import repository
import 'package:omnom/src/features/countries/domain/country.dart';

// part 'country_service.g.dart'; // Not needed if not using @riverpod for all

// Enum for filtering
enum CountryFilterType { all, toCook, explored }

// StreamProvider for live countries data from Firestore
final countriesStreamProvider = StreamProvider<List<Country>>((ref) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.watchCountries();
});

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

// Filtered countries provider (operates on data from countriesStreamProvider)
final filteredCountriesProvider = Provider<List<Country>>((ref) {
  final countriesData = ref.watch(countriesStreamProvider);
  final searchQuery = ref.watch(countrySearchQueryProvider).toLowerCase();
  final filterType = ref.watch(countryFilterProvider);
  final continent = ref.watch(selectedContinentProvider);

  return countriesData.when(
    data: (countries) {
      return countries.where((country) {
        final matchesSearchQuery = country.name.toLowerCase().contains(searchQuery);
        // Use the getter `isExplored` from the Country model
        final matchesFilterType = filterType == CountryFilterType.all ||
            (filterType == CountryFilterType.explored && country.isExplored) ||
            (filterType == CountryFilterType.toCook && !country.isExplored);
        final matchesContinent = continent == null || country.continent == continent;
        return matchesSearchQuery && matchesFilterType && matchesContinent;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// We are no longer using @riverpod for these specific providers, so the .g.dart part is not strictly necessary
// unless other providers in this file still use it. If CountriesList was the only one, we can remove the part directive.
// For now, I'll assume it might be used by others or can be cleaned up later.
// The old CountriesList provider is removed as it's replaced by countriesStreamProvider. 