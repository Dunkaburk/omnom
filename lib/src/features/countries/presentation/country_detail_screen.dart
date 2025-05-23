import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
// import 'package:omnom/src/features/dishes/domain/dish.dart'; // For Dish type if needed for list items
import 'package:intl/intl.dart'; // For date formatting

class CountryDetailScreen extends ConsumerWidget {
  final String countryName; // Or countryId if using Firestore IDs directly for routing

  const CountryDetailScreen({super.key, required this.countryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsyncValue = ref.watch(countriesStreamProvider);

    return countriesAsyncValue.when(
      data: (countries) {
        Country? foundCountry;
        try {
          foundCountry = countries.firstWhere((c) => c.name == countryName);
        } catch (e) {
          foundCountry = null; // Explicitly null if not found
        }

        if (foundCountry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Country not found.')),
          );
        }
        // From here, foundCountry is guaranteed to be non-null.
        final Country country = foundCountry;

        Widget flagImageWidget = Center(
          child: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 150, color: Colors.white),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(country.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 200,
                  color: Colors.teal,
                  child: flagImageWidget,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: Text('Log New Meal for ${country.name}'),
                    onPressed: () {
                      context.go('/countries/${country.name}/log-meal');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      textStyle: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Meals Cooked',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                if (country.dishes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No meals cooked from this country yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true, // Important for ListView inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the inner list
                    itemCount: country.dishes.length,
                    itemBuilder: (context, index) {
                      final dish = country.dishes[index];
                      return ListTile(
                        // leading: dish.imageUrl != null ? Image.network(dish.imageUrl!, width: 50, height: 50, fit: BoxFit.cover) : null,
                        title: Text(dish.name),
                        subtitle: Text('Cooked: ${DateFormat.yMMMd().format(dish.cookedDate)}\nRating: ${dish.rating}/10\n${dish.comment ?? ''}'),
                        isThreeLine: true,
                        // TODO: Add onTap to view/edit dish details if needed
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(countryName)), // Show title while loading
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error loading country details: ${err.toString()}')),
      ),
    );
  }
} 