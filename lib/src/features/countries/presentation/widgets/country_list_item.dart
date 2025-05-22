import 'package:flutter/material.dart';
import 'package:omnom/src/features/countries/domain/country.dart';

class CountryListItem extends StatelessWidget {
  final Country country;
  final VoidCallback? onTap;

  const CountryListItem({super.key, required this.country, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        country.flagEmoji,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(country.name),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
      onTap: onTap,
    );
  }
} 