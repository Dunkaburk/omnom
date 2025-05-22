import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:omnom/src/features/countries/domain/country.dart';

part 'country_service.g.dart';

@riverpod
class CountriesList extends _$CountriesList {
  @override
  List<Country> build() {
    // Placeholder data - replace with actual data source (e.g., Firebase)
    return [
      Country(name: 'Italy', flagEmoji: '🇮🇹'),
      Country(name: 'Japan', flagEmoji: '🇯🇵'),
      Country(name: 'Mexico', flagEmoji: '🇲🇽'),
      Country(name: 'France', flagEmoji: '🇫🇷'),
      Country(name: 'India', flagEmoji: '🇮🇳'),
      Country(name: 'Spain', flagEmoji: '🇪🇸'),
      Country(name: 'Brazil', flagEmoji: '🇧🇷'),
      Country(name: 'China', flagEmoji: '🇨🇳'),
      Country(name: 'Germany', flagEmoji: '🇩🇪'),
      Country(name: 'United States', flagEmoji: '🇺🇸'),
    ];
  }

  // Add methods here to modify the list if needed, e.g., filter, add, remove
} 