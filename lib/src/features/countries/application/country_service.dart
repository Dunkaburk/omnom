import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart'; // Import repository
import 'package:omnom/src/features/countries/domain/country.dart';
// TODO: Import Meal model and providers if needed for future 'isExplored' logic

// part 'country_service.g.dart'; // Not needed if not using @riverpod for all

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

// Filtered countries provider (operates on data from countriesStreamProvider)
final filteredCountriesProvider = Provider<List<Country>>((ref) {
  final countries = ref.watch(countriesStreamProvider).value ?? [];
  final filterType = ref.watch(countryFilterTypeProvider);
  final searchQuery = ref.watch(countrySearchQueryProvider).toLowerCase();

  // Apply search query first
  List<Country> searchResults = countries;
  if (searchQuery.isNotEmpty) {
    searchResults = countries.where((country) {
      return country.name.toLowerCase().contains(searchQuery) ||
             country.continent.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // TODO: Re-implement 'isExplored' logic based on the top-level 'meals' collection.
  // This will likely involve fetching meals and checking their countryId.
  // For now, this filtering is disabled to allow compilation.
  /*
  // Apply filter type
  if (filterType == CountryFilterType.all) {
    return searchResults;
  } else {
    return searchResults.where((country) {
      // Placeholder for isExplored logic - this needs to be re-implemented
      // bool isExplored = country.isExplored; // This getter no longer exists
      // For now, let's assume a way to get this. This will be part of the next step.
      // This logic below is commented out as 'isExplored' is removed from Country model.
      // return (filterType == CountryFilterType.explored && isExplored) ||
      //        (filterType == CountryFilterType.toCook && !isExplored);
      return true; // Temporarily return all to avoid breaking, needs proper logic
    }).toList();
  }
  */
  return searchResults; // Return search results directly until filter is re-implemented
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