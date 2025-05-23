import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String name;
  final List<String> imageUrls; // For multiple images
  final DateTime date;
  final Map<String, double> userRatings; // Key: userId, Value: rating (e.g., 0.0-10.0)
  final String countryId; // To link back to a country
  final String cookedByUid; // UID of the user who initially added the meal or was primary cook
  // Add countryName for easier display if needed, but can also be fetched via countryId

  Meal({
    required this.id,
    required this.name,
    this.imageUrls = const [], // Default to empty list
    required this.date,
    this.userRatings = const {}, // Default to empty map
    required this.countryId,
    required this.cookedByUid,
  });

  // Factory constructor to create a Meal from a Firestore document
  factory Meal.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Meal',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userRatings: Map<String, double>.from((data['userRatings'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      )),
      countryId: data['countryId'] ?? '',
      cookedByUid: data['cookedByUid'] ?? '',
    );
  }

  // Method to convert a Meal instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrls': imageUrls,
      'date': Timestamp.fromDate(date),
      'userRatings': userRatings,
      'countryId': countryId,
      'cookedByUid': cookedByUid,
    };
  }

  // Helper to calculate average rating
  double get averageRating {
    if (userRatings.isEmpty) return 0.0;
    return userRatings.values.reduce((a, b) => a + b) / userRatings.length;
  }
} 