import 'package:cloud_firestore/cloud_firestore.dart';

class Dish {
  final String id;
  final String name;
  final DateTime cookedDate;
  final double rating; // e.g., 9 out of 10
  final String? comment; // Added comment field
  final String? imageUrl; // Optional image of the dish
  final String? cookedByUserId; // Optional: UID of the user who cooked/logged

  Dish({
    required this.id,
    required this.name,
    required this.cookedDate,
    required this.rating,
    this.comment,
    this.imageUrl,
    this.cookedByUserId,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      cookedDate: (json['cookedDate'] as Timestamp).toDate(),
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      imageUrl: json['imageUrl'] as String?,
      cookedByUserId: json['cookedByUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cookedDate': Timestamp.fromDate(cookedDate),
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (cookedByUserId != null) 'cookedByUserId': cookedByUserId,
    };
  }

  Dish copyWith({
    String? id,
    String? name,
    DateTime? cookedDate,
    double? rating,
    String? comment,
    String? imageUrl,
    String? cookedByUserId,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      cookedDate: cookedDate ?? this.cookedDate,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrl: imageUrl ?? this.imageUrl,
      cookedByUserId: cookedByUserId ?? this.cookedByUserId,
    );
  }
} 