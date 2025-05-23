import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart'; // For Country type hint
import 'package:omnom/src/features/countries/presentation/widgets/country_list_item.dart';

class CountriesScreen extends ConsumerWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsyncValue = ref.watch(countriesStreamProvider);
    // These are now synchronous providers deriving from the stream or other state providers
    final List<Country> filteredCountries = ref.watch(filteredCountriesProvider);
    final List<String> uniqueContinentsList = ref.watch(uniqueContinentsProvider);

    final selectedContinentFilter = ref.watch(selectedContinentProvider);
    final currentFilterType = ref.watch(countryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a country...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<CountryFilterType>(
              segments: const <ButtonSegment<CountryFilterType>>[
                ButtonSegment(value: CountryFilterType.all, label: Text('All')),
                ButtonSegment(value: CountryFilterType.toCook, label: Text('To Cook')),
                ButtonSegment(value: CountryFilterType.explored, label: Text('Explored')),
              ],
              selected: {currentFilterType},
              onSelectionChanged: (Set<CountryFilterType> newSelection) {
                ref.read(countryFilterProvider.notifier).state = newSelection.first;
              },
            ),
          ),
          // Continent Chips - directly use uniqueContinentsList as it's now synchronous
          // The loading/error for this will be handled by the main countriesAsyncValue.when below
          if (uniqueContinentsList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('All Continents'),
                      selected: selectedContinentFilter == null,
                      onSelected: (selected) {
                        ref.read(selectedContinentProvider.notifier).state = null;
                      },
                    ),
                    ...uniqueContinentsList.map((continent) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Text(continent),
                          selected: selectedContinentFilter == continent,
                          onSelected: (selected) {
                            ref.read(selectedContinentProvider.notifier).state = selected ? continent : null;
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          Expanded(
            child: countriesAsyncValue.when(
              data: (_) { // We use filteredCountries for the actual list
                if (filteredCountries.isEmpty) {
                  return const Center(child: Text('No countries match your filters.'));
                }
                return ListView.builder(
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    return CountryListItem(
                      country: country,
                      onTap: () {
                        context.go('/countries/${country.name}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error loading countries: ${err.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
} 