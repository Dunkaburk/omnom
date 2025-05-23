// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$uniqueContinentsHash() => r'e46d5009e56a3f2f0b387040ee1f61a2a88ae540';

/// See also [uniqueContinents].
@ProviderFor(uniqueContinents)
final uniqueContinentsProvider = AutoDisposeProvider<List<String>>.internal(
  uniqueContinents,
  name: r'uniqueContinentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uniqueContinentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UniqueContinentsRef = AutoDisposeProviderRef<List<String>>;
String _$filteredCountriesHash() => r'fc0ef7e6c91d6bccf4597002576aefc8e7c1fc24';

/// See also [filteredCountries].
@ProviderFor(filteredCountries)
final filteredCountriesProvider = AutoDisposeProvider<List<Country>>.internal(
  filteredCountries,
  name: r'filteredCountriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredCountriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredCountriesRef = AutoDisposeProviderRef<List<Country>>;
String _$countriesListHash() => r'c8846ce0773049bd3f0432237f04626d6526900e';

/// See also [CountriesList].
@ProviderFor(CountriesList)
final countriesListProvider =
    AutoDisposeNotifierProvider<CountriesList, List<Country>>.internal(
  CountriesList.new,
  name: r'countriesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$countriesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CountriesList = AutoDisposeNotifier<List<Country>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
