import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
// import 'package:omnom/src/features/dishes/domain/dish.dart'; // Will be used later

class CountryDetailScreen extends ConsumerWidget {
  final String countryName;
  const CountryDetailScreen({super.key, required this.countryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the country by name from the provider
    // In a real app, you might fetch this by ID from a database
    final countries = ref.watch(countriesListProvider);
    final Country country = countries.firstWhere(
      (c) => c.name == countryName,
      orElse: () => Country(name: 'Unknown', flagEmoji: '❓'), // Fallback
    );

    // Placeholder for actual flag image. For now, we'll use the emoji.
    // In the future, this could be a network image or a more elaborate asset.
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200, // Adjust height as needed
              color: Colors.teal, // Placeholder background color for the flag
              child: flagImageWidget,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text('Log New Meal for ${country.name}'),
                onPressed: () {
                  // TODO: Implement navigation to a form/modal to log a new meal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // As per Figma
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
            // TODO: Replace with a ListView.builder when meals data is available
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No meals cooked from this country yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 