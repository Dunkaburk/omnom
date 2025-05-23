import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:omnom/src/features/countries/application/country_providers.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';
import 'package:omnom/src/features/meals/application/meal_providers.dart';
import 'package:omnom/src/common_widgets/async_value_widget.dart';
import 'package:uuid/uuid.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  final String countryId;

  const LogMealScreen({super.key, required this.countryId});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _currentUserRating = 0;
  String _mealName = '';

  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _logMeal(Country country, WidgetRef ref) async {
    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null || currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in.')),
        );
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_selectedDay == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a date.')),
          );
        }
        return;
      }
      if (_currentUserRating == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide your rating for the meal.')),
          );
        }
        return;
      }

      List<String> uploadedImageUrls = [];

      final newMeal = Meal(
        id: _uuid.v4(),
        name: _mealName.isNotEmpty ? _mealName : 'Unnamed Meal',
        countryId: country.id,
        date: _selectedDay!,
        userRatings: { currentUserId: _currentUserRating },
        imageUrls: uploadedImageUrls,
        cookedByUid: currentUserId,
      );

      try {
        final countryRepository = ref.read(countryRepositoryProvider);
        await countryRepository.addMealToCountry(country.id, newMeal);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal logged successfully!')),
          );
          GoRouter.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log meal: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countryAsyncValue = ref.watch(countryDetailsProvider(widget.countryId));

    return AsyncValueWidget<Country>(
      value: countryAsyncValue,
      loading: () => Scaffold(appBar: AppBar(title: const Text('Log Your Meal')), body: const Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(appBar: AppBar(title: const Text('Error')), body: Center(child: Text('Error loading country data: ${err.toString()}'))),
      data: (country) {
        Widget flagImageWidget = Center(
          child: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 100, color: Colors.white),
          ),
        );
        if (country.flagImageUrl != null && country.flagImageUrl!.isNotEmpty) {
            flagImageWidget = Image.network(
                country.flagImageUrl!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(country.flagEmoji, style: const TextStyle(fontSize: 100, color: Colors.white)),
                ),
                 loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
            );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Log Meal for ${country.name}'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => GoRouter.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    color: Theme.of(context).primaryColorDark,
                    child: flagImageWidget,
                  ),
                  const SizedBox(height: 20),
                  TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: CalendarFormat.month,
                    headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
                    calendarBuilders: CalendarBuilders(
                      selectedBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(date.day.toString(), style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Your Rating for This Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _currentUserRating,
                      minRating: 0.5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 10,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) => setState(() => _currentUserRating = rating),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _currentUserRating == 0 ? 'Select your rating (min 0.5)' : '${_currentUserRating.toStringAsFixed(1)} / 10 stars',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  ),
                  const SizedBox(height: 20),
                  const Text('Add Photos (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Upload Photos'),
                    onPressed: () { /* TODO: Implement multiple photo upload logic, update uploadedImageUrls */ },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12.0), backgroundColor: Colors.grey[200]),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Meal Name', border: OutlineInputBorder()),
                    onChanged: (value) => setState(() => _mealName = value),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a meal name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Log This Meal'),
                    onPressed: () => _logMeal(country, ref),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0), textStyle: const TextStyle(fontSize: 18.0)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 