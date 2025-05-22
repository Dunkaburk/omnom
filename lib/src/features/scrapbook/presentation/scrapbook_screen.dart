import 'package:flutter/material.dart';

class ScrapbookScreen extends StatelessWidget {
  const ScrapbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrapbook'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Scrapbook Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
} 