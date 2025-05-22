import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/presentation/widgets/country_list_item.dart';

class CountriesScreen extends ConsumerWidget {
  const CountriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesListProvider);
    // final router = GoRouter.of(context); // Get router instance

    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        // Removed leading back arrow as this is a root tab screen
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     if (GoRouter.of(context).canPop()) {
        //       GoRouter.of(context).pop();
        //     }
        //   },
        // ),
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
                // TODO: Implement search functionality
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('All')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('To Cook')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () {}, child: const Text('Explored')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return CountryListItem(
                  country: country,
                  onTap: () {
                    // Navigate to country detail screen
                    context.go('/countries/${country.name}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 