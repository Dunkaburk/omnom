class Dish {
  final String id;
  final String name;
  final DateTime cookedDate;
  final double rating; // e.g., 9 out of 10
  final String? imageUrl; // Optional image of the dish

  Dish({
    required this.id,
    required this.name,
    required this.cookedDate,
    required this.rating,
    this.imageUrl,
  });
} 