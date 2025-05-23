import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/countries/domain/country.dart';
import 'package:omnom/src/features/dishes/domain/dish.dart';

class CountryRepository {
  final FirebaseFirestore _firestore;

  CountryRepository(this._firestore);

  // Get a stream of all countries
  Stream<List<Country>> watchCountries() {
    return _firestore.collection('countries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Country.fromJson(doc.data(), doc.id)).toList();
    });
  }

  // Add a new dish to a specific country
  // This assumes dishes are stored as an array within the country document, as per guidelines.
  Future<void> addDishToCountry(String countryId, Dish dish) async {
    final countryRef = _firestore.collection('countries').doc(countryId);
    await countryRef.update({
      'dishes': FieldValue.arrayUnion([dish.toJson()])
    });
  }

  // Helper to add initial set of countries if the collection is empty
  // This is useful for development and first-time setup.
  Future<void> addInitialCountries(List<Country> initialCountries) async {
    final countriesCollection = _firestore.collection('countries');
    final snapshot = await countriesCollection.limit(1).get();

    if (snapshot.docs.isEmpty) {
      final batch = _firestore.batch();
      for (var country in initialCountries) {
        // When adding, Firestore will auto-generate an ID if we use .add()
        // If we want to use our predefined ID from the model, we'd use .doc(country.id).set()
        // For simplicity with initial data that doesn't have IDs yet, let's allow auto-ID for now.
        // However, our Country model expects an ID. This needs careful handling.
        // Let's assume initialCountries are just data templates and we let Firestore create IDs.
        // Or, we ensure our initial data has pre-generated IDs (e.g. country name slugified)

        // For the guideline where `dishes` is an array in `country`, we set it directly.
        final docRef = countriesCollection.doc(); // Firestore generates ID
        Country countryWithId = country.copyWith(id: docRef.id); // Assign Firestore-generated ID
        batch.set(docRef, countryWithId.toJson());
      }
      await batch.commit();
      print('Initial countries added to Firestore.');
    } else {
      print('Countries collection already exists. Skipping initial data.');
    }
  }
}

// Provider for the CountryRepository
final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  return CountryRepository(FirebaseFirestore.instance);
}); 