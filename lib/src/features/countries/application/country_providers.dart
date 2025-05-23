import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';

// Provider for a single country's details
final countryDetailsProvider = StreamProvider.family<Country, String>((ref, countryId) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.getCountryDetailsStream(countryId);
});

// Provider for the list of meals for a specific country
final countryMealsProvider = StreamProvider.family<List<Meal>, String>((ref, countryId) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.getMealsForCountryStream(countryId);
}); 