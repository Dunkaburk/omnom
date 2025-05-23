import 'package:flutter/material.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:go_router/go_router.dart'; // Added for navigation

class MealListItemWidget extends StatelessWidget {
  final Meal meal;
  // final String countryId; // Removed, meal.countryId should be used if needed for navigation path

  const MealListItemWidget({super.key, required this.meal}); // Updated constructor

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(meal.date);
    final firstImageUrl = meal.imageUrls.isNotEmpty ? meal.imageUrls.first : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell( // Added InkWell for tap functionality
        onTap: () {
          // Navigate to MealDetailScreen
          // Path: /countries/:countryId/meals/:mealId
          context.go('/countries/${meal.countryId}/meals/${meal.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // Display average rating, or a placeholder if no ratings
                      meal.userRatings.isNotEmpty 
                        ? 'Avg Rating: ${meal.averageRating.toStringAsFixed(1)}/10' 
                        : 'No ratings yet',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (firstImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    firstImageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, color: Colors.white70, size: 40),
                      );
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                          width: 80,
                          height: 80,
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
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(Icons.photo_camera, color: Colors.grey, size: 40),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 