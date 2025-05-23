import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omnom/src/features/meals/application/meal_providers.dart';
import 'package:omnom/src/features/countries/data/country_repository.dart';
import 'package:omnom/src/features/meals/domain/meal.dart';
import 'package:omnom/src/features/meals/domain/meal_comment.dart';
import 'package:omnom/src/common_widgets/async_value_widget.dart'; // For AsyncValueWidget
// Make sure you have an auth provider that gives the current user's ID
// import 'package:omnom/src/features/auth/application/auth_providers.dart'; 
import 'package:go_router/go_router.dart'; // Import go_router

class MealDetailScreen extends ConsumerWidget {
  final String countryId;
  final String mealId;
  const MealDetailScreen({super.key, required this.countryId, required this.mealId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsyncValue = ref.watch(mealStreamProvider((countryId: countryId, mealId: mealId)));
    final commentsAsyncValue = ref.watch(mealCommentsStreamProvider((countryId: countryId, mealId: mealId)));
    final currentUserId = ref.watch(currentUserIdProvider);
    final userProfilesData = ref.watch(userProfilesForUiProvider); // For user names
    // final countryAsyncValue = ref.watch(countryDetailsProvider(countryId)); // To get country name for title

    final TextEditingController commentController = TextEditingController();

    // Define your two main user UIDs here for fetching their specific ratings
    // IMPORTANT: Replace these with the actual UIDs you provided
    const String user1UID = '7hXKbdQyR6SIsj4Ml9sbGletG3H3'; 
    const String user2UID = 'zbTUygo1UZO8QNVQWD2pjhAr4073';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Fallback navigation if there's no page to pop to
              context.go('/countries/$countryId/meals');
            }
          },
        ),
        title: AsyncValueWidget(
          value: mealAsyncValue,
          // If you want "Meal from [CountryName]", you'd also need to watch countryDetailsProvider
          // For now, just using meal name.
          data: (meal) => Text('Meal from ${meal.name}'), // Updated to reflect sketch more closely
          loading: () => const Text('Loading...'),
          error: (e, st) => const Text('Error')
        ),
        centerTitle: true,
      ),
      body: AsyncValueWidget<Meal>(
        value: mealAsyncValue,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading meal: $err')),
        data: (meal) {
          final user1Rating = meal.userRatings[user1UID];
          final user2Rating = meal.userRatings[user2UID];
          final user1Name = userProfilesData[user1UID]?.name ?? 'User 1';
          final user2Name = userProfilesData[user2UID]?.name ?? 'User 2';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cooked on ${DateFormat.yMMMMd().format(meal.date)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RatingDisplayCard(label: '$user1Name\'s Rating', rating: user1Rating),
                    RatingDisplayCard(label: '$user2Name\'s Rating', rating: user2Rating),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Average Rating: ${meal.averageRating.toStringAsFixed(1)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (meal.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 250, // Adjust as needed
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: meal.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: index < meal.imageUrls.length - 1 ? 8.0 : 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    meal.imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width * 0.7, // Adjust width
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorBuilder: (context, error, stackTrace) => 
                                      Container(width: MediaQuery.of(context).size.width * 0.7, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text(meal.name, style: Theme.of(context).textTheme.bodySmall), // Or specific caption if you add it to model
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('No photos for this meal.', style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Add/Edit Photos'),
                    onPressed: () {
                      // TODO: Implement Photo Management Logic
                      print('Add/Edit Photos pressed for meal: ${meal.id}');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black87),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AsyncValueWidget(
                  value: commentsAsyncValue,
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err,st) => Text('Error loading comments: $err'),
                  data: (comments) {
                    if (comments.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: Text('No comments yet. Be the first to comment!')),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final profile = userProfilesData[comment.userId];
                        return CommentTile(
                          userName: profile?.name ?? comment.userName,
                          userAvatarUrl: profile?.profileUrl,
                          commentText: comment.text,
                          timestamp: comment.timestamp.toDate(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (currentUserId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Add your thoughts on this meal...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onPressed: () async {
                            if (commentController.text.isNotEmpty && currentUserId != null && currentUserId.isNotEmpty) {
                              final allUserProfilesMap = ref.read(userProfilesMapProvider).valueOrNull ?? {};
                              final currentUserProfileData = allUserProfilesMap[currentUserId];
                              final newComment = MealComment(
                                id: '', 
                                userId: currentUserId,
                                userName: currentUserProfileData?.name ?? 'Current User',
                                userProfileUrl: currentUserProfileData?.profileImageUrl ?? '',
                                text: commentController.text,
                                timestamp: Timestamp.now(),
                              );
                              try {
                                await ref.read(countryRepositoryProvider).addCommentToCountryMeal(
                                  countryId: countryId,
                                  mealId: mealId,
                                  comment: newComment
                                );
                                commentController.clear();
                                FocusScope.of(context).unfocus();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to post comment: $e')),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text('Post', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit This Meal Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      // TODO: Implement Edit Meal Entry functionality
                      print('Edit This Meal Entry pressed for meal: ${meal.id}');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// New widget to display individual ratings as per sketch
class RatingDisplayCard extends StatelessWidget {
  final String label;
  final double? rating;

  const RatingDisplayCard({super.key, required this.label, this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating?.toStringAsFixed(0) ?? '-', // Display rating or dash
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final String userName;
  final String? userAvatarUrl;
  final String commentText;
  final DateTime timestamp;

  const CommentTile({
    super.key,
    required this.userName,
    this.userAvatarUrl,
    required this.commentText,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    String timeAgo;
    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m';
    } else {
      timeAgo = 'now';
    }

    Widget avatarWidget;
    if (userAvatarUrl != null && userAvatarUrl!.isNotEmpty && userAvatarUrl!.startsWith('http')) {
      avatarWidget = CircleAvatar(
        backgroundImage: NetworkImage(userAvatarUrl!),
        onBackgroundImageError: (_, __) { 
          print('Error loading network image for avatar: $userAvatarUrl');
        },
        radius: 20,
         child: (userAvatarUrl == null || userAvatarUrl!.isEmpty || !userAvatarUrl!.startsWith('http')) 
              ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?') 
              : null,
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 20,
        child: Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?'),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            avatarWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(commentText, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 