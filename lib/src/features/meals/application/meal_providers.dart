import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/meals/data/meal_repository.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';
import 'package:omnom/src/features/meals/domain/meal_comment.dart';
import 'package:omnom/src/features/auth/application/auth_service.dart';
import 'package:omnom/src/features/users/domain/user_profile.dart';
import 'package:omnom/src/features/users/data/user_repository.dart';

// Provider for FirebaseFirestore instance
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider for MealRepository (consider if still needed for top-level meal operations)
final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(ref.watch(firebaseFirestoreProvider));
});

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firebaseFirestoreProvider));
});

// Define a type for the family parameter for clarity
typedef MealDetailParameters = ({String countryId, String mealId});

// StreamProvider for a single meal from a country's subcollection
final mealStreamProvider = StreamProvider.autoDispose.family<Meal, MealDetailParameters>((ref, params) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.getMealFromCountryStream(countryId: params.countryId, mealId: params.mealId);
});

// StreamProvider for meal comments from a country's subcollection
final mealCommentsStreamProvider =
    StreamProvider.autoDispose.family<List<MealComment>, MealDetailParameters>((ref, params) {
  final countryRepository = ref.watch(countryRepositoryProvider);
  return countryRepository.getMealCommentsFromCountryStream(countryId: params.countryId, mealId: params.mealId);
});

// Provider to get current user's ID from Firebase Auth
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.uid;
});

// AsyncProvider to fetch and provide the map of UserProfiles for the two main users.
// This will fetch data from Firestore.
final userProfilesMapProvider = FutureProvider<Map<String, UserProfile>>((ref) async {
  // IMPORTANT: Replace these with the ACTUAL Firebase UIDs of your two users.
  const String user1UID = 'USER_1_UID_PLACEHOLDER'; // e.g., 'firebaseUidForAva'
  const String user2UID = 'USER_2_UID_PLACEHOLDER'; // e.g., 'firebaseUidForLiam'

  if (user1UID == 'USER_1_UID_PLACEHOLDER' || user2UID == 'USER_2_UID_PLACEHOLDER') {
    print(
        'WARNING: Placeholder UIDs are still in userProfilesMapProvider. Update them with actual Firebase UIDs.');
    // Return empty or throw error if UIDs are not set, to avoid runtime issues with placeholder values.
    return {}; 
  }

  final userRepository = ref.watch(userRepositoryProvider);
  final uidsToFetch = [user1UID, user2UID].where((uid) => uid.isNotEmpty).toList();
  
  if (uidsToFetch.isEmpty) {
    return {};
  }
  
  return await userRepository.getMultipleUserProfiles(uidsToFetch);
});

// This provider is kept for semantic compatibility with the UI, 
// but now it transforms the data from userProfilesMapProvider.
// The UI expects Map<String, ({String name, String profileUrl})>
final userProfilesForUiProvider = Provider<Map<String, ({String name, String profileUrl})>>((ref) {
  final profilesAsyncValue = ref.watch(userProfilesMapProvider);
  return profilesAsyncValue.when(
    data: (profilesMap) {
      return profilesMap.map(
        (uid, userProfile) => MapEntry(
          uid,
          (name: userProfile.name, profileUrl: userProfile.profileImageUrl),
        ),
      );
    },
    loading: () => {},
    error: (e, s) {
      print('Error in userProfilesForUiProvider: $e');
      return {}; 
    },
  );
});

// StreamProvider to get all meals for a specific countryId
final mealsForCountryProvider = StreamProvider.autoDispose.family<List<Meal>, String>((ref, countryId) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  // This still queries the top-level 'meals' collection. 
  // If all meals are now in subcollections, this provider might not return expected results
  // or should be removed/refactored to use CountryRepository.getMealsForCountryStream.
  // For now, leaving as is, but be aware of this discrepancy.
  return firestore
      .collection('meals')
      .where('countryId', isEqualTo: countryId)
      // Optionally, order them by cookedDate or mealName
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Meal.fromFirestore(doc)).toList());
}); 