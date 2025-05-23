import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:omnom/src/features/countries/application/country_service.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/dishes/domain/dish.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart';
import 'package:uuid/uuid.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  final String countryName;

  const LogMealScreen({super.key, required this.countryName});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _currentRating = 0;
  String _mealName = '';
  String _comment = '';

  final _formKey = GlobalKey<FormState>();
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  Future<void> _logMeal(Country country) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date.')),
        );
        return;
      }
      if (_currentRating == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a rating.')),
        );
        return;
      }

      final newDish = Dish(
        id: _uuid.v4(),
        name: _mealName.isNotEmpty ? _mealName : 'Unnamed Meal',
        cookedDate: _selectedDay!,
        rating: _currentRating,
        comment: _comment,
      );

      try {
        final countryRepository = ref.read(countryRepositoryProvider);
        await countryRepository.addDishToCountry(country.id, newDish);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal logged successfully!')),
        );
        if (mounted) {
          GoRouter.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log meal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsyncValue = ref.watch(countriesStreamProvider);

    return countriesAsyncValue.when(
      data: (countries) {
        Country? foundCountry;
        try {
          foundCountry = countries.firstWhere((c) => c.name == widget.countryName);
        } catch (e) {
          foundCountry = null;
        }

        if (foundCountry == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Country not found to log meal.')),
          );
        }
        final Country country = foundCountry;

        Widget flagImageWidget = Center(
          child: Text(
            country.flagEmoji,
            style: const TextStyle(fontSize: 100, color: Colors.white),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Log meal'),
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
                    color: Colors.teal,
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
                  const Text('Rate Our Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: RatingBar.builder(
                      initialRating: _currentRating,
                      minRating: 0.5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 10,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) => setState(() => _currentRating = rating),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _currentRating == 0 ? 'Select a rating (min 0.5)' : '${_currentRating.toStringAsFixed(1)} / 10 stars',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  ),
                  const SizedBox(height: 20),
                  const Text('Add a Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Upload Photo'),
                    onPressed: () { /* TODO: Implement photo upload */ },
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
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Comment (Optional)', border: OutlineInputBorder()),
                    onChanged: (value) => setState(() => _comment = value),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Log Meal'),
                    onPressed: () => _logMeal(country),
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
      loading: () => Scaffold(appBar: AppBar(title: const Text('Log meal')), body: const Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(appBar: AppBar(title: const Text('Error')), body: Center(child: Text('Error: ${err.toString()}'))),
    );
  }
} 