import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culinary Couple'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Changed to ListView to allow scrolling if content overflows
          children: [
            const Text(
              'Hello, Louise & Jonathan!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '49 out of 195 Countries Explored!',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0), // Added padding for progress bar
              child: ClipRRect( // Used ClipRRect for rounded corners
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 49 / 195,
                  minHeight: 20, // Increased height
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Next Adventure?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0), // Added padding for button
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Randomize Country logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for button
                  ),
                ),
                child: const Text('Randomize Our Next Country!', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Our Latest Feasts:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Placeholder for "Our Latest Feasts" - will implement this with actual data later
            SizedBox(
              height: 200, // Adjust height as needed
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  FeastCard(imagePath: 'assets/images/italian_pasta.png', title: 'Italian pasta'),
                  FeastCard(imagePath: 'assets/images/japanese_sushi.png', title: 'Japanese Sushi'),
                  FeastCard(imagePath: 'assets/images/mexican_tacos.png', title: 'Mexican Tacos'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeastCard extends StatelessWidget {
  final String imagePath; // Placeholder for image
  final String title;

  const FeastCard({super.key, required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Adjust width as needed
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1, // Makes the image container a square
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(75), // Circular images
                  image: DecorationImage(
                    // TODO: Replace with actual image loading.
                    // For now, using a colored box as a placeholder if imagePath is not found
                    // or if you haven't set up assets yet.
                    image: AssetImage(imagePath), // Assumes images are in assets/images
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback in case image fails to load
                      // You might want to log the error or show a different placeholder
                      // For simplicity, just showing a colored box
                      // print('Error loading image: \$exception');
                    },
                  ),
                  boxShadow: [ // Optional: add some shadow for depth
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                ),
                // Fallback child if image fails to load, remove if onError handles it well
                child: !const bool.fromEnvironment("dart.library.io") && imagePath.isEmpty ? Container(color: Colors.grey[200]) : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ],
      ),
    );
  }
} 