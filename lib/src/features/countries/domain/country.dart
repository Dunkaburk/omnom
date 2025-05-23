import 'package:cloud_firestore/cloud_firestore.dart';

class Country {
  final String id; // Firestore document ID
  final String name;
  final String flagEmoji; // Or a path to an image asset
  final String? flagImageUrl; // Added for network image
  final String continent;

  Country({
    required this.id,
    required this.name,
    required this.flagEmoji,
    this.flagImageUrl, // Added
    required this.continent,
  });

  factory Country.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, String id) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for CountryId: $id');
    }
    return Country(
      id: id,
      name: data['name'] as String? ?? 'Unnamed Country',
      flagEmoji: data['flagEmoji'] as String? ?? '🏁',
      flagImageUrl: data['flagImageUrl'] as String?, // Added
      continent: data['continent'] as String? ?? 'Unknown Continent',
    );
  }

  Map<String, dynamic> toFirestore(String id) {
    return {
      'name': name,
      'flagEmoji': flagEmoji,
      'flagImageUrl': flagImageUrl, // Added
      'continent': continent,
    };
  }

  Country copyWith({
    String? id,
    String? name,
    String? flagEmoji,
    String? flagImageUrl, // Added
    String? continent,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      flagImageUrl: flagImageUrl ?? this.flagImageUrl, // Added
      continent: continent ?? this.continent,
    );
  }
} 