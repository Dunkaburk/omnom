import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/meals/application/meal_providers.dart'; // For mealsForCountryProvider
import 'package:omnom/src/features/meals/domain/meal.dart'; // For Meal model
import 'package:intl/intl.dart'; // For date formatting

class CountryDetailScreen extends ConsumerWidget {
  final String countryName;

  const CountryDetailScreen({super.key, required this.countryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the specific country by name to get its ID
    final allCountriesAsync = ref.watch(countriesStreamProvider);

    return allCountriesAsync.when(
      data: (allCountries) {
        Country? country;
        try {
          country = allCountries.firstWhere((c) => c.name == countryName);
        } catch (e) {
          country = null;
        }

        if (country == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Country Not Found')),
            body: Center(child: Text('Details for $countryName could not be loaded.')),
          );
        }

        // Now that we have the country and its ID, watch the meals for this country
        final mealsAsyncValue = ref.watch(mealsForCountryProvider(country.id));
        final Country nonNullCountry = country; // country is guaranteed non-null here

        return Scaffold(
          appBar: AppBar(
            title: Text(nonNullCountry.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined), // Icon for logging a meal
                tooltip: 'Log Meal',
                onPressed: () {
                  context.go('/countries/${nonNullCountry.name}/log-meal');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.blueGrey[100], // Example background color
                child: Center(
                  child: Text(
                    country.flagEmoji,
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continent: ${country.continent}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Logged Meals from ${country.name}:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: mealsAsyncValue.when(
                  data: (meals) {
                    if (meals.isEmpty) {
                      return const Center(
                        child: Text(
                          'No meals logged for this country yet. Tap the + icon to add one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.restaurant_menu, color: Colors.orangeAccent),
                            title: Text(meal.mealName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Cooked on: ${DateFormat.yMMMd().format(meal.cookedDate.toDate())}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              context.go('/meal/${meal.id}');
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading meals: ${err.toString()}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(appBar: AppBar(title: Text(countryName)), body: const Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(appBar: AppBar(title: Text(countryName)), body: Center(child: Text('Error loading country data: ${err.toString()}'))),
    );
  }
} 