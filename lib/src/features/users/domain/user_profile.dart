import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String profileImageUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.profileImageUrl,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for UserProfileId: ${snapshot.id}');
    }
    return UserProfile(
      uid: snapshot.id, // The document ID is the user's UID
      name: data['name'] as String? ?? 'Unknown User',
      profileImageUrl: data['profileImageUrl'] as String? ?? '', // Default to empty if not set
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'profileImageUrl': profileImageUrl,
      // UID is not stored in the document body as it's the document ID
    };
  }
} 