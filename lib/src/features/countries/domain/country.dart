import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omnom/src/features/dishes/domain/dish.dart';

class Country {
  final String id; // Firestore document ID
  final String name;
  final String flagEmoji; // Or a path to an image asset
  final String continent;
  final List<Dish> dishes; // List of dishes cooked from this country

  Country({
    required this.id,
    required this.name,
    required this.flagEmoji,
    required this.continent,
    this.dishes = const [], // Default to an empty list
  });

  bool get isExplored => dishes.isNotEmpty;

  factory Country.fromJson(Map<String, dynamic> json, String id) {
    var dishList = <Dish>[];
    if (json['dishes'] != null) {
      dishList = (json['dishes'] as List<dynamic>)
          .map((dishJson) => Dish.fromJson(dishJson as Map<String, dynamic>))
          .toList();
    }
    return Country(
      id: id,
      name: json['name'] as String,
      flagEmoji: json['flagEmoji'] as String,
      continent: json['continent'] as String,
      dishes: dishList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'flagEmoji': flagEmoji,
      'continent': continent,
      // Dishes will be a subcollection, so not usually stored directly in the country document this way,
      // but let's include it if we were to embed. For subcollections, this part would be omitted.
      // As per guidelines, dishes is an array of maps in the country document.
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
    };
  }

  Country copyWith({
    String? id,
    String? name,
    String? flagEmoji,
    String? continent,
    List<Dish>? dishes,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      continent: continent ?? this.continent,
      dishes: dishes ?? this.dishes,
    );
  }
} 