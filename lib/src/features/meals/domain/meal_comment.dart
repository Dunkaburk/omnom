import 'package:cloud_firestore/cloud_firestore.dart';

class MealComment {
  final String id;
  final String userId;
  final String userName; // Denormalized for display
  final String userProfileUrl; // Denormalized for display
  final String text;
  final Timestamp timestamp;

  MealComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userProfileUrl,
    required this.text,
    required this.timestamp,
  });

  factory MealComment.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for CommentId: $id');
    }
    return MealComment(
      id: id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Unknown User',
      userProfileUrl: data['userProfileUrl'] as String? ?? '',
      text: data['text'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userProfileUrl': userProfileUrl,
      'text': text,
      'timestamp': timestamp,
    };
  }
} 