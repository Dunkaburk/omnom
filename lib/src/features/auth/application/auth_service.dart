import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omnom/src/features/auth/data/auth_repository.dart';

// Provider for the auth state changes stream
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

// Provider to expose the current user (synchronously, if available)
final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.getCurrentUser();
});

// You might also create a NotifierProvider here if you need to manage more complex auth state
// or expose methods for login/logout that handle loading/error states for the UI.
// For now, these two providers cover the basics. 