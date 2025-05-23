import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnom/src/features/users/domain/user_profile.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  // Get a stream of a single user profile
  Stream<UserProfile> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => UserProfile.fromFirestore(snapshot));
  }

  // Fetch a single user profile once
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return UserProfile.fromFirestore(snapshot);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile for $uid: $e');
      rethrow;
    }
  }

  // Update user profile (example for name and imageURL)
  Future<void> updateUserProfile(String uid, String name, String profileImageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'profileImageUrl': profileImageUrl,
      }, SetOptions(merge: true)); // Use merge to avoid overwriting other fields if any
    } catch (e) {
      print('Error updating user profile for $uid: $e');
      rethrow;
    }
  }

  // Method to fetch profiles for a list of UIDs (useful for the two-user scenario)
  Future<Map<String, UserProfile>> getMultipleUserProfiles(List<String> uids) async {
    if (uids.isEmpty) return {};
    final Map<String, UserProfile> profiles = {};
    try {
      // Firestore 'in' query can fetch up to 10 documents at a time.
      // If you had more users, you might need to batch this.
      // For two users, it's perfectly fine.
      final querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: uids)
          .get();

      for (var doc in querySnapshot.docs) {
        profiles[doc.id] = UserProfile.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching multiple user profiles: $e');
      // Depending on requirements, you might want to return partial data or rethrow
    }
    return profiles;
  }
} 