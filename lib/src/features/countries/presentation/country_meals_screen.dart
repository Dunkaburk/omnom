import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/application/country_providers.dart';
import 'package:omnom/src/features/countries/presentation/widgets/meal_list_item_widget.dart';
import 'package:omnom/src/common_widgets/async_value_widget.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:go_router/go_router.dart';

class CountryMealsScreen extends ConsumerWidget {
  final String countryId;
  const CountryMealsScreen({super.key, required this.countryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryAsyncValue = ref.watch(countryDetailsProvider(countryId));
    final mealsAsyncValue = ref.watch(countryMealsProvider(countryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AsyncValueWidget(
          value: countryAsyncValue,
          data: (country) => Text(country.name),
          loading: () => const Text('Loading...'),
          error: (e, st) => const Text('Error'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          AsyncValueWidget(
            value: countryAsyncValue,
            data: (country) {
              // Placeholder for flag image - replace with actual image logic
              Widget flagImageWidget;
              if (country.flagImageUrl != null && country.flagImageUrl!.isNotEmpty) {
                 flagImageWidget = Image.network(
                    country.flagImageUrl!, // Assuming you have a flagImageUrl on Country model
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                        return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: Center(child: Text(country.flagEmoji, style: const TextStyle(fontSize: 100))),
                        );
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: Center(
                                child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                ),
                            ),
                        );
                    },
                );
              } else {
                flagImageWidget = Container(
                  height: 250,
                  color: Colors.teal, // Placeholder color
                  child: Center(
                    child: Text(
                      country.flagEmoji, // Display emoji if no image URL
                      style: const TextStyle(fontSize: 100),
                    ),
                  ),
                );
              }
              return flagImageWidget;
            },
            loading: () => Container(
              height: 250,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Container(
              height: 250,
              color: Colors.red[100],
              child: const Center(child: Text('Could not load country image')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: AsyncValueWidget(
                value: countryAsyncValue,
                data: (country) => Text('Log New Meal for ${country.name}'),
                loading: () => const Text('Log New Meal'),
                error: (e, st) => const Text('Log New Meal'),
              ),
              onPressed: () {
                // Navigate to LogMealScreen with countryId
                // The route path is /countries/:countryId/log-meal
                // The countryId is already available in this screen as widget.countryId or country.id from countryAsyncValue
                final countryIdForLog = countryAsyncValue.value?.id;
                if (countryIdForLog != null) {
                  context.go('/countries/$countryIdForLog/log-meal');
                } else {
                  // Handle case where countryId is not available, though it should be if the button is enabled
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not determine country to log meal for.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Meals Cooked',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: mealsAsyncValue,
              data: (meals) {
                if (meals.isEmpty) {
                  return const Center(child: Text('No meals logged yet for this country.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return MealListItemWidget(meal: meal);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error loading meals: ${e.toString()}')),
            ),
          ),
        ],
      ),
    );
  }
} 