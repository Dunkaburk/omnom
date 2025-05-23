import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';
import 'package:omnom/src/features/meals/domain/meal_comment.dart';

class MealRepository {
  final FirebaseFirestore _firestore;

  MealRepository(this._firestore);

  // Get a stream of a single meal
  Stream<Meal> getMealStream(String mealId) {
    return _firestore
        .collection('meals')
        .doc(mealId)
        .snapshots()
        .map((snapshot) => Meal.fromFirestore(snapshot));
  }

  // Get a stream of comments for a meal, ordered by timestamp
  Stream<List<MealComment>> getMealCommentsStream(String mealId) {
    return _firestore
        .collection('meals')
        .doc(mealId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MealComment.fromFirestore(doc, doc.id))
          .toList();
    });
  }

  // Add a comment to a meal
  Future<void> addComment(String mealId, MealComment comment) async {
    try {
      await _firestore
          .collection('meals')
          .doc(mealId)
          .collection('comments')
          .add(comment.toFirestore());
    } catch (e) {
      // Log error or handle as needed
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Update a meal's rating for a specific user
  Future<void> updateUserRating(String mealId, String userId, double rating) async {
    try {
      await _firestore.collection('meals').doc(mealId).update({
        'ratings.$userId': rating,
      });
    } catch (e) {
      print('Error updating rating: $e');
      rethrow;
    }
  }

  // Add/Edit photos (placeholder for now, would involve Firebase Storage)
  Future<void> updateMealPhotos(String mealId, List<String> newImageUrls) async {
    try {
      await _firestore.collection('meals').doc(mealId).update({
        'imageUrls': newImageUrls,
      });
    } catch (e) {
      print('Error updating meal photos: $e');
      rethrow;
    }
  }
   Future<void> editMealEntry(Meal meal) async {
    try {
      await _firestore
          .collection('meals')
          .doc(meal.id)
          .update(meal.toFirestore());
    } catch (e) {
      print('Error updating meal entry: $e');
      rethrow;
    }
  }

  // Add a new meal to the top-level 'meals' collection
  Future<void> addMeal(Meal meal) async {
    try {
      await _firestore
          .collection('meals')
          .doc(meal.id) // Using the client-generated ID from the Meal object
          .set(meal.toFirestore());
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }
} 